module Day05 where

import Control.Arrow ((>>>))
import Control.Newtype (ala)
import qualified Control.Newtype as Newtype
import Data.Function ((&))
import Data.Functor ((<&>))
import qualified Data.List as List
import qualified Data.Maybe as Maybe
import Data.Ord (Down (..))
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.IO as Text
import qualified Text.Read as Read

part1 :: Text -> Int
part1 input =
  input
    & Text.splitOn "\n\n"
    <&> Text.lines
    <&> (map (Text.unpack >>> Read.readMaybe >>> Maybe.fromMaybe 0) >>> sum)
    & maximum

part2 :: Text -> Int
part2 input =
  input
    & Text.splitOn "\n\n"
    <&> Text.lines
    <&> (map (Text.unpack >>> Read.readMaybe >>> Maybe.fromMaybe 0) >>> sum)
    & Newtype.underF Down (List.sort >>> take 3)
    & sum

run :: IO ()
run = do
  input <- Text.readFile "../input/day01"
  putStrLn "part 1"
  print (part1 input)
  putStrLn "part 2"
  print (part2 input)
