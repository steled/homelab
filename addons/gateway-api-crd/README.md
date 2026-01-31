# renovate: datasource=github-releases depName=gateway-api packageName=kubernetes-sigs/gateway-api
VERSION=1.4.0
wget -q --show-progress https://github.com/kubernetes-sigs/gateway-api/releases/download/v${VERSION}/experimental-install.yaml
curl -O https://github.com/kubernetes-sigs/gateway-api/releases/download/v${VERSION}/experimental-install.yaml
