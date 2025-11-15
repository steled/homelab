![renovate workflow](https://github.com/steled/homelab/actions/workflows/renovate.yaml/badge.svg)

# homelab

Repository for my homelab configuration

## installation

- for cilium gatewayAPI you first need to apply the gatewayAPI CRDs from here: https://gateway-api.sigs.k8s.io/guides/#install-standard-channel
  - because of TLS Route is only available at experimental channel apply the following CRDs: https://gateway-api.sigs.k8s.io/guides/#install-experimental-channel

## upgrade

- because of Longhorn it is saver to first update the control-plane only by commentig out the `staticWorkers` section in the file [homelab.yaml](./homelab.yaml)
- run `make k1-apply-homelab` after commenting out the lines
- if the update of the control-plane was successfull remove the comments at `staticWorkers` section and run `make k1-apply-homelab` again
