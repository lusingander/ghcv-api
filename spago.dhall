{ name = "ghcv-api"
, dependencies =
  [ "aff"
  , "console"
  , "dotenv"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "httpure"
  , "node-process"
  , "prelude"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
