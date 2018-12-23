#!/usr/bin/env runhaskell

{- |
>>> pandoc test.md --filter includes.hs -o test.pdf

test.md:
@
Add content of README.md as markdown

```{.input}
README.md
```

test.c:

```{.c .include}
test.c
```

test.c, lines 1 and 3:
```{.c .include}
test.c:1-1
test.c:3-3
```
@
-}

module Main where

import Text.Pandoc
import Text.Pandoc.Error
import Text.Pandoc.JSON
import Control.Exception ( IOException, handle )
import System.IO ( hPutStrLn, stderr )
import System.Exit ( exitFailure )
import Text.Read ( readMaybe )
import Data.List ( lines, unlines )
import qualified Data.Text.IO as T ( readFile )

doInclude :: Block -> IO [Block]
doInclude cb@(CodeBlock (id, classes, namevals) files)
  | "include" `elem` classes = do
        contents <- getFiles files
        pure [CodeBlock (id, classes', namevals) contents]
  | "input" `elem` classes || "inputmd" `elem` classes = concat <$> mapM inputMD (lines files)
  | otherwise = pure [cb]
  where
    classes' = filter (/= "include") classes
doInclude x = pure [x]

getFiles :: String -> IO String
getFiles files = concat <$> mapM getFile (lines files)

getFile :: String -> IO String
getFile fileLines = case break (== ':') fileLines of
    ("", ':':range) -> getEmpty range
    (file, ':':range) -> getLines file range
    (file, []) -> readFileOrDie file
    _ -> die $ "unknown file include defintion " ++ fileLines

getLines :: FilePath -> String -> IO String
getLines file range = case break (== '-') range of
    (sf, '-':st) -> case (,) <$> readMaybe sf <*> readMaybe st of
        Just (f, t) -> unlines . take (t - f + 1) . drop (f - 1) . lines <$> readFileOrDie file
        Nothing -> dieRange
    _ -> dieRange
  where dieRange = die $ "Could not parse line range for " ++ file ++ ": '"
                         ++ range ++ "', expected range FROM-TO"

getEmpty :: String -> IO String
getEmpty str = case readMaybe str of
    Just cnt -> pure . unlines $ replicate cnt ""
    Nothing -> die $ "Could not parse empty line count '" ++ str ++ "'"

stripPandoc :: Either PandocError Pandoc -> IO [Block]
stripPandoc p = case p of
    Left err -> die $ "Pandoc error in input: " ++ show err
    Right (Pandoc _ blocks) -> pure blocks

inputMD :: FilePath -> IO [Block]
inputMD file = do
    cont <- readFileOrDie' T.readFile file
    stripPandoc . runPure $ readMarkdown def cont

readFileOrDie' :: (FilePath -> IO a) -> FilePath -> IO a
readFileOrDie' rf file = handle (ioe file) $ rf file

readFileOrDie :: FilePath -> IO String
readFileOrDie = readFileOrDie' readFile


ioe :: FilePath -> IOException -> IO a
ioe file ex = die $ "Could not open included code file " ++ file ++ ", " ++ show ex

die :: String -> IO a
die msg = hPutStrLn stderr msg >> exitFailure

main :: IO ()
main = toJSONFilter doInclude
