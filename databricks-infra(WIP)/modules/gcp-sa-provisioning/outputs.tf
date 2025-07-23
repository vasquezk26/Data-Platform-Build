
output "custom_role_url" {
  value = "https://console.cloud.google.com/iam-admin/roles/details/projects%3C${var.project_id}%3Croles%3C${google_project_iam_custom_role.workspace_creator.role_id}"
}

output "service_account_id" {
  value = data.google_client_openid_userinfo.me.id
}

output "service_account_email" {
  value = data.google_client_openid_userinfo.me.email
}