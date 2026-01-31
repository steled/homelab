# renovate: datasource=github-releases depName=gateway-api packageName=kubernetes-sigs/gateway-api
API_VERSION=1.4.0 # get version from here: https://github.com/kubernetes-sigs/gateway-api/tags
wget -q --show-progress https://github.com/kubernetes-sigs/gateway-api/releases/download/v${API_VERSION}/experimental-install.yaml
curl -O https://github.com/kubernetes-sigs/gateway-api/releases/download/v${API_VERSION}/experimental-install.yaml
