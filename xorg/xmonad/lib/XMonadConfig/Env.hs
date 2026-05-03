module XMonadConfig.Env
  ( Cfg (..),
    Env (..),
    buildEnvironment,
    dzenFont,
    xmonadFont,
  )
where

import Data.Aeson (FromJSON (parseJSON), decodeFileStrict, defaultOptions, fieldLabelModifier, genericParseJSON)
import Data.Char (toLower)
import GHC.Generics (Generic)
import System.Directory (getHomeDirectory)
import System.Exit (exitFailure)
import System.FilePath ((</>))
import System.IO (hPutStrLn, stderr)

data Cfg = Cfg
  { cfgFont :: String,
    cfgPromptHeight :: Int,
    cfgTabsHeight :: Int,
    cfgHiRes :: Bool,
    cfgMainWsGroup :: [String]
  }
  deriving (Show, Generic)

instance FromJSON Cfg where
  parseJSON = genericParseJSON defaultOptions {fieldLabelModifier = dropEnvPrefix}

dropEnvPrefix :: String -> String
dropEnvPrefix ('c' : 'f' : 'g' : c : cs) = toLower c : cs
dropEnvPrefix name = name

data Env = Env
  { cfg :: Cfg,
    home :: String
  }

buildEnvironment :: IO Env
buildEnvironment = do
  home <- getHomeDirectory
  let config = home </> ".config/xmonad.json"
  cfg <- decodeFileStrict config
  case cfg of
    Nothing -> do
      hPutStrLn stderr "Invalid JSON in config.json"
      exitFailure
    Just cfg -> pure Env {cfg, home}

dzenFont :: Env -> String
dzenFont env = cfgFont . cfg $ env

xmonadFont :: Env -> String
xmonadFont env = "xft:" ++ (cfgFont . cfg $ env)
