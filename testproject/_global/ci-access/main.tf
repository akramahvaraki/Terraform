module "iam_assumable_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version   = "5.51.0"
  role_name = "DepositproofCIAssumableRole"

  trusted_role_arns = [
    "arn:aws:iam::850956595534648:user/CIAccessUser",
  ]

  trusted_role_services = []
  create_role           = true

  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  ]
}
