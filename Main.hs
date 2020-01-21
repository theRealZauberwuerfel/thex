-- {-# LANGUAGE
--     GeneralizedNewtypeDeriving
--   , TemplateHaskell
--   #-}

module Main where

-- import Control.Lens
import Data.Char (chr,ord)
import Data.Foldable (forM_)
import System.IO (getLine)

-- Don't import qualified, but named, to distinguish.
import UI.NCurses as NC

main :: IO ()
main = do
    putStrLn "What board size do you want? (5-8):"
    line <- getLine
    let n = read line :: Int
    drawBoard n

drawBoard :: Int -> IO ()
drawBoard n = runCurses $ do
    setEcho False
    w <- defaultWindow
    setCursorMode CursorVeryVisible
    let zero@(x',y') = (3,3)
    drawCellLines w zero n
    waitFor w

-- We support board sizes from 11^2 to 14^2.
minBoardSize = 11 :: Int
maxBoardSize = 14 :: Int

welcomeMessage = "Welcome to THex! Have fun."

drawCellLines w start@(startX,startY) num = do
    forM_ lineJumps putter
    render
  where
    putter = \n ->
        drawCellLine w (startX + n, startY + n) num
    -- How to move the cursor for next cell line.
    lineJumps = take num [0,2..]

drawCellLine w (startX,startY) num =
    forM_ columnJumps putter
  where
    putter = \n -> drawCell w (startX,startY + n)
    columnJumps = take num [0,4..]

drawCell w (startX,startY) =
    updateWindow w $ do
        forM_ moveTable drawer
        moveCursor 0 0
  where
    drawer :: (Integer,Integer,Glyph) -> Update ()
    drawer (x',y',g) = do
        moveCursor (startX + x') (startY + y')
        drawGlyph g
    moveTable = [ 
                  (2,1,sl)
                , (2,3,bs)
                , (3,0,pipe)
                , (3,4,pipe)
                , (4,1,bs)
                , (4,3,sl)
                ]

-- How to build our special glyphs.
glypher = \chr -> Glyph chr []
-- BackSlash
bs = glypher '\\'
-- Pipe
pipe = glypher '|'
-- Slash
sl = glypher '/'
-- Space
space = glypher ' '
-- UnderScore
us = glypher '_'
-- Player O (blue)
o = glypher 'o'
-- Player X (red)
x = glypher 'x'

-- Alphabet for the columns.
abc@[a,b,c,d,e,f,g,h,i,j,k] = map glypher ['A'..'K']
{-
-- Numbers for the rows.
nums = nums1to9 ++ [ten,eleven,twelve,thirteen,fourteen]
nums1to9@[zero,one,two,three,four,five,six,seven,eight,nine] =
    map (glypher . head . show) [0..9]

ten = [one,zero]
eleven = [one,one]
twelve = [one,two]
thirteen = [one,three]
fourteen = [one,four]
-}

waitFor :: Window -> Curses ()
waitFor w = loop where
    drawer c = do
      updateWindow w $ do
        moveCursor 3 2
        drawGlyph c
        moveCursor 0 0
      render
      loop
    loop = do
        ev <- getEvent w Nothing
        (i,j) <- getCursor w
        case ev of
            Nothing -> loop
            Just (EventSpecialKey k) -> keyRecognizer k
            Just (EventCharacter ev') -> case ev' of
                'o' -> drawer o
                'x' -> drawer x
                '\t' -> do
                    updateWindow w $ do
                      drawGlyph glyphDiamond
                    render
                    loop
                'q' -> return ()
                otherwise -> loop
      where
        keyRecognizer k = do
            cursor@(row,col) <- getCursor w
            case k of
                KeyUpArrow -> do
                  updateWindow w $ do
                      if (row>0)
                        then moveCursor (row-1) col
                        else return ()
                  render
                  loop
                KeyDownArrow -> do
                  updateWindow w $ do
                      moveCursor (row+1) col
                  render
                  loop
                KeyLeftArrow -> do
                  updateWindow w $ do
                      if (col>0)
                        then moveCursor row (col-1)
                        else return ()
                  render
                  loop
                KeyRightArrow -> do
                  updateWindow w $ do
                      moveCursor row (col+1)
                  render
                  loop
-- Just some thoughts on using lenses.
{-
data Field = Field
  { _row    :: Int
  , _column :: Char
  }

makeLenses ''Field

newtype Line = Line { _line :: [Field] }
makeLenses ''Line

newtype Board = Board { _lines :: [Line] }
makeLenses ''Board
-}
