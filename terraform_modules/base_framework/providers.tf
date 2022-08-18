terraform {
  required_providers {
    aws   = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1"
    }
    template = {
      source = "hashicorp/template"
      version = ">= 2.2"
    }
  }

  backend s3 {
    bucket         = "nr-coreint-terraform-tfstates"
    dynamodb_table = "nr-coreint-terraform-locking"
    key            = "base-framework/global-state-store.tfstate"
    region         = "us-east-1"
  }
}

# ########################################### #
#  Local file                                 #
# ########################################### #
provider local {}

# ########################################### #
#  TLS certs                                  #
# ########################################### #
provider tls {}

# ########################################### #
#  Template                                   #
# ########################################### #
provider template {}

# ########################################### #
#  AWS                                        #
# ########################################### #
provider aws {
  default_tags {
    tags = {
      "owning_team" = "COREINT"
      "purpose"     = "development-integration-environments"
    }
  }
}

data aws_region current {}
