module Day05 where

import Control.Applicative ((<|>))
import Control.Lens ((^..))
import Control.Lens.Combinators
import qualified Control.Monad.State as State
import qualified Data.Foldable as Foldable
import Data.Function ((&))
import Data.Functor (($>), (<&>))
import Data.IntMap (IntMap, (!))
import qualified Data.IntMap as IntMap
import qualified Data.List as List
import qualified Data.Maybe as Maybe
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.IO as Text
import Data.Void (Void)
import Text.Megaparsec (Parsec)
import qualified Text.Megaparsec as Megaparsec
import qualified Text.Megaparsec.Char as Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as Megaparsec.Char.Lexer

parseCrates :: Text -> IntMap [Char]
parseCrates input =
  input
    & Text.splitOn "\n"
    & map Text.unpack
    & List.transpose
    & map reverse
    & unlines
    & Megaparsec.parseMaybe (Megaparsec.many crates)
    <&> Maybe.catMaybes
    <&> IntMap.fromList
    & Maybe.fromMaybe (error "Oops")
  where
    crates :: Parsec Void String (Maybe (Int, [Char]))
    crates =
      do
        n <- Megaparsec.Char.Lexer.decimal
        chars <- Megaparsec.many Megaparsec.Char.letterChar
        Megaparsec.Char.space1
        -- Need to reverse chars so top of stack is at front of list
        pure (Just (n, reverse chars))
        <|> Megaparsec.skipManyTill Megaparsec.anySingle Megaparsec.Char.newline $> Nothing

data Move = Move
  { amount :: Int,
    from :: Int,
    to :: Int
  }

parseMoves :: Text -> [Move]
parseMoves input =
  input
    & Megaparsec.parseMaybe (Megaparsec.many move)
    & Maybe.fromMaybe (error "💩")
  where
    move :: Parsec Void Text Move
    move = do
      amount <- "move " *> Megaparsec.Char.Lexer.decimal
      from <- " from " *> Megaparsec.Char.Lexer.decimal
      to <- " to " *> Megaparsec.Char.Lexer.decimal <* Megaparsec.Char.space
      pure Move {..}

part1 :: Text -> String
part1 input = do
  let (cratesLines : movesLines : _) = Text.splitOn "\n\n" input
      crates = parseCrates cratesLines
      moves = parseMoves movesLines

  let finalCrates = flip State.execState crates do
        Foldable.for_ moves \Move {..} -> do
          State.modify \crates' -> do
            let (reverse -> lose, keep) = List.splitAt amount (crates' ! from)
            crates' & IntMap.insert from keep & IntMap.insertWith (<>) to lose
  finalCrates ^.. folded . taking 1 folded

part2 :: Text -> String
part2 input = do
  let (cratesLines : movesLines : _) = Text.splitOn "\n\n" input
      crates = parseCrates cratesLines
      moves = parseMoves movesLines

  let finalCrates = flip State.execState crates do
        Foldable.for_ moves \Move {..} -> do
          State.modify \crates' -> do
            -- Only difference, omitting the reverse here
            let (lose, keep) = List.splitAt amount (crates' ! from)
            crates' & IntMap.insert from keep & IntMap.insertWith (<>) to lose
  finalCrates ^.. folded . taking 1 folded

run :: IO ()
run = do
  input <- Text.readFile "../input/day05"
  putStrLn "part 1"
  putStrLn (part1 input)
  putStrLn "part 2"
  putStrLn (part2 input)
