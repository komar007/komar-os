module XMonadConfig.Utils
  ( toggleStrutsOn,
    keepCurrentScreen,
    whenSingleScreen,
    setXProperty,
    shiftIfNoMatch,
    toggleLastNonScratch,
  )
where

import Control.Monad (filterM, when)
import Data.Maybe (listToMaybe)
import Foreign.C.String (castCharToCChar)
import Graphics.X11.Xlib (internAtom)
import Graphics.X11.Xlib.Extras (changeProperty8, propModeReplace)
import XMonad
import XMonad.Actions.PhysicalScreens
  ( PhysicalScreen (..),
    ScreenComparator,
    getScreen,
    viewScreen,
  )
import XMonad.Hooks.ManageDocks (ToggleStruts (ToggleStruts))
import XMonad.StackSet qualified as W

toggleStrutsOn :: [WorkspaceId] -> X ()
toggleStrutsOn wss = do
  cur <- gets (W.currentTag . windowset)
  mapM_ (\ws -> windows (W.view ws) >> sendMessage ToggleStruts) wss
  windows (W.view cur)

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

whenSingleScreen :: X () -> X ()
whenSingleScreen action = do
  n <- gets (length . W.screens . windowset)
  when (n == 1) action

setXProperty :: String -> String -> X ()
setXProperty property value = withDisplay $ \d -> do
  root <- asks theRoot
  propertyAtom <- atom d property
  typeAtom <- atom d "STRING"
  io
    . changeProperty8 d root propertyAtom typeAtom propModeReplace
    $ map castCharToCChar value
  where
    atom d atomName = io $ internAtom d atomName False

shiftIfNoMatch :: WorkspaceId -> Query Bool -> ManageHook
shiftIfNoMatch ws q = do
  newWin <- ask
  noExistingMatches <- liftX $ withWindowSet $ \s -> do
    let otherWindows = filter (/= newWin) (W.allWindows s)
    matches <- filterM (runQuery q) otherWindows
    pure (null matches)
  if noExistingMatches
    then doF (W.shift ws)
    else idHook

toggleLastNonScratch :: X ()
toggleLastNonScratch =
  windows $ \ws ->
    maybe ws (\last -> W.view (W.tag last) ws) $
      lastNonScratch ws

lastNonScratch ws =
  listToMaybe
    . filter (not . isScratch . W.tag)
    $ W.hidden ws

isScratch :: String -> Bool
isScratch tag = tag == "NSP" || tag == "SP"
