import System.IO
import System.Exit (exitSuccess)
import System.Environment (lookupEnv)
import System.Directory (getHomeDirectory)
import System.FilePath ((</>))
import qualified Data.Map as M
import Data.Ratio ((%))
import Data.Foldable (for_)
import Data.Maybe (listToMaybe)
import Foreign.C.String (castCharToCChar)
import Graphics.X11.Xlib
import Graphics.X11.Xlib.Extras
import Control.Monad (filterM, when)
import XMonad
import XMonad.ManageHook
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.DynamicHooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.XSelection
import XMonad.Util.Loggers
import XMonad.Util.SessionStart (doOnce, setSessionStarted)
import XMonad.StackSet as W hiding(layout, workspaces)
import XMonad.Layout.NoBorders
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.Renamed
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Gaps
import XMonad.Layout.IM
import XMonad.Layout.Grid
import XMonad.Layout.Reflect
import XMonad.Layout.Tabbed
import XMonad.Layout.MagicFocus
import XMonad.Layout.SimplestFloat
import XMonad.Layout.LayoutScreens
import XMonad.Layout.TwoPane
import qualified XMonad.Layout.HintedTile as H
import qualified XMonad.Layout.ResizableTile as R
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Workspace
import XMonad.Actions.Search
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.Plane
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.WindowBringer
import XMonad.Actions.GridSelect
import XMonad.Actions.Promote
import XMonad.Actions.NoBorders
import XMonad.Actions.CycleWS
import XMonad.Actions.SpawnOn
import XMonad.Actions.TopicSpace
import XMonad.Actions.DynamicWorkspaceGroups
-- for MyDzenUrgencyHook
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Dzen (dzenWithArgs, seconds)
import XMonad.Util.WorkspaceCompare

import XMonad.Prompt.Input

import GHC.Generics (Generic)
import Data.Aeson (FromJSON(parseJSON), decodeFileStrict, defaultOptions, genericParseJSON, fieldLabelModifier)
import Data.Char (toLower)
import System.IO (hPutStrLn, stderr)
import System.Exit (exitFailure)

data Env = Env
    { envFont         :: String
    , envPromptHeight :: Int
    , envTabsHeight   :: Int
    , envHiRes        :: Bool
    , envMainWsGroup  :: [String]
    } deriving (Show, Generic)

dropEnvPrefix :: String -> String
dropEnvPrefix ('e':'n':'v':c:cs) = toLower c : cs
dropEnvPrefix name = name

instance FromJSON Env where
    parseJSON = genericParseJSON defaultOptions
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

main = do
    checkTopicConfig myTopicNames myTopicConfig
    env <- loadEnv
    xmproc <- spawnPipe $ "bash ~/.xmonad/panels_wrapper.sh"
    xmonad
        $ withUrgencyHookC myDzenUrgencyHook def {remindWhen = Every 2}
        $ withUrgencyHook myBlinkUrgencyHook
        $ myConf env xmproc

golden = toRational (((sqrt 5) - 1)/2)

tall ratio numMaster = R.ResizableTall numMaster delta ratio []
    where delta = (3/100)

myTall r n = named "tall" $ tall r n
myWide r n = named "wide" $ Mirror $ tall r n
myFull env = named "full" $ noBorders (tabbedBottom shrinkText (tabTheme env))

defaultSet env r n =
    myTall r n ||| myWide r n ||| (myFull env)
defaultWSet env r n =
    myFull env ||| myTall r n ||| myWide r n

fullscreenPreferredSpaces = ["c1", "c2", "c3", "web1", "web2", "mail"]

-- FIXME dynamically create workspacedirs from topics configuration
myLayoutHook env =
    workspaceDir "~" $
    smartBorders $
    (onWorkspaces fullscreenPreferredSpaces $ avoidStruts $ defaultWSet env golden 1) $
    (avoidStruts $ defaultSet env golden 1)

toggleStrutsOn :: [WorkspaceId] -> X ()
toggleStrutsOn wss = do
    cur <- gets (W.currentTag . windowset)
    mapM_ (\ws -> windows (W.view ws) >> sendMessage ToggleStruts) wss
    windows (W.view cur)

iconDir env = case envHiRes env of
                False -> "/home/komar/.xmonad/dzen2_img_small/"
                True -> "/home/komar/.xmonad/dzen2_img_large/"

wrapSpace = wrap "^p(8)" "^p(1)"
preIcon env i = wrap ("^i(" ++ iconDir env ++ i ++ ")") "^p(1)"
layoutNameToIcon env n = "^i(" ++ iconDir env ++ "lay" ++ n ++ ".xbm)"

myLogHook env pipe = dynamicLogWithPP $ dzenPP {
    ppSort    = fmap (.filterOutWs [scratchpadWorkspaceTag]) $ wsSorter,
    ppOutput  = hPutStrLn pipe,
    ppTitle   = dzenColor "#5d728d" "" . shorten 100,
    ppCurrent = dzenColor "#719e4b" "#333333" . preIcon env "dcur.xbm",
    ppUrgent  = dzenColor "#a53333" "" . preIcon env "durg.xbm" . dzenColor "#666666" "" . dzenStrip,
    ppVisible = dzenColor "#719e4b" "#252525" . preIcon env "dvis.xbm",
    ppHidden  = dzenColor "#444444" "" . wrapSpace,
    ppWsSep   = "^p(2)",
    ppSep     = dzenColor "#aaaaaa" "" "^p(3)|^p(3)",
    ppLayout  = dzenColor "#c0712c" "" . layoutNameToIcon env
} where
    wsSorter = getSortByXineramaPhysicalRule horizontalScreenOrderer

scratchpads = [
    NS "scratchpad"     "~/.xmonad/terminal.sh scratchpad tmux new-session -A -s scratch"
        (resource =? "scratchpad")   (terminalFloating 0 0.5 1 0.5),
    NS "wiremix" ("TERMINAL_PADDING=y ~/.xmonad/terminal.sh scratchmixer " ++ "wiremix")
        (resource =? "scratchmixer") (terminalFloating 0.15 0.08 0.7 0.3),
    NS "bc"        "~/.xmonad/terminal.sh bc tmux new-session -A -s bc ~/.tmux/bin/spawn_shell.sh bc"
        (resource =? "bc")           (terminalFloating 0.67 0.2 0.3 0.6),
    NS "notepad"   "~/.xmonad/terminal.sh notepad ~/.xmonad/notepad.sh"
        (resource =? "notepad")      (terminalFloating 0.3 0.2 0.4 0.6)]
    where terminalFloating x y w h = (do
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

myScratchpadManageHook = namedScratchpadManageHook scratchpads
myManageHook = myScratchpadManageHook <+> manageDocks <+> myConditions <+> manageHook def
myConditions = composeAll [
    shiftFirstWindowTo "mail" $ className =? "thunderbird",
    shiftFirstWindowTo "web1" $ className =? "firefox",
    isFullscreen --> doFullFloat]

tabTheme env = def {
    fontName             = envFont env,
    activeColor          = "#111111",
    inactiveColor        = "#000000",
    urgentColor          = "#222222",
    activeBorderColor    = "#5d728d",
    inactiveBorderColor  = "#5d728d",
    urgentBorderColor    = "#dd0000",
    activeTextColor      = "#c4a000",
    inactiveTextColor    = "#aaaaaa",
    urgentTextColor      = "#dd0000",
    decoHeight           = fromIntegral $ envTabsHeight env
}

data TopicItem = TI { topicName :: Topic   -- (22b)
                    , topicDir  :: Dir
                    , topicAction :: X ()
                    }

myTopics :: [Main.TopicItem]
myTopics =
    [ ti "NSP"   "~"
    , ti "c1"    "~"
    , ti "d1"    "~"
    , ti "c2"    "~"
    , ti "d2"    "~"
    , ti "c3"    "~"
    , ti "d3"    "~"
    , ti "sys1"  "~"
    , ti "ds1"   "~"
    , ti "sys2"  "~"
    , ti "ds2"   "~"
    , Main.TI "web1" "~" (spawnHere "firefox")
    , Main.TI "web2" "~" (spawnHere "firefox")
    , Main.TI "mail" "~" (spawnHere "thunderbird")
    , ti "vm1"  "~"
    , ti "vm2"  "~"
    ]
    where
        ti t d = Main.TI t d shell
        shell = spawnHere "~/.xmonad/terminal.sh terminal tmux new-session -A -s 0"

myTopicNames :: [Topic]
myTopicNames = map topicName myTopics

myTopicConfig :: TopicConfig
myTopicConfig = def
    { topicDirs = M.fromList $ map (\(Main.TI n d _) -> (n,d)) myTopics
    , defaultTopicAction = const (return ())
    , defaultTopic = "web1"
    , topicActions = M.fromList $ map (\(Main.TI n _ a) -> (n,a)) myTopics
    }

setWs :: String -> X ()
setWs ws = do
    windows (W.view ws)

setXProperty :: String -> String -> X ()
setXProperty property value = withDisplay $ \d -> do
    root <- asks theRoot
    propertyAtom <- atom d property
    typeAtom <- atom d "STRING"
    io $ changeProperty8 d root propertyAtom typeAtom propModeReplace $ map castCharToCChar value
    where
        atom d value = io $ internAtom d value False

addPhysicalWSGroup :: ScreenComparator -> WSGroupId -> [WorkspaceId] -> X ()
addPhysicalWSGroup cmp name wids = do
    msids <- mapM (getScreen cmp . P) [0 .. length wids - 1]
    for_ (sequence msids) $ \sids ->
        addRawWSGroup name (zip sids wids)

sessionStartupHook env = toggleStrutsOn ["c1", "c2", "c3"] <+>
                         -- pre-set last workspace
                         setWs "web1" <+>
                         -- set starting workspace
                         addPhysicalWSGroup def "w" (envMainWsGroup env) <+>
                         viewWSGroup "w"

myConf env xmproc =
    docks $
    def {
        startupHook =
            setWMName "LG3D" <+>
            doOnce (sessionStartupHook env) <+>
            setSessionStarted <+>
            setXProperty "__XMONAD_STARTUP_DONE__" "1",
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
} `additionalKeysP` (myKeys env xmproc)

data MyDzenUrgencyHook = MyDzenUrgencyHook {
                             duration :: Int,
                             args :: [String]
                         }
    deriving (Read, Show)

instance UrgencyHook MyDzenUrgencyHook where
    urgencyHook MyDzenUrgencyHook { Main.duration = d, Main.args = a } w = do
        name <- getName w
        ws <- gets windowset
        whenJust (W.findTag w ws) (flash name)
      where flash name index =
                  dzenWithArgs (dzenColor "#a53333" "" index ++ dzenColor "#444444" "" ": " ++ dzenColor "#5d728d" "" (show name)) a d

myDzenUrgencyHook :: MyDzenUrgencyHook
myDzenUrgencyHook = MyDzenUrgencyHook {Main.duration = seconds 1, Main.args = [
    "-bg", "black",
    "-xs", "2",
    "-ta", "r",
    "-fn", "-misc-fixed-*-*-*-*-10-*-*-*-*-*-*-*",
    "-x", "830"
]}

myBlinkUrgencyHook :: SpawnUrgencyHook
myBlinkUrgencyHook = SpawnUrgencyHook "~/.xmonad/blink.sh "

workspaceKeys = ["", "M-1", "M-<F1>", "M-2", "M-<F2>", "M-3", "M-<F3>", "M-4", "M-<F4>", "M-5", "M-<F5>",
    "M-6", "M-7", "M-u", "M-<F9>", "M-<F10>"]
workspaceSKeys = map ("S-"++) workspaceKeys

-- Workaround for toggle + scratchpad
myToggle = windows $ W.view =<< W.tag . head . Prelude.filter ((\x -> x /= "NSP" && x /= "SP") . W.tag) . W.hidden

currentPhysicalScreen :: ScreenComparator -> X (Maybe PhysicalScreen)
currentPhysicalScreen sc = do
    curSid <- gets (W.screen . W.current . windowset)
    n      <- gets (length . W.screens . windowset)
    let ps = map P [0 .. n - 1]
    matches <- filterM
        (\p -> fmap (== Just curSid) (getScreen sc p))
        ps
    pure (listToMaybe matches)

keepCurrentScreen :: X () -> X ()
keepCurrentScreen action = do
    mp <- currentPhysicalScreen def
    action
    mapM_ (viewScreen def) mp

xpconfig env = def {
    font        = envFont env,
    bgColor     = "#000000",
    fgColor     = "#aaaaaa",
    bgHLight    = "#cccccc",
    fgHLight    = "#000000",
    promptBorderWidth = 0,
    height = fromIntegral $ envPromptHeight env
}

whenSingleScreen :: X () -> X ()
whenSingleScreen action = do
    n <- gets (length . W.screens . windowset)
    when (n == 1) action

myKeys env xmproc = [
    ("M-m",               spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi"),
    ("M-S-m",             io exitSuccess),
    ("M-q",               viewScreen def 0),
    ("M-w",               viewScreen def 1),
    ("M-e",               viewScreen def 2),
    ("M-S-q",             sendToScreen def 0),
    ("M-S-w",             sendToScreen def 1),
    ("M-S-e",             sendToScreen def 2),
    ("M-`",               workspacePrompt xpconfig' (windows . W.view)),
    ("M-S-`",             workspacePrompt xpconfig' (windows . W.shift)),
    ("M-p",               shellPromptHere xpconfig'),
    ("M-s",               namedScratchpadAction scratchpads "scratchpad"),
    ("M-a",               namedScratchpadAction scratchpads "wiremix"),
    ("M-x",               namedScratchpadAction scratchpads "bc"),
    ("M-c",               namedScratchpadAction scratchpads "notepad"),
    ("M-d",               changeDir xpconfig'),
    ("M-;",               sendMessage R.MirrorShrink),
    ("M-'",               sendMessage R.MirrorExpand),
    ("M-<Esc>",           goToSelected def),
    ("M-<Return>",        promote),
    ("M-b",               sendMessage ToggleStruts),
    ("M-g n",             promptWSGroupAdd xpconfig' "name group: "),
    ("M-g g",             promptWSGroupView' xpconfig' "go to group: "),
    ("M-g d",             promptWSGroupForget xpconfig' "drop group: "),
    ("M-f",               whenSingleScreen $ layoutScreens 2 (TwoPane 0.5 0.5)),
    ("M-S-f",             whenSingleScreen $ layoutScreens 2 (Mirror (TwoPane 0.5 0.5))),
    ("M-v",               rescreen),
    ("M-S-<Backspace>",   do
                              focusUrgent
                              spawnHere "~/.xmonad/noblink.sh"
                              ),
    ("M-S-<Return>",      currentTopicAction myTopicConfig),
    ("M-S-C-<Return>",    spawnHere "FSHF_REMOTE_CMD='tmux a || exec \"$SHELL\"' ~/.xmonad/terminal.sh terminal fshf"),
    ("M-<Backspace>",     myToggle)]
    ++
    [(sc, withNthWorkspace W.greedyView n) | (sc, n) <- zip workspaceKeys [0..]]
    ++
    [(sc, withNthWorkspace W.shift n) | (sc, n) <- zip  workspaceSKeys [0..]]
    ++
    [(mod ++ sc, func (Lines 1) Linear dir) |
        (sc, dir) <- [("[", ToLeft), ("]", ToRight)],
        (mod, func) <- [("M-", planeMove), ("M-S-", planeShift)]]
    where xpconfig' = xpconfig env
          promptWSGroupView' xp label = keepCurrentScreen (promptWSGroupView xp label)
