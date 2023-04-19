# AWS cluster bootstrapping

To aid testing and development of new policies for AWS there is some terraform to provision an EKS cluster for you and install crossplane and kyverno. Provisioning happens in 2 stages because the kubernetes provider can't handle dependencies properly itself. There are helper script to run the terraform commands in the right order and pass variables around.

## Quickstart

To create a cluster first run `init.sh` to pull the terraform dependencies for both stages. You also need to define the variables (via tfvars) `project_name`. Optionally you can also define `aws_region` and `aws_profile`

Then to bring up the cluster run `up.sh`. Once this is complete you should have a cluster ready to go.