import System.Environment
import Data.Maybe
import Data.List
import Control.Exception

main :: IO ()
main = do
  isTest <- getEnv "TEST" `catch` (\(SomeException _) -> return "")
  if isTest == "1"
    then do
      testFile <- readFile "tests"
      putStrLn $ tests testFile
    else do
      input <- getContents
      putStrLn $ trim (solve (trim input))

--処理
solve :: String -> String
solve s =
  show
    $ x
    + ( sum
      . fmap (\a -> (length . takeWhile (<=d) . fmap (\x -> x * a + 1)) [0 ..])
      )
        list
 where
  (line1:line2:line3) = lines s
  n                   = read line1 :: Int
  [d, x]              = fmap read (words line2) :: [Int]
  list                = fmap read line3 :: [Int]

tests :: String -> String
tests text = case testParse text of
  Right bodys -> unlines (fmap (\(i, body) -> test i body) (zip [1 ..] bodys))
  Left  msg   -> "Test file parse error:" ++ msg

test :: Int -> (String, String) -> String
test n (input, outputRight)
  | output == outputRight
  = header ++ "Passed"
  | otherwise
  = header
    ++ "Faild\n"
    ++ "Right:"
    ++ show outputRight
    ++ "\nOutput:"
    ++ show output
 where
  header = "test" ++ show n ++ ":"
  output = trim $ solve input

testParse :: String -> Either String [(String, String)]
testParse s = case lines s of
  (sp1:sp2:bodys) -> testBodysParse sp1 sp2 bodys
  _               -> Left "testParse"

testBodysParse
  :: String -> String -> [String] -> Either String [(String, String)]
testBodysParse sp1 sp2 = (traverse . testBodyParse) sp2 . (split sp1)

testBodyParse :: String -> [String] -> Either String (String, String)
testBodyParse sp body = case fmap (trim . unlines) (split sp body) of
  [input, output] -> Right (input, output)
  _               -> Left "testBodyParse"

split :: Eq a => a -> [a] -> [[a]]
split spratar = foldr f [[]]
 where
  f x (p:ps) | x == spratar = [] : p : ps
             | otherwise    = (x : p) : ps
  f _ _ = undefined

trimHead :: String -> String
trimHead = dropWhile (\s -> isJust (elemIndex s [' ', '\t', '\n', '\r']))

trim :: String -> String
trim = reverse . trimHead . reverse . trimHead