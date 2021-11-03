{ name = "ghcv-api"
, dependencies =
  [ "aff"
  , "console"
  , "dotenv"
  , "effect"
  , "httpure"
  , "maybe"
  , "node-process"
  , "prelude"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
