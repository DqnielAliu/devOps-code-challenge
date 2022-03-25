/******************************************************************************
* Bastion Host
*******************************************************************************/

/**
* The public key for the key pair we'll use to ssh into our bastion instance.
*/
resource "aws_key_pair" "bastion" {
  key_name   = "ceros-ski-bastion-key-${var.aws_region}"
  public_key = file(var.public_key_path)
}

/**
* This parameter contains the AMI ID for the most recent Amazon Linux 2 ami,
* managed by AWS.
*/
data "aws_ssm_parameter" "linux2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn-ami-hvm-x86_64-ebs"
}

/**
* Launch a bastion instance we can use to gain access to the private subnets of
* this availabilty zone.
*/
resource "aws_instance" "bastion" {
  count         = var.az_count
  ami           = data.aws_ssm_parameter.linux2_ami.value
  key_name      = aws_key_pair.bastion.key_name
  instance_type = "t2.micro"

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  tags = {
    Application = "ceros-ski"
    Environment = var.environment
    Name        = "ceros-ski-${var.environment}-${var.aws_region}-bastion"
    Resource    = "modules.availability_zone.aws_instance.bastion"
  }
}
