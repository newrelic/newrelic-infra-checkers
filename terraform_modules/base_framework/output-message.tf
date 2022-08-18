output zzz_message {
  value = <<-EOM
    A file with the credentials to save states has being saved here:
      ${pathexpand("~/.aws/shared-credentials/base-framework/credentials")}

    Please, add this snippet to your AWS config file so you can use it
    as a profile for all the deployments that use this store backend:

    ====================================
    [profile base-framework]
    credential_process = cat $HOME/.aws/shared-credentials/base-framework/credentials
    region = ${aws_s3_bucket.tfstates.region}
    output = json
    ====================================
    EOM
}
