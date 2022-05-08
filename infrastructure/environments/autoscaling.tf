
/*******************************************************************************
* AutoScaling Group
*
* The autoscaling group that will generate the instances used by the ECS
* cluster.
*
********************************************************************************/


/** 
* This parameter contains the AMI ID of the ECS Optimized version of Amazon
* Linux 2 maintained by AWS.  We'll use it to launch the instances that back
* our ECS cluster.
*/
data "aws_ssm_parameter" "cluster_ami_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

/**
* The launch configuration for the autoscaling group that backs our cluster.  
*/
resource "aws_launch_configuration" "cluster" {
  name                 = "${var.app_name}-${var.environment}-cluster"
  image_id             = data.aws_ssm_parameter.cluster_ami_id.value
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.autoscaling_group.id]

  // Register our EC2 instances with the correct ECS cluster.
  user_data = <<EOF
#!/bin/bash
echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.name}" >> /etc/ecs/ecs.config
EOF
}

/**
* The autoscaling group that backs our ECS cluster.
*/
resource "aws_autoscaling_group" "cluster" {
  name             = "${var.app_name}-${var.environment}-cluster"
  min_size         = 1
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier  = aws_subnet.public_subnet.*.id
  launch_configuration = aws_launch_configuration.cluster.name

  tag {
    key                 = "Application"
    value               = var.app_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Resource"
    value               = "modules.ecs.cluster.aws_autoscaling_group.cluster"
    propagate_at_launch = true
  }

  depends_on = [
    aws_vpc.main_vpc,
  ]
}



/*******************************************************************************
* AutoScaling Group
*
* The autoscaling group that will generate the instances used by the Bastion
* hosts
*
********************************************************************************/

/**
* This parameter contains the AMI ID for the most recent Amazon Linux 2 ami,
* managed by AWS.
*/
data "aws_ssm_parameter" "linux2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn-ami-hvm-x86_64-ebs"
}

/**
* The public key for the key pair we'll use to ssh into our bastion instance.
*/
resource "aws_key_pair" "bastion" {
  key_name   = "${var.app_name}-bastion-key-${var.aws_region}"
  public_key = file(var.public_key_path)
}

/**
* The launch configuration for the autoscaling group that backs our cluster.  
*/
resource "aws_launch_configuration" "bastion" {
  name          = "${var.app_name}-${var.environment}-bastion"
  image_id      = data.aws_ssm_parameter.linux2_ami.value
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion.key_name

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  security_groups             = [aws_security_group.autoscaling_group.id]
}

/**
* The autoscaling group that backs our bastion hosts.
*/
resource "aws_autoscaling_group" "bastion-host" {
  name             = "${var.app_name}-${var.environment}-bastion"
  min_size         = 1
  max_size         = 2
  desired_capacity = 2

  vpc_zone_identifier  = aws_subnet.public_subnet.*.id
  launch_configuration = aws_launch_configuration.bastion.name

  tag {
    key                 = "Application"
    value               = var.app_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Resource"
    value               = "modules.ecs.cluster.aws_autoscaling_group.bastion"
    propagate_at_launch = true
  }

  depends_on = [
    aws_vpc.main_vpc,
  ]
}
