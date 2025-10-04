#######################################
# GitHub OIDC Provider (shared)
#######################################

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.github_thumbprint]
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  github_thumbprint = data.tls_certificate.github.certificates[0].sha1_fingerprint
}
