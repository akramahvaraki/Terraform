output "ecr_repository_urls" {
  value = {
    for service in local.services : service => module.ecr[service].repository_url
  }
}
