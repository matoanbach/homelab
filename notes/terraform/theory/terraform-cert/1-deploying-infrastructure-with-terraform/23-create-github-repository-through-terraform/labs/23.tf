terraform {
    required_providers {
      github = {
        source = "integrations/github"
        version = "~> 6.0"
      }
    }
}

provider "github" {
    token = ""
}

resource "github_repository" "example" {
    name = "example"
    description = "my example"
    visibility = "public"
}