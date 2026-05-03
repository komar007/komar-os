module XMonadConfig.Scratchpads (scratchpads) where

import XMonad (resource, (=?))
import XMonad.Layout.NoBorders (hasBorder)
import XMonad.StackSet qualified as W
import XMonad.Util.NamedScratchpad
  ( NamedScratchpad (NS),
    customFloating,
  )

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
    terminalFloating x y w h = do
      hasBorder False
      customFloating $ W.RationalRect x y w h
