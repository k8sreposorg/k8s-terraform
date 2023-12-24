#########################################  Importing  modules #################################

module "computing"{
source = "./modules/computing/ec2"
appsg = "${module.security.appsg}"
dbsg = "${module.security.dbsg}"
public-subnet = "${module.networking.public-subnet}"
private-subnet = "${module.networking.private-subnet}"
myamiid = "${var.myamiid}"
mykeypair = "${var.mykeypair}"
}


module "networking"{
source = "./modules/networking/vpc"
appserver = "${module.computing.appserver}"
dbserver = "${module.computing.dbserver}"
}


module "security"{
source = "./modules/security/sg"
cloudstones-vpc = "${module.networking.cloudstones-vpc}"
}

