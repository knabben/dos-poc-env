# Denial of Service Proof of Concept - The environment

The purpose of this repository is to provide an automated installation of the [DoS-Poc](https://github.com/knabben/dos-poc) through GitOps and FluxCD. The instructions provided here are specifically for staging and production environments.

In the staging environment, signed artifacts are fetched directly from the main branch build. On the other hand, the production cluster only deploys from released tags.

This repository is divided into two environments, each set up to run in different clusters using the scripts provided. The aim is to emulate the entire infrastructure with Kind, and the steps outlined here will provide guidance and procedures on how to use FluxCD with signed artifacts on this type of scenario.


### Bootstraping clusters and FluxCD

The first step is to run:

```
make 1-up
```

This will create:

1. A kind cluster called `staging` and another `production`
2. Bootstrap FluxCD with a GitHub mono repository.


### Installing Policy Controller

To install the sigstore policy controller with:

```
make 2-policy
```

This will install the controller and a default Image policy for validating a signed OCI image from the Github CI


### (optional) Alerting on Slack

As an optional step this enable alert on Slack for error in the image validation

```
make 3-slack SLACK_TOKEN=xoxb
```

### Cleanup and leaving no trace behind

Delete both kind clusters with:

```
make x-delete
```

Delete registry tags from both OCI manifests and images

```
make x-clean
```

If you have created an app on Slack don't forget to clean it up as well.
