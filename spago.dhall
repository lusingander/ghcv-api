{ name = "ghcv-api"
, dependencies =
  [ "aff"
  , "affjax"
  , "arrays"
  , "assert"
  , "console"
  , "control"
  , "dotenv"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "http-methods"
  , "httpure"
  , "integers"
  , "maybe"
  , "newtype"
  , "node-process"
  , "nullable"
  , "ordered-collections"
  , "prelude"
  , "psci-support"
  , "simple-json"
  , "strings"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
