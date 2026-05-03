module XMonadConfig.Startup
  ( myStartupHook,
  )
where

import Data.Foldable (for_)
import XMonad (Default (def), WorkspaceId, X, windows, (<+>))
import XMonad.Actions.DynamicWorkspaceGroups
  ( WSGroupId,
    addRawWSGroup,
    viewWSGroup,
  )
import XMonad.Actions.PhysicalScreens
  ( PhysicalScreen (P),
    ScreenComparator,
    getScreen,
  )
import XMonad.StackSet qualified as W
import XMonad.Util.SessionStart (doOnce, setSessionStarted)
import XMonadConfig.Env (Cfg (cfgMainWsGroup), Env (cfg))
import XMonadConfig.Utils (setXProperty, toggleStrutsOn)

myStartupHook :: Env -> X ()
myStartupHook env =
  doOnce
    ( toggleStrutsOn ["c1", "c2", "c3"]
        <+> setWs "web1"
        <+> addPhysicalWSGroup def "w" (cfgMainWsGroup . cfg $ env)
        <+> viewWSGroup "w"
    )
    <+> setSessionStarted
    <+> setXProperty "__XMONAD_STARTUP_DONE__" "1"

addPhysicalWSGroup :: ScreenComparator -> WSGroupId -> [WorkspaceId] -> X ()
addPhysicalWSGroup cmp name wids = do
  msids <- mapM (getScreen cmp . P) [0 .. length wids - 1]
  for_ (sequence msids) $ \sids ->
    addRawWSGroup name (zip sids wids)

setWs :: WorkspaceId -> X ()
setWs ws = windows (W.view ws)
