{ name = "ghcv-api"
, dependencies =
  [ "aff"
  , "affjax"
  , "console"
  , "control"
  , "dotenv"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "http-methods"
  , "httpure"
  , "maybe"
  , "newtype"
  , "node-process"
  , "nullable"
  , "prelude"
  , "psci-support"
  , "simple-json"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
