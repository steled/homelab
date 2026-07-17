# renovate: datasource=github-releases depName=gateway-api packageName=kubernetes-sigs/gateway-api
API_VERSION=1.6.1 # get version from here: https://github.com/kubernetes-sigs/gateway-api/tags
echo "downloading file"
wget -q --show-progress -O ~/repositories/github/homelab/addons/gateway-api-crd/experimental-install_${API_VERSION}.yaml https://github.com/kubernetes-sigs/gateway-api/releases/download/v${API_VERSION}/experimental-install.yaml
# curl -LO https://github.com/kubernetes-sigs/gateway-api/releases/download/v${API_VERSION}/experimental-install.yaml
echo "applying file"
k apply -f ~/repositories/github/homelab/addons/gateway-api-crd/experimental-install_${API_VERSION}.yaml --server-side
echo "renaming file"
mv ~/repositories/github/homelab/addons/gateway-api-crd/experimental-install_${API_VERSION}.yaml ~/repositories/github/homelab/addons/gateway-api-crd/experimental-install_${API_VERSION}.yaml.stop
