# Ceros Devops Code Challenge

Summary: Take our stubbed out ceros-ski infrastructure and make it functional.

## The Task

Contained within is a stubbed-out infrastructure for the ceros-ski nodejs game.
It is not currently functional.  What we'd like you to do is take this stub and
make it work, so that the ceros-ski game can be loaded successfully in the
browser on the deployed infrastructure. We'd like the resulting infrastructure
to be highly available. 

Additionally, take some time to pull out any Terraform modules that you think
it would make sense to abstract.  Take a look at the Dockerfile and optimize it
to the best of your abilities.  As you are working, keep an eye out for
security vulnerabilities.  Fix any that you find, and make sure new code does
not introduce any.

Please document your code and your choices.  If you make any techdebt decisions
in the interest of time, please ensure they are also well documented.  Update
the provided usage documentation and architecture documentation to account for
any changes you make.

You will be graded on the cleanliness of your code, the quality of your
documentation, and your architectural choices.

The challenge is structured to take about one working day's (8 hours) worth of
effort.  But it's not timed, and you can take as much time with it as you want
to.

You should be able to complete it sticking to the AWS free tier - and please do
so, because we won't compensate you for any charges incurred.

Note: You can ignore the code in the `/app` directory other than the Dockerfile
and any work necessary to get it deployed.  That's the challenge we give to
prospective full stack devs - it has some bugs and missing features, including
a crash that can happen right off the bat.  You don't need to worry about
fixing those.

## Acceptance Criteria

You can consider the challenge "done" when each of these has been achieved.

- The infrastructure is functional: the ceros-ski game can be loaded successfully in the browser.
- The infrastructure is highly available: the ceros-ski container is running in two or more availability zones.
- Changes to the ceros-ski game can be deployed to the infrastructure with out any downtime.
- The Dockerfile in the `/app` directory has been optimized.
- Any logical modules have been refactored out.

## Grading

You will be graded on the following criteria.

- How readable, organized, and documented your code is
- How well optimized the Dockerfile is
- What has been pulled out into terraform modules, and how well structured those modules are
- How well security concerns have been handled
- The quality, detail, and clarity of your usage and architecture documentation
- How well documented and reasonable tech debt decisions are

## Bonus

**Note: You won’t be marked down for excluding any of this, it’s purely bonus.
If you’re really up against the clock, make sure to focus on writing clean, well
organized, and well documented code before taking on any of the bonus.**

If you find yourself with time to spare, are enjoying yourself, and really want
to impress us, add in one or more of the following.

- Implement autoscaling in the ECS Cluster and Autoscaling Group
- Write and document an automated deployment system for the Docker image
- Add monitoring to the infrastructure
- Implement some form of shared terraform state
- ??? Surprise us with something new and interesting ???



======================================================================================================

# Ceros Devops Code Challenge

## Dockerfile

The dockerfile contains a multi-stage build to avoid source code exposure.
This makes the image size small and lightweight only containing the built artifacts.

The build command was combined with the tag command. `docker build -t ***.dkr.ecr.***.amazonaws.com/ceros-ski:latest .` This was done this way to avoid having two separate images after the build is done.

The build script `./app/build.sh` can be used in a CI pipeline to automatically build, tag and push the image.

## Terraform files
The monolithic `main.tf` terraform files was refactored to more logical file structure for easier maintenance. Application load balancer, EC2, auto-scaling group.

## Repository

The `infrastructure/repository` directory remains largely unchanged, with a minor variable changes to satisfy parameter required by the aws provider module.

## ECS cluster

The ECS cluster and its dependencies are defined in `infrastructure/environments`.

The cluster is made up of the following resources;

- An ECS cluster with configurations, like the task definition, IAM roles and ECS services defined in `main.tf` file.

- Two `bastion hosts` with configurations in two availablity zones for high availability, defined in `infrastructure/environments/ec2.tf`.
This host is used for SSH access to the ECS instance. 

- `Application loadbalancer` with configs defined in `infrastructure/environments/alb.tf`.
This is used to expose the url of the application running in the ECS cluster. 
The ALB has one listener on port `80`. Its url will be displayed on the console after the infrastructure has been created using `terraform apply`.

- `VPC` with configs defined in `infrastructure/environments/vpc.tf`
The cluster VPC has 2 subnets; 2 private and 2 public in 2 different availability zones. This can be configured to higher availability using the `az.count` variable in `variables.tf` or overridden by other inputs of higher precedence.

- `AutoScaling group` with configs defined in `infrastructure/environments/autoscaling.tf`.
This AutoScaling group is defined to have a minimum of 1 instance, 2 desired instances and a maximum of 4 instances.

- `Security groups` are configured for the autoscaling group, the application load balancer and the bastion EC2 instances; with appropriate ingress and egress rules
  
## Technical Debt
- The terraform state file could be better secured in an s3 bucket, for security and easy distribution between the team(s).
- An automated CI/CD pipeline will be very helpful.