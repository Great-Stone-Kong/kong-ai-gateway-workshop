# Config is applied by terraform_data.kong_install (kong.yml upload + compose recreate).
# This resource exists so config-only changes stay explicit in the module layout.
# Re-apply triggers live on kong_yml_sha / license_sha in kong_install.tf.
