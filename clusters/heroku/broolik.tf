# https://registry.terraform.io/providers/heroku/heroku/latest/docs/resources/app

resource "heroku_pipeline" "broolik" {
  name = "broolik"

  owner {
    id   = "1463c5b6-751b-4527-92a4-37e265ac9e9b"
    type = "user"
  }
}

resource "heroku_app" "broolik-master" {
  acm = false
  buildpacks = [
    "heroku/ruby",
    "heroku/nodejs",
  ]
  internal_routing = false
  name             = "broolik-master"
  region           = "us"
  stack            = "heroku-18"
}

resource "heroku_domain" "broolik-ml" {
  app      = heroku_app.broolik-master.name
  hostname = "broolik.ml"
}

resource "heroku_pipeline_coupling" "broolik-development" {
  app      = heroku_app.broolik-master.name
  pipeline = heroku_pipeline.broolik.id
  stage    = "development"
}
