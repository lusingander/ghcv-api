{ name = "ghcv-api"
, dependencies =
  [ "arrays", "console", "effect", "httpure", "prelude", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
