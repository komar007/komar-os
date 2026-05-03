module XMonadConfig.Manage
  ( myManageHook,
  )
where

import XMonad
  ( Default (def),
    ManageHook,
    XConfig (manageHook),
    className,
    composeAll,
    (-->),
    (<+>),
    (=?),
  )
import XMonad.Core
import XMonad.Hooks.ManageDocks (manageDocks)
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Util.NamedScratchpad (namedScratchpadManageHook)
import XMonadConfig.Scratchpads (scratchpads)
import XMonadConfig.Utils (shiftIfNoMatch)

myManageHook :: ManageHook
myManageHook =
  namedScratchpadManageHook scratchpads
    <+> manageDocks
    <+> myConditions
    <+> manageHook def

myConditions :: ManageHook
myConditions =
  composeAll
    [ shiftFirstWindowTo "mail" $ className =? "thunderbird",
      shiftFirstWindowTo "web1" $ className =? "firefox",
      isFullscreen --> doFullFloat
    ]

shiftFirstWindowTo :: WorkspaceId -> Query Bool -> ManageHook
shiftFirstWindowTo ws query = query --> shiftIfNoMatch ws query
