/******************************************************************************
* ECR
*
* Create the repo and initialize it with our docker image first.  Just push the
* image to "latest" to start with.
*
********************************************************************************/

/**
* The ECR repository we'll push our images to.
*/
resource "aws_ecr_repository" "fashion-flux" {
  name                 = "fashion-flux"
  image_tag_mutability = "MUTABLE"
}
