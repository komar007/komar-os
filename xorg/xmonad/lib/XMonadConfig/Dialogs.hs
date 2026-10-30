module XMonadConfig.Dialogs
  ( placeDialogsCentered,
  )
where

import Graphics.X11.Types (Window)
import Graphics.X11.Xlib.Extras
  ( WindowAttributes (wa_height, wa_width, wa_x, wa_y),
    getTransientForHint,
    getWindowAttributes,
  )
import Graphics.X11.Xlib.Types (Display, Rectangle (rect_height, rect_width, rect_x, rect_y))
import XMonad
  ( ManageHook,
    ask,
    asks,
    doF,
    gets,
    liftX,
    pointScreen,
    (-->),
  )
import XMonad.Core (X, display, io, screenRect, windowset)
import XMonad.Hooks.ManageHelpers (isDialog)
import XMonad.StackSet qualified as W

-- | Float dialog windows, centered on their parent (falling back to the
-- current screen), sized from their requested geometry but never larger than a
-- fraction of the screen, preserving aspect ratio and keeping the window on
-- screen.
placeDialogsCentered :: ManageHook
placeDialogsCentered =
  isDialog --> do
    w <- ask
    r <- liftX $ dialogRect w
    doF (W.float w r)

-- | Compute the floating rectangle for a dialog: an anchor (parent center, or
-- current screen center), a target size derived from the window's requested
-- geometry and clamped to @maxFrac@ of the containing screen.
dialogRect :: Window -> X W.RationalRect
dialogRect w = do
  d <- asks display
  wa <- io $ getWindowAttributes d w
  mParent <- io $ getTransientForHint d w
  (ax, ay, sr) <- anchorRect d mParent
  pure $ fitDialog ax ay (fi (wa_width wa)) (fi (wa_height wa)) sr

-- | Resolve the anchor point (parent center, or current screen center) and the
-- screen rectangle that contains it.
anchorRect :: Display -> Maybe Window -> X (Integer, Integer, Rectangle)
anchorRect d mParent =
  case mParent of
    Just p -> do
      pwa <- io $ getWindowAttributes d p
      let pcx = fi (wa_x pwa) + fi (wa_width pwa) `div` 2
          pcy = fi (wa_y pwa) + fi (wa_height pwa) `div` 2
      ms <- pointScreen pcx pcy
      sr <- maybe currentScreenRect (pure . screenRect . W.screenDetail) ms
      pure (fi pcx, fi pcy, sr)
    Nothing -> do
      sr <- currentScreenRect
      let ax = fi (rect_x sr) + fi (rect_width sr) `div` 2
          ay = fi (rect_y sr) + fi (rect_height sr) `div` 2
      pure (ax, ay, sr)

currentScreenRect :: X Rectangle
currentScreenRect = do
  ws <- gets windowset
  pure $ screenRect (W.screenDetail (W.current ws))

-- | Build a screen-relative rectangle centered on the anchor, sized from the
-- requested pixel dimensions, scaled uniformly so the larger dimension reaches
-- at most @maxFrac@ of the screen, and clamped back into the screen bounds.
fitDialog ::
  Integer ->
  Integer ->
  Integer ->
  Integer ->
  Rectangle ->
  W.RationalRect
fitDialog ax ay reqW reqH sr = W.RationalRect x y w h
  where
    sx = fi (rect_x sr)
    sy = fi (rect_y sr)
    sw = fi (rect_width sr)
    sh = fi (rect_height sr)
    reqW' = fi reqW
    reqH' = fi reqH
    ax' = fi ax
    ay' = fi ay

    dim = max (reqW' / sw) (reqH' / sh)
    s = if dim <= 0 then 1 else min 1 (maxFrac / dim)
    targetW = reqW' * s
    targetH = reqH' * s

    dx = clamp sx (sx + sw - targetW) (ax' - targetW / 2)
    dy = clamp sy (sy + sh - targetH) (ay' - targetH / 2)

    x = (dx - sx) / sw
    y = (dy - sy) / sh
    w = targetW / sw
    h = targetH / sh

clamp :: (Ord a) => a -> a -> a -> a
clamp lo hi = max lo . min hi

maxFrac :: Rational
maxFrac = 0.8

fi :: (Integral a, Num b) => a -> b
fi = fromIntegral
