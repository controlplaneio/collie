# Collie

`Collie`: Toolkit for securing cloud controller provisioned infrastructure and demonstrating compliance

Collie is a POC project demonstrating how infrastructure provisioned by cloud infrastructure controllers can be simultaneously secured and validated for compliance. It provides NIST 800-53 rev.5 aligned libraries of Kyverno Policy to secure Infrastructure provisioned by [Crossplane](https://www.crossplane.io/) [Community Provider](https://marketplace.upbound.io/providers/crossplane-contrib/provider-aws/), generated from OSCAL documents, and leverages Lula to use the same OSCAL documents to validate compliance.

* [Collie](#collie)
  * [Why?](#why)
* [Prerequisites](#prerequisites)
* [AWS Usage](#aws-usage)
  * [Bootstrapping a cluster](#bootstrapping-a-cluster)


## Why?

Organisations moving into cloud, often rely on using Infrastructure as Code templates with Policy enforcement for provisioning secure infrastructure, and rightly so. However, Kubernetes itself provisions infrastructure natively, through Load Balancer Services, or through third party cloud controllers, such as Crossplane. 

This provides a challenge in large regulated organisations, which invest heavily in IAC and Policy patterns, forming an integral part of their enterprise security architecture. This inertia and lack of an equivalent pattern for infrastructure provisioned by cloud controllers will impede the adoption of these technologies, despite the benefits of 
* developer simplicity via consumption of a single K8s deployment pipeline for apps and infrastructure 
* gitops enablement for infrastructure    
and
* drift protection, as cloud controllers continuously reconcile

The intention of Collie is to create confidence in a pattern where k8s provisioned infrastructure is secured via policy engines acting as Kubernetes Admission controllers, such as Kyverno, and can be simultaneously validated for compliance using OSCAL documents and Lula.

For a more in depth discussion around the motivation for this and demonstrating it in action you can watch Andy presenting at Cloud Native SecurityCon 2023:   
   
[![SecurityCon Talk](https://img.youtube.com/vi/cvoWlwftbEE/0.jpg)](https://www.youtube.com/watch?v=cvoWlwftbEE)


## Prerequisites

An installation of [lula](https://github.com/defenseunicorns/lula) is required for compliance validation and policy generation. For convenience, its installed as a submodule within [Tools](./Tools). Install lula by running `make build-lula` from the root folder.

Kyverno also needs to be installed (Not via Kubectl plugin). Follow [Kyverno Installation Instructions](https://kyverno.io/docs/kyverno-cli/#manual-binary-installation)

## AWS Usage

### Bootstrapping a Cluster

> ❗️Note that this cluster is not hardened and is for experimentation/test purposes only ❗️

> ❗ The cluster API will be exposed publicly but will be restricted so it can only be accessed from the IP address you are running the tests from. This can cause issues if your IP address changes, e.g. you move to a new network. If this happens you will have to manually add your new IP from the AWS console. ❗

Navigate to [AWS/Bootstrap](https://github.com/controlplaneio/collie/tree/main/AWS/Bootstrap)

To create a cluster first run `init.sh` to pull the terraform dependencies for both stages.

Within [provider](./AWS/Bootstrap/provider), [cluster](./AWS/Bootstrap/cluster) and [demoResources](./AWS/Bootstrap/demoResources/) you need to define the variables (via tfvars) `project_name`. Optionally you can also define `aws_region` and `aws_profile`

Then to bring up the cluster run `up.sh`. Once this is complete you should have a cluster with Kyverno, Crossplane and the Crossplane Community Provider ready to go.

### Applying Policies

Policies are available within the [AWS/S3/Policies](https://github.com/controlplaneio/collie/tree/main/AWS/S3/Policies) and [AWS/RDS/Policies](https://github.com/controlplaneio/collie/tree/main/AWS/RDS/Policies) folders

They are set with `validationFailureAction: enforce` and can be applied to the cluster to block non-compliant resources.

### Creating Resources

Resources are available within [AWS/S3/resourceTemplates](https://github.com/controlplaneio/collie/tree/main/AWS/S3/resourceTemplates) and [AWS/RDS/resourceTemplate](https://github.com/controlplaneio/collie/tree/main/AWS/RDS/resourceTemplates) folders

They leverage helm, set the secrets values file as required, prior to installation.

To install individual resources use
`helm template -f values.secret.yaml -s templates/<Resource>.yaml . | kubectl apply -f -`

### Assessing for Compliance

Lula can be run against the cluster to assess for compliance, using the component definitions as a source of truth. run `<path/to>/lula validate <oscal-component-definition.yaml>`

### Creating new Policies

1. Edit the relevant OSCAL component definition file e.g [AWS/S3/S3-component-definition.yaml](https://github.com/controlplaneio/collie/blob/main/AWS/S3/S3-component-definition.yaml)
2. Run `make generate-policies` from the root directory. Policies will be written to the Policies folder for each collection (e.g. S3, RDS, etc)
3. Update the tests by creating the resources required within the `resourceTemplates` folder and updating `kyverno-test.yaml`

### Unit Testing

Tests are defined within kyverno-test.yaml with resources tested defined within resourceTemplates for each service

To run the tests define `values.secret.yaml` in each resourceTemplates folder and run `make unit-test`

### Linting

To ensure code quality code will be linted ot make sure all files follow a consistent style and catch any potential errors.

Currently there are linters for:

* Yaml ([yamllint](https://github.com/adrienverge/yamllint))
* Helm ([Helm CLI](https://helm.sh/))
* Terraform ([Terraform CLI](https://www.terraform.io/), [tflint](https://github.com/terraform-linters/tflint))

These will be run as part of CI, it is recommended to install these on your system and check linting before contributing code.

### End to End testing

End to end testing involves deploying a k8s cluster with crossplane and kyverno installed then deploying the kyverno policies and then trying to create infrastructure and asserting that the resources are appropriately allowed or denied by kyverno.

> ❗️Note that these tests are creating real resources in AWS. This may take a while, as some resources like RDS can take 10-15 minutes to provision, this means it can appear that the tests are hanging but it may take 20 mins for them to complete. Since the resources are actually provisioned this may incur costs.❗️

The tests are run using [bats](https://bats-core.readthedocs.io/en/stable/index.html). The bats tooling is included as submodules so make sure to run `git submodule update --init --recursive` to pull the submodules.
Tests are run concurrently which requires [GNU Parallel](https://www.gnu.org/software/parallel/) to be installed on your system as well.

You will also need to be set up to bootstrap a cluster, this requires [terraform](https://www.terraform.io/) to be installed, any tfvars described in the bootstrapping section of this readme, the terraform dependencies are installed (this can be done with the `init.sh` script), and you need credentials for connecting to the cloud provider e.g. AWS or GCP.
Also make sure the correct profile is configured for AWS in a `tfvars` file in *each* folder, i.e. `cluster`, `demoResources` and `provider`.

Some of the tests require [yq](https://github.com/mikefarah/yq) so this should be installed.

The policies and test resources will be regenerated before running the tests. To generate the test resources you need [helm](https://helm.sh/) installed. To generate the policies you need to build [lula](https://github.com/defenseunicorns/lula) which requires [go](https://go.dev/) to be installed. The Lula repository is included as a submodule so you don't need to clone it.

Once all this is set up you can run the tests by running `make bats-test`. This will provision the cluster and also tear it down when the tests are done. If you are going to be running the tests multiple times you can set the environment variable `PRESERVE_CLUSTER` to true to skip deleting the cluster at the end as creating a cluster can take over 10 minutes. To skip refreshing the terraform state each time as well you can set `SKIP_TERRAFORM` to `true` as well.
