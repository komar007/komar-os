module XMonadConfig.Keys
  ( myKeys,
  )
where

import System.Exit (exitSuccess)
import XMonad
import XMonad.Actions.DynamicWorkspaceGroups
import XMonad.Actions.DynamicWorkspaces (withNthWorkspace)
import XMonad.Actions.GridSelect (goToSelected)
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.Plane
import XMonad.Actions.Promote (promote)
import XMonad.Actions.SpawnOn
  ( shellPromptHere,
    spawnHere,
  )
import XMonad.Actions.TopicSpace (currentTopicAction)
import XMonad.Hooks.ManageDocks (ToggleStruts (ToggleStruts))
import XMonad.Hooks.UrgencyHook (focusUrgent)
import XMonad.Layout.LayoutScreens (layoutScreens)
import XMonad.Layout.ResizableTile
import XMonad.Layout.TwoPane (TwoPane (TwoPane))
import XMonad.Layout.WorkspaceDir (changeDir)
import XMonad.Prompt
import XMonad.Prompt.Workspace (workspacePrompt)
import XMonad.StackSet qualified as W
import XMonad.Util.NamedScratchpad (namedScratchpadAction)
import XMonadConfig.Env
import XMonadConfig.Scratchpads (scratchpads)
import XMonadConfig.Topics (myTopicConfig)
import XMonadConfig.Utils (keepCurrentScreen, toggleLastNonScratch, whenSingleScreen)

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
    ("M-<Backspace>", toggleLastNonScratch)
  ]
    ++ [(sc, withNthWorkspace W.greedyView n) | (sc, n) <- zip workspaceKeys [0 ..]]
    ++ [(sc, withNthWorkspace W.shift n) | (sc, n) <- zip workspaceSKeys [0 ..]]
    ++ [ (mods ++ sc, func (Lines 1) Linear dir)
       | (sc, dir) <- [("[", ToLeft), ("]", ToRight)],
         (mods, func) <- [("M-", planeMove), ("M-S-", planeShift)]
       ]
  where
    xpconfig' = xpconfig env
    promptWSGroupView' xp label = keepCurrentScreen (promptWSGroupView xp label)

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

xpconfig :: Env -> XPConfig
xpconfig env =
  def
    { font = xmonadFont env,
      bgColor = "#000000",
      fgColor = "#aaaaaa",
      bgHLight = "#cccccc",
      fgHLight = "#000000",
      promptBorderWidth = 0,
      height = fromIntegral $ cfgPromptHeight . cfg $ env
    }
