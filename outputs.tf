output "fastapi_app_dns_url" {
  value       = module.api_app_server_ec2_01.public_dns
  description = "Gives you the public dns of the ec2 to access the application"
}
