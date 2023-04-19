# Lula - The Kubernetes Compliance Engine

lula is a tool written to bridge the gap between expected configuration required for compliance and **_actual_** configuration.

Cloud Native Infrastructure, Platforms, and applications can establish OSCAL documents that live beside source-of-truth code bases. Providing an inheritance model for when a control that the technology can satisfy _IS_ satisfied in a live-environment. 

This can be well established and regulated standards such as NIST 800-53. It can also be best practices, Enterprise Standards, or simply team development standards that need to be continuously monitored and validated.

## Hows it work?
The primary functionality is leveraging [Kyverno CLI/Engine](https://kyverno.io/docs/kyverno-cli/).
lula:
- Ingests a `oscal-component.yaml` and creates an object in memory
- Queries all `implemented-requirements` for a `rules` field
    - This rules block is a strict port from the rules of a [Kyverno ClusterPolicy](https://kyverno.io/docs/kyverno-policies/) resource
- If a rules field exists:
    - Generate a `ClusterPolicy` resource on the filesystem
    - Execute the `applyCommandHelper` function from Kyverno CLI
        - This will return the number of passing/failing resources in the cluster (or optionally static manifests on the filesystem)
        - If any fail, given valid exclusions that may be present, the control is declared as `Fail`
    - Remove `ClusterPolicy` from the filesystem
    - This is done for each `implemented-requirement` that has a `rules` field
- Generate a report of the findings (`Pass` or `fail` for each control) on the filesystem (optional - can be run with `--dry-run` in order to not write to filesystem)

## Getting Started

## Demo

### Static Manifest Demo
![Resource Demo](./images/resource-demo.gif)


### Live Cluster Demo
![Cluster Demo](./images/cluster-demo.gif)

### Try it out!

#### Dependencies:
- A running Kubernetes cluster
- GoLang version 1.19.1

#### Steps
1. Clone the repository to your local machine
2. While in the `lula` directory, run ```go build .``` to compile the tool
3. Apply the `namespace.yaml` file in the `demo` directory to your cluster using the ```kubectl apply -f ./demo/namespace.yaml``` command
4. Apply the `pod.fail.yaml` file to your cluster using the ```kubectl apply -f ./demo/pod.fail.yaml``` command
5. Run the following command in the `lula` directory, ```./lula execute ./demo/oscal-component.yaml```
    - The tool should inform you that there is at least one failing pod in the cluster
6. Now, apply the `pod.pass.yaml` file to your cluster using the ```kubectl apply -f ./demo/pod.pass.yaml``` command
    - This should modify the configuration for the pod to have the validation pass
7. Run the following command in the `lula` directory, ```./lula execute ./demo/oscal-component.yaml```
    - The tool should now show the pod as passing the compliance requirement

## Future Extensibility
- Support for cloud infrastructure state queries
- Support for API validation

## Developing
- GO 1.19
