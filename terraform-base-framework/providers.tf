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
    profile        = "base-framework"  # Change it to your profile on first init/run, then migrate it.
  }
}

# ########################################### #
#  Local file                                 #
# ########################################### #
provider local {
  # Configuration options
}

# ########################################### #
#  TLS certs                                  #
# ########################################### #
provider tls {
  # Configuration options
}

# ########################################### #
#  Template                                   #
# ########################################### #
provider template {
  # Configuration options
}

# ########################################### #
#  AWS                                        #
# ########################################### #
provider aws {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      "owning_team" = "COREINT"
      "purpose"     = "development-integration-environments"
    }
  }
}

# Variables so we can change them using Environment variables.
variable aws_region {
  type    = string
  default = "us-east-1"
}
variable aws_profile {
  type    = string
  default = "coreint"
}
