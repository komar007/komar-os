module XMonadConfig.Topics
  ( myTopicNames,
    myTopicConfig,
  )
where

import Data.Map qualified as M
import XMonad (Default (def))
import XMonad.Actions.SpawnOn (spawnHere)
import XMonad.Actions.TopicSpace

myTopics :: [TopicItem]
myTopics =
  [ ti "NSP" "~",
    ti "c1" "~",
    ti "d1" "~",
    ti "c2" "~",
    ti "d2" "~",
    ti "c3" "~",
    ti "d3" "~",
    ti "sys1" "~",
    ti "ds1" "~",
    ti "sys2" "~",
    ti "ds2" "~",
    TI "web1" "~" $ spawnHere "firefox",
    TI "web2" "~" $ spawnHere "firefox",
    TI "mail" "~" $ spawnHere "thunderbird",
    ti "vm1" "~",
    ti "vm2" "~"
  ]
  where
    ti t d = TI t d shell
    shell = spawnHere "~/.xmonad/terminal.sh terminal tmux new-session -A -s 0"

myTopicNames :: [Topic]
myTopicNames = map (\(TI n _ _) -> n) myTopics

myTopicConfig :: TopicConfig
myTopicConfig =
  def
    { topicDirs = M.fromList $ map (\(TI n d _) -> (n, d)) myTopics,
      defaultTopicAction = const (pure ()),
      defaultTopic = "web1",
      topicActions = M.fromList $ map (\(TI n _ a) -> (n, a)) myTopics
    }
