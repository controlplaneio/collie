# Loading CSV Data

A tool to aid bootstrapping compoent files from CSVs.

## Perquisites

* Python
* pyyaml - Install with `pip install -r requirements.txt`

## Usage

`python loadcsv.py metadata.yaml nist.csv > out.yaml`

The metadata file must contain the metadata for a component definition file, e.g.

```yaml
component-definition:
  uuid: 20e597f6-836b-436f-ba4e-74be11f96d27
  metadata:
    title: collie-aws-s3-crossplane-community
    last-modified: '2023-01-05T12:00:00Z'
    version: "20230105"
    oscal-version: 1.0.0
    parties:
    - uuid: 98b53905-1ce2-4af0-a059-459b117925d1
      type: organization
      name: ControlPlane
      links:
      - href: <https://github.com/controlplaneio
        rel: website
  components:
  - uuid: 51bfea57-cc49-40de-a091-65759a65b5b3
    type: policy
    title: collie-aws-s3
    description: ControlPlane Security Policy Demo for S3 provisioned by Crossplane Community AWS Provider
    purpose: Validate compliance controls
    responsible-roles:
    - role-id: provider
      party-uuids:
        - 98b53905-1ce2-4af0-a059-459b117925d1 
    control-implementations:
    - uuid: 0faa2504-c14c-4a94-8904-30cbdb94a362
      source: https://github.com/controlplaneio/collie/blob/main/AWS/S3/NIST_SP-800-53_rev5_S3-baseline_profile.yaml
      description:
        S3 control implementations for NIST SP 800-53 revision 5.
```
