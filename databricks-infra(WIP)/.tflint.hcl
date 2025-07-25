config {
  format = "compact"
  plugin_dir = "~/.tflint.d/plugins"
}

plugin "google" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_required_version" {
  enabled = false
}