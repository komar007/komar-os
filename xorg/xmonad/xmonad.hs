import Control.Monad (filterM, when)
import Data.Aeson (FromJSON (parseJSON), decodeFileStrict, defaultOptions, fieldLabelModifier, genericParseJSON)
import Data.Char (toLower)
import Data.Foldable (for_)
import Data.Map qualified as M
import Data.Maybe (listToMaybe)
import Data.Ratio ((%))
import Foreign.C.String (castCharToCChar)
import GHC.Generics (Generic)
import GHC.Internal.IO.Handle.Types qualified
import Graphics.X11.Xlib (internAtom, mod4Mask)
import Graphics.X11.Xlib.Extras
  ( changeProperty8,
    propModeReplace,
  )
import System.Directory (getHomeDirectory)
import System.Environment (lookupEnv)
import System.Exit (exitFailure, exitSuccess)
import System.FilePath ((</>))
import System.IO (hPutStrLn, stderr)
import XMonad
import XMonad.Actions.DynamicWorkspaceGroups
import XMonad.Actions.DynamicWorkspaces (withNthWorkspace)
import XMonad.Actions.GridSelect (goToSelected)
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.Plane
import XMonad.Actions.Promote (promote)
import XMonad.Actions.SpawnOn
  ( manageSpawn,
    shellPromptHere,
    spawnHere,
  )
import XMonad.Actions.TopicSpace
import XMonad.Hooks.DynamicHooks (dynamicMasterHook)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
  ( ToggleStruts (ToggleStruts),
    avoidStruts,
    docks,
    manageDocks,
  )
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.HintedTile qualified as H
import XMonad.Layout.LayoutScreens (layoutScreens)
import XMonad.Layout.NoBorders
  ( hasBorder,
    noBorders,
    smartBorders,
  )
import XMonad.Layout.PerWorkspace (onWorkspaces)
import XMonad.Layout.Renamed (named)
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.TwoPane (TwoPane (TwoPane))
import XMonad.Layout.WorkspaceDir (changeDir, workspaceDir)
import XMonad.Prompt
import XMonad.Prompt.Workspace (workspacePrompt)
import XMonad.StackSet as W hiding (workspaces)
import XMonad.Util.Dzen (dzenWithArgs, seconds)
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SessionStart (doOnce, setSessionStarted)
import XMonad.Util.WorkspaceCompare
  ( filterOutWs,
    getSortByXineramaPhysicalRule,
  )

data Env = Env
  { envFont :: String,
    envPromptHeight :: Int,
    envTabsHeight :: Int,
    envHiRes :: Bool,
    envMainWsGroup :: [String]
  }
  deriving (Show, Generic)

dropEnvPrefix :: String -> String
dropEnvPrefix ('e' : 'n' : 'v' : c : cs) = toLower c : cs
dropEnvPrefix name = name

instance FromJSON Env where
  parseJSON =
    genericParseJSON
      defaultOptions
        { fieldLabelModifier = dropEnvPrefix
        }

loadEnv :: IO Env
loadEnv = do
  home <- getHomeDirectory
  let config = home </> ".config/xmonad.json"
  m <- decodeFileStrict config
  case m of
    Nothing -> do
      hPutStrLn stderr "Invalid JSON in config.json"
      exitFailure
    Just cfg -> pure cfg

main :: IO ()
main = do
  checkTopicConfig myTopicNames myTopicConfig
  env <- loadEnv
  xmproc <- spawnPipe $ "bash ~/.xmonad/panels_wrapper.sh"
  xmonad
    . withUrgencyHookC (myDzenUrgencyHook env) def {remindWhen = Every 2}
    . withUrgencyHook myBlinkUrgencyHook
    $ myConf env xmproc

golden :: Rational
golden = toRational (((sqrt 5) - 1) / 2)

tall :: Rational -> Int -> ResizableTall a
tall ratio numMaster = ResizableTall numMaster delta ratio []
  where
    delta = (3 / 100)

myTall r n =
  named "tall" $
    tall r n

myWide r n =
  named "wide"
    . Mirror
    $ tall r n

myFull env =
  named "full"
    . noBorders
    . tabbedBottom shrinkText
    $ tabTheme env

defaultSet env r n =
  myTall r n
    ||| myWide r n
    ||| myFull env

defaultWSet env r n =
  myFull env
    ||| myTall r n
    ||| myWide r n

fullscreenPreferredSpaces = ["c1", "c2", "c3", "web1", "web2", "mail"]

-- FIXME dynamically create workspacedirs from topics configuration
myLayoutHook env =
  workspaceDir "~"
    . avoidStruts
    . smartBorders
    . ( onWorkspaces fullscreenPreferredSpaces $
          defaultWSet env golden 1
      )
    $ defaultSet env golden 1

toggleStrutsOn :: [WorkspaceId] -> X ()
toggleStrutsOn wss = do
  cur <- gets (W.currentTag . windowset)
  mapM_ (\ws -> windows (W.view ws) >> sendMessage ToggleStruts) wss
  windows (W.view cur)

iconDir :: Env -> String
iconDir env = case envHiRes env of
  False -> "/home/komar/.xmonad/dzen2_img_small/"
  True -> "/home/komar/.xmonad/dzen2_img_large/"

wrapSpace :: String -> String
wrapSpace = wrap "^p(8)" "^p(1)"

preIcon :: Env -> String -> String -> String
preIcon env i = wrap ("^i(" ++ iconDir env ++ i ++ ")") "^p(1)"

layoutNameToIcon :: Env -> String -> String
layoutNameToIcon env n = "^i(" ++ iconDir env ++ "lay" ++ n ++ ".xbm)"

myLogHook :: Env -> GHC.Internal.IO.Handle.Types.Handle -> X ()
myLogHook env pipe =
  dynamicLogWithPP $
    dzenPP
      { ppSort = fmap (. filterOutWs [scratchpadWorkspaceTag]) $ wsSorter,
        ppOutput = hPutStrLn pipe,
        ppTitle = dzenColor "#5d728d" "" . shorten 100,
        ppCurrent = dzenColor "#719e4b" "#333333" . preIcon env "dcur.xbm",
        ppUrgent = dzenColor "#a53333" "" . preIcon env "durg.xbm" . dzenColor "#666666" "" . dzenStrip,
        ppVisible = dzenColor "#719e4b" "#252525" . preIcon env "dvis.xbm",
        ppHidden = dzenColor "#444444" "" . wrapSpace,
        ppWsSep = "^p(2)",
        ppSep = dzenColor "#aaaaaa" "" "^p(3)|^p(3)",
        ppLayout = dzenColor "#c0712c" "" . layoutNameToIcon env
      }
  where
    wsSorter = getSortByXineramaPhysicalRule horizontalScreenOrderer

scratchpads :: [NamedScratchpad]
scratchpads =
  [ NS
      "scratchpad"
      "~/.xmonad/terminal.sh scratchpad tmux new-session -A -s scratch"
      (resource =? "scratchpad")
      (terminalFloating 0 0.5 1 0.5),
    NS
      "wiremix"
      ("TERMINAL_PADDING=y ~/.xmonad/terminal.sh scratchmixer " ++ "wiremix")
      (resource =? "scratchmixer")
      (terminalFloating 0.15 0.08 0.7 0.3),
    NS
      "bc"
      "~/.xmonad/terminal.sh bc tmux new-session -A -s bc ~/.tmux/bin/spawn_shell.sh bc"
      (resource =? "bc")
      (terminalFloating 0.67 0.2 0.3 0.6),
    NS
      "notepad"
      "~/.xmonad/terminal.sh notepad ~/.xmonad/notepad.sh"
      (resource =? "notepad")
      (terminalFloating 0.3 0.2 0.4 0.6)
  ]
  where
    terminalFloating x y w h =
      ( do
          hasBorder False
          customFloating $ W.RationalRect x y w h
      )

shiftIfNoMatch :: WorkspaceId -> XMonad.Query Bool -> ManageHook
shiftIfNoMatch ws q = do
  newWin <- ask
  noExistingMatches <- liftX $ withWindowSet $ \s -> do
    let otherWindows = Prelude.filter (/= newWin) (W.allWindows s)
    matches <- filterM (runQuery q) otherWindows
    pure (null matches)

  if noExistingMatches
    then doF (W.shift ws)
    else idHook

shiftFirstWindowTo :: WorkspaceId -> XMonad.Query Bool -> ManageHook
shiftFirstWindowTo ws query = query --> shiftIfNoMatch ws query

myScratchpadManageHook :: ManageHook
myScratchpadManageHook = namedScratchpadManageHook scratchpads

myManageHook :: ManageHook
myManageHook = myScratchpadManageHook <+> manageDocks <+> myConditions <+> manageHook def

myConditions :: ManageHook
myConditions =
  composeAll
    [ shiftFirstWindowTo "mail" $ className =? "thunderbird",
      shiftFirstWindowTo "web1" $ className =? "firefox",
      isFullscreen --> doFullFloat
    ]

tabTheme :: Env -> Theme
tabTheme env =
  def
    { fontName = "xft:" ++ (envFont env),
      activeColor = "#111111",
      inactiveColor = "#000000",
      urgentColor = "#222222",
      activeBorderColor = "#5d728d",
      inactiveBorderColor = "#5d728d",
      urgentBorderColor = "#dd0000",
      activeTextColor = "#c4a000",
      inactiveTextColor = "#aaaaaa",
      urgentTextColor = "#dd0000",
      decoHeight = fromIntegral $ envTabsHeight env
    }

data TopicItem = TI
  { topicName :: Topic, -- (22b)
    topicDir :: Dir,
    topicAction :: X ()
  }

myTopics :: [Main.TopicItem]
myTopics =
  [ ti "NSP" "~",
    ti "c1" "~",
    ti "d1" "~",
    ti "c2" "~",
    ti "d2" "~",
    ti "c3" "~",
    ti "d3" "~",
    ti "sys1" "~",
    ti "ds1" "~",
    ti "sys2" "~",
    ti "ds2" "~",
    Main.TI "web1" "~" (spawnHere "firefox"),
    Main.TI "web2" "~" (spawnHere "firefox"),
    Main.TI "mail" "~" (spawnHere "thunderbird"),
    ti "vm1" "~",
    ti "vm2" "~"
  ]
  where
    ti t d = Main.TI t d shell
    shell = spawnHere "~/.xmonad/terminal.sh terminal tmux new-session -A -s 0"

myTopicNames :: [Topic]
myTopicNames = map topicName myTopics

myTopicConfig :: TopicConfig
myTopicConfig =
  def
    { topicDirs = M.fromList $ map (\(Main.TI n d _) -> (n, d)) myTopics,
      defaultTopicAction = const (return ()),
      defaultTopic = "web1",
      topicActions = M.fromList $ map (\(Main.TI n _ a) -> (n, a)) myTopics
    }

setWs :: String -> X ()
setWs ws = do
  windows (W.view ws)

setXProperty :: String -> String -> X ()
setXProperty property value = withDisplay $ \d -> do
  root <- asks theRoot
  propertyAtom <- atom d property
  typeAtom <- atom d "STRING"
  io
    . changeProperty8 d root propertyAtom typeAtom propModeReplace
    $ map castCharToCChar value
  where
    atom d value = io $ internAtom d value False

addPhysicalWSGroup :: ScreenComparator -> WSGroupId -> [WorkspaceId] -> X ()
addPhysicalWSGroup cmp name wids = do
  msids <- mapM (getScreen cmp . P) [0 .. length wids - 1]
  for_ (sequence msids) $ \sids ->
    addRawWSGroup name (zip sids wids)

myStartupHook :: Env -> X ()
myStartupHook env =
  doOnce
    ( toggleStrutsOn ["c1", "c2", "c3"]
        <+> setWs "web1"
        <+> addPhysicalWSGroup def "w" (envMainWsGroup env)
        <+> viewWSGroup "w"
    )
    <+> setSessionStarted
    <+> setXProperty "__XMONAD_STARTUP_DONE__" "1"

myConf env xmproc =
  docks $
    def
      { startupHook = myStartupHook env,
        manageHook = manageSpawn <+> myManageHook <+> dynamicMasterHook,
        layoutHook = myLayoutHook env,
        logHook = myLogHook env xmproc,
        focusFollowsMouse = False,
        modMask = mod4Mask,
        normalBorderColor = "#000000",
        focusedBorderColor = "#3465a4",
        terminal = "~/.xmonad/terminal.sh terminal",
        workspaces = myTopicNames,
        clickJustFocuses = True
      }
      `additionalKeysP` (myKeys env)

data MyDzenUrgencyHook = MyDzenUrgencyHook
  { duration :: Int,
    args :: [String]
  }
  deriving (Read, Show)

instance UrgencyHook MyDzenUrgencyHook where
  urgencyHook :: MyDzenUrgencyHook -> Window -> X ()
  urgencyHook MyDzenUrgencyHook {Main.duration = d, Main.args = a} w = do
    name <- getName w
    ws <- gets windowset
    whenJust (W.findTag w ws) (flash name)
    where
      flash name index =
        dzenWithArgs (dzenColor "#a53333" "" index ++ dzenColor "#444444" "" ": " ++ dzenColor "#5d728d" "" (show name)) a d

myDzenUrgencyHook :: Env -> MyDzenUrgencyHook
myDzenUrgencyHook env =
  MyDzenUrgencyHook
    { Main.duration = seconds 1,
      Main.args =
        [ "-bg",
          "black",
          "-xs",
          "2",
          "-ta",
          "r",
          "-fn",
          envFont env,
          "-x",
          "830"
        ]
    }

myBlinkUrgencyHook :: SpawnUrgencyHook
myBlinkUrgencyHook = SpawnUrgencyHook "~/.xmonad/blink.sh "

workspaceKeys :: [String]
workspaceKeys =
  [ "",
    "M-1",
    "M-<F1>",
    "M-2",
    "M-<F2>",
    "M-3",
    "M-<F3>",
    "M-4",
    "M-<F4>",
    "M-5",
    "M-<F5>",
    "M-6",
    "M-7",
    "M-u",
    "M-<F9>",
    "M-<F10>"
  ]

workspaceSKeys :: [String]
workspaceSKeys = map ("S-" ++) workspaceKeys

-- Workaround for toggle + scratchpad
myToggle :: X ()
myToggle =
  windows $
    W.view =<< W.tag . head . Prelude.filter ((\x -> x /= "NSP" && x /= "SP") . W.tag) . W.hidden

currentPhysicalScreen :: ScreenComparator -> X (Maybe PhysicalScreen)
currentPhysicalScreen sc = do
  curSid <- gets (W.screen . W.current . windowset)
  n <- gets (length . W.screens . windowset)
  let ps = map P [0 .. n - 1]
  matches <-
    filterM
      (\p -> fmap (== Just curSid) (getScreen sc p))
      ps
  pure (listToMaybe matches)

keepCurrentScreen :: X () -> X ()
keepCurrentScreen action = do
  mp <- currentPhysicalScreen def
  action
  mapM_ (viewScreen def) mp

xpconfig :: Env -> XPConfig
xpconfig env =
  def
    { font = envFont env,
      bgColor = "#000000",
      fgColor = "#aaaaaa",
      bgHLight = "#cccccc",
      fgHLight = "#000000",
      promptBorderWidth = 0,
      height = fromIntegral $ envPromptHeight env
    }

whenSingleScreen :: X () -> X ()
whenSingleScreen action = do
  n <- gets (length . W.screens . windowset)
  when (n == 1) action

myKeys :: Env -> [(String, X ())]
myKeys env =
  [ ("M-m", spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi"),
    ("M-S-m", io exitSuccess),
    ("M-q", viewScreen def 0),
    ("M-w", viewScreen def 1),
    ("M-e", viewScreen def 2),
    ("M-S-q", sendToScreen def 0),
    ("M-S-w", sendToScreen def 1),
    ("M-S-e", sendToScreen def 2),
    ("M-`", workspacePrompt xpconfig' (windows . W.view)),
    ("M-S-`", workspacePrompt xpconfig' (windows . W.shift)),
    ("M-p", shellPromptHere xpconfig'),
    ("M-s", namedScratchpadAction scratchpads "scratchpad"),
    ("M-a", namedScratchpadAction scratchpads "wiremix"),
    ("M-x", namedScratchpadAction scratchpads "bc"),
    ("M-c", namedScratchpadAction scratchpads "notepad"),
    ("M-d", changeDir xpconfig'),
    ("M-;", sendMessage MirrorShrink),
    ("M-'", sendMessage MirrorExpand),
    ("M-<Esc>", goToSelected def),
    ("M-<Return>", promote),
    ("M-b", sendMessage ToggleStruts),
    ("M-g n", promptWSGroupAdd xpconfig' "name group: "),
    ("M-g g", promptWSGroupView' xpconfig' "go to group: "),
    ("M-g d", promptWSGroupForget xpconfig' "drop group: "),
    ("M-f", whenSingleScreen $ layoutScreens 2 (TwoPane 0.5 0.5)),
    ("M-S-f", whenSingleScreen $ layoutScreens 2 (Mirror (TwoPane 0.5 0.5))),
    ("M-v", rescreen),
    ( "M-S-<Backspace>",
      do
        focusUrgent
        spawnHere "~/.xmonad/noblink.sh"
    ),
    ("M-S-<Return>", currentTopicAction myTopicConfig),
    ("M-S-C-<Return>", spawnHere "FSHF_REMOTE_CMD='tmux a || exec \"$SHELL\"' ~/.xmonad/terminal.sh terminal fshf"),
    ("M-<Backspace>", myToggle)
  ]
    ++ [(sc, withNthWorkspace W.greedyView n) | (sc, n) <- zip workspaceKeys [0 ..]]
    ++ [(sc, withNthWorkspace W.shift n) | (sc, n) <- zip workspaceSKeys [0 ..]]
    ++ [ (mod ++ sc, func (Lines 1) Linear dir)
       | (sc, dir) <- [("[", ToLeft), ("]", ToRight)],
         (mod, func) <- [("M-", planeMove), ("M-S-", planeShift)]
       ]
  where
    xpconfig' = xpconfig env
    promptWSGroupView' xp label = keepCurrentScreen (promptWSGroupView xp label)
