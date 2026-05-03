module XMonadConfig.Layouts
  ( myLayoutHook,
    tabTheme,
  )
where

import XMonad (Default (def), Mirror (Mirror), WorkspaceId, (|||))
import XMonad.Hooks.ManageDocks (avoidStruts)
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.PerWorkspace (onWorkspaces)
import XMonad.Layout.Renamed (named)
import XMonad.Layout.ResizableTile (ResizableTall (ResizableTall))
import XMonad.Layout.Tabbed
import XMonad.Layout.WorkspaceDir (workspaceDir)
import XMonadConfig.Env
  ( Cfg (cfgTabsHeight),
    Env (cfg),
    xmonadFont,
  )

myLayoutHook env =
  workspaceDir "~"
    . avoidStruts
    . smartBorders
    . (onWorkspaces fullscreenPreferredSpaces $ defaultWSet env golden 1)
    $ defaultSet env golden 1

fullscreenPreferredSpaces :: [WorkspaceId]
fullscreenPreferredSpaces = ["c1", "c2", "c3", "web1", "web2", "mail"]

defaultSet env r n =
  myTall r n
    ||| myWide r n
    ||| myFull env

defaultWSet env r n =
  myFull env
    ||| myTall r n
    ||| myWide r n

golden :: Rational
golden = toRational (((sqrt 5) - 1) / 2)

tall :: Rational -> Int -> ResizableTall a
tall ratio numMaster = ResizableTall numMaster delta ratio []
  where
    delta = 3 / 100

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

tabTheme :: Env -> Theme
tabTheme env =
  def
    { fontName = xmonadFont env,
      activeColor = "#111111",
      inactiveColor = "#000000",
      urgentColor = "#222222",
      activeBorderColor = "#5d728d",
      inactiveBorderColor = "#5d728d",
      urgentBorderColor = "#dd0000",
      activeTextColor = "#c4a000",
      inactiveTextColor = "#aaaaaa",
      urgentTextColor = "#dd0000",
      decoHeight = fromIntegral $ cfgTabsHeight . cfg $ env
    }
