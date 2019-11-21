variable "PROJECT" {
  default = "Monitoring"
}

variable "ENVIROMENT" {
  default = "dev"
}

variable "OWNER" {
  default = "erick.yataco.s@gmail.com"
}

variable "REGION" {
  default = "us-east-1"
}

variable "PATH_TO_PUBLIC_KEY" {
  default=""
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
    ca-central-1 = "ami-cb5ae7af"
  }
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}

variable "INSTANCES_NUMBER" {
  default = 1
}