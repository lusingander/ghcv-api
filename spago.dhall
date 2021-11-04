{ name = "ghcv-api"
, dependencies =
  [ "aff"
  , "affjax"
  , "console"
  , "dotenv"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "foreign"
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
