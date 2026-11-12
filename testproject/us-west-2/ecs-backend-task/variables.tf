variable "image_name" {
  description = "The name of the Docker image to use for the ECS service"
  type        = string
}

variable "image_tag" {
  description = "The tag of the Docker image to use for the ECS service"
  type        = string
}

variable "env" {
  description = "Environment variables used in backend service"
  type        = list(object({
    name  = string
    value = any
  }))
}
