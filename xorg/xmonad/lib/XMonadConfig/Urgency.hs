module XMonadConfig.Urgency
  ( myDzenUrgencyHook,
    myBlinkUrgencyHook,
  )
where

import XMonad (Window, X, XState (windowset), gets, whenJust)
import XMonad.Hooks.DynamicLog (dzenColor)
import XMonad.Hooks.UrgencyHook
  ( SpawnUrgencyHook (..),
    UrgencyHook (..),
    seconds,
  )
import XMonad.StackSet qualified as W
import XMonad.Util.Dzen (dzenWithArgs, seconds)
import XMonad.Util.NamedWindows (getName)
import XMonadConfig.Env (Env, dzenFont)

data MyDzenUrgencyHook = MyDzenUrgencyHook
  { hookDuration :: Int,
    hookArgs :: [String]
  }
  deriving (Read, Show)

instance UrgencyHook MyDzenUrgencyHook where
  urgencyHook :: MyDzenUrgencyHook -> Window -> X ()
  urgencyHook MyDzenUrgencyHook {hookDuration, hookArgs} w = do
    name <- getName w
    ws <- gets windowset
    whenJust (W.findTag w ws) (flash name)
    where
      flash name index =
        dzenWithArgs
          ( dzenColor "#a53333" "" index
              ++ dzenColor "#444444" "" ": "
              ++ dzenColor "#5d728d" "" (show name)
          )
          hookArgs
          hookDuration

myDzenUrgencyHook :: Env -> MyDzenUrgencyHook
myDzenUrgencyHook env =
  MyDzenUrgencyHook
    { hookDuration = seconds 5,
      hookArgs =
        [ "-bg",
          "black",
          "-xs",
          "2",
          "-ta",
          "r",
          "-fn",
          dzenFont env,
          "-x",
          "-1000"
        ]
    }

myBlinkUrgencyHook :: SpawnUrgencyHook
myBlinkUrgencyHook = SpawnUrgencyHook "~/.xmonad/blink.sh "
