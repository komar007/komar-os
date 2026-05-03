import Graphics.X11.Xlib (mod4Mask)
import XMonad
import XMonad.Actions.SpawnOn (manageSpawn)
import XMonad.Actions.TopicSpace (checkTopicConfig)
import XMonad.Hooks.DynamicHooks (dynamicMasterHook)
import XMonad.Hooks.ManageDocks (docks)
import XMonad.Hooks.UrgencyHook
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (spawnPipe)
import XMonadConfig.Env
import XMonadConfig.Keys
import XMonadConfig.Layouts
import XMonadConfig.Log
import XMonadConfig.Manage
import XMonadConfig.Startup
import XMonadConfig.Topics
import XMonadConfig.Urgency

main :: IO ()
main = do
  checkTopicConfig myTopicNames myTopicConfig
  env <- buildEnvironment
  xmproc <- spawnPipe $ "bash ~/.xmonad/panels_wrapper.sh"
  xmonad
    . withUrgencyHookC (myDzenUrgencyHook env) def {remindWhen = Every 2}
    . withUrgencyHook myBlinkUrgencyHook
    $ myConf env xmproc

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
