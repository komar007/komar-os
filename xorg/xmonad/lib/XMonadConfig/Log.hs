module XMonadConfig.Log
  ( myLogHook,
  )
where

import System.FilePath ((</>))
import System.IO (Handle, hPutStrLn)
import XMonad (X)
import XMonad.Actions.PhysicalScreens (horizontalScreenOrderer)
import XMonad.Hooks.DynamicLog
import XMonad.Util.NamedScratchpad (scratchpadWorkspaceTag)
import XMonad.Util.WorkspaceCompare (filterOutWs, getSortByXineramaPhysicalRule)
import XMonadConfig.Env (Cfg (cfgHiRes), Env (cfg, home))

myLogHook :: Env -> Handle -> X ()
myLogHook env pipe =
  dynamicLogWithPP $
    dzenPP
      { ppSort = fmap (. filterOutWs [scratchpadWorkspaceTag]) physicalSorter,
        ppOutput = hPutStrLn pipe,
        ppTitle = dzenColor "#5d728d" "" . shorten 100,
        ppCurrent = dzenColor "#719e4b" "#333333" . preIcon' "dcur.xbm",
        ppUrgent = dzenColor "#a53333" "" . preIcon' "durg.xbm" . dzenColor "#666666" "" . dzenStrip,
        ppVisible = dzenColor "#719e4b" "#252525" . preIcon' "dvis.xbm",
        ppHidden = dzenColor "#444444" "" . wrapSpace,
        ppWsSep = "^p(2)",
        ppSep = dzenColor "#aaaaaa" "" "^p(3)|^p(3)",
        ppLayout = dzenColor "#c0712c" "" . layoutIcon env
      }
  where
    physicalSorter = getSortByXineramaPhysicalRule horizontalScreenOrderer
    preIcon' = preIcon env

preIcon :: Env -> String -> String -> String
preIcon env i = wrap ("^i(" ++ iconDir env ++ i ++ ")") "^p(1)"

layoutIcon :: Env -> String -> String
layoutIcon env n = "^i(" ++ iconDir env ++ "lay" ++ n ++ ".xbm)"

iconDir :: Env -> String
iconDir env =
  home env </> case cfgHiRes . cfg $ env of
    False -> ".xmonad/dzen2_img_small/"
    True -> ".xmonad/dzen2_img_large/"

wrapSpace :: String -> String
wrapSpace = wrap "^p(8)" "^p(1)"
