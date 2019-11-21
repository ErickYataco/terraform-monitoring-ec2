module "instance-monitor" {
   source                           = "./modules/ec2-monitor"
   PROJECT                          = "Monitor"
   ENVIROMENT                       = "dev"   
   PATH_TO_PUBLIC_KEY               = "./ssh/monitor-dev.pub"
   INSTANCE_TYPE                    = "t2.micro"
   REGION                           = "${var.region}"
}

module "instances-monitored" {
   source                 = "./modules/ec2-monitored"
   PROJECT                = "Monitor"
   ENVIROMENT             = "dev"   
   PATH_TO_PUBLIC_KEY     = "./ssh/monitor-dev.pub"
   INSTANCE_TYPE          = "t2.micro"
   INSTANCES_NUMBER       = "2"
   REGION                 = "${var.region}"
}