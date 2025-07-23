locals {
  bronze_schemas = {
    mso                     = jsondecode(file("bronze_schemas/mso.json"))
    accesscode              = jsondecode(file("bronze_schemas/accesscode.json"))
    transaction             = jsondecode(file("bronze_schemas/transaction.json"))
    member_app_core_backend = jsondecode(file("bronze_schemas/member_app_core_backend.json"))
    admin_backend           = jsondecode(file("bronze_schemas/admin_backend.json"))
  }
}