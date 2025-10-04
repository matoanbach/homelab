module "ec2" {
    source = "../../modules/ec2"
    instance_type = "t2.micro"
    ami = "ami-123"
    region = "us-east-1"
}