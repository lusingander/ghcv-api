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
  , "node-process"
  , "prelude"
  , "psci-support"
  , "simple-json"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
