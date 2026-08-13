########## K1 Helper for easy management
# check version here: https://github.com/kubermatic/kubeone/releases
# renovate: datasource=github-releases depName=kubeone packageName=kubermatic/kubeone
KUBEONE_VERSION=1.13.6
ROOT_DIR=$(realpath .)

K1_CONFIG="."
# from K1_CONFIG location
# K1_SSH_KEY="${ROOT_DIR}/../secrets/kone-key-ecdsa"
# K1_CRED_FILE="./secrets/credentials.kubermatic.yml"
# K1_CRED_FLAG=-c ${K1_CRED_FILE}
K1_KUBECONFIG="${ROOT_DIR}/homelab-kubeconfig"
K1_EXTRA_ARG?=""
# K1_EXTRA_ARG?="--force-upgrade"
KUBEONE_BINARY="${ROOT_DIR}/kubeone"

# CREDENTIALS_FILE=${ROOT_DIR}/../secrets/credentials.sh
# include ${CREDENTIALS_FILE}
#### sometimes needed if "special characters in password or username is used
## CREDENTIALS_FILE_OVERWRITE=./secrets/credentials.makefile.overwrite.env
## include ${CREDENTIALS_FILE_OVERWRITE}
export

######### KubeOne
k1-apply:
	@cd ${K1_CONFIG} && \
		$(KUBEONE_BINARY) ${K1_CRED_FLAG} apply $(arg) -c credentials.yaml -m homelab.yaml --verbose ${K1_EXTRA_ARG}
	kubectl delete -f addons/fluo-cleanup/fluo-cleanup.yaml || true
	kubectl apply -f addons/fluo-cleanup/fluo-cleanup.yaml
	make k1-kubeconfig
	make k1-fix-journald-size

# TODO: remove once https://github.com/kubermatic/kubeone/issues/4058 is resolved.
# kubeone/kubeadm rewrite /etc/systemd/journald.conf on every apply, silently
# dropping any manual SystemMaxUse tweak made directly in that file. A drop-in
# under journald.conf.d/ survives the rewrite, so we re-apply it after every
# k1-apply until kubeone supports configuring this natively.
K1_JOURNALD_MAX_SIZE=500M
k1-fix-journald-size:
	@for node in $(shell grep -oP "publicAddress: '\K[0-9.]+" homelab.yaml); do \
		user=$$(grep -m1 'sshUsername:' homelab.yaml | awk '{print $$2}'); \
		key=$$(grep -m1 'sshPrivateKeyFile:' homelab.yaml | awk '{print $$2}' | tr -d "'"); \
		echo "Setting journald SystemMaxUse=${K1_JOURNALD_MAX_SIZE} on $$node"; \
		ssh -o StrictHostKeyChecking=accept-new -i $$key $$user@$$node \
			"sudo mkdir -p /etc/systemd/journald.conf.d && \
			 printf '[Journal]\nSystemMaxUse=${K1_JOURNALD_MAX_SIZE}\n' | sudo tee /etc/systemd/journald.conf.d/99-homelab-max-size.conf > /dev/null && \
			 sudo systemctl restart systemd-journald"; \
	done

k1-reset:
	@cd ${K1_CONFIG} && \
		$(KUBEONE_BINARY) ${K1_CRED_FLAG} reset $(arg) -m homelab.yaml  --verbose ${K1_EXTRA_ARG}

k1-kubeconfig:
	@cd ${K1_CONFIG} && \
		$(KUBEONE_BINARY) ${K1_CRED_FLAG} kubeconfig -m homelab.yaml > ${K1_KUBECONFIG} && \
		chmod 0600 ${K1_KUBECONFIG}

# e.g. darwin, windows
export BIN_OS ?=linux
# e.g. arm64
export BIN_ARCH ?=amd64
download-kubeone-release:
	@$(eval KUBEONE_OLD=$(shell test -f $(KUBEONE_BINARY) && $(KUBEONE_BINARY) version | jq -r .kubeone.gitVersion || echo "0.0.0"))
	@$(eval VERSION_COMPARE=$(shell printf '%s\n%s' "${KUBEONE_VERSION}" "${KUBEONE_OLD}" | sort -V | tail -n1))
	@if [ "${VERSION_COMPARE}" = "${KUBEONE_OLD}" ] && [ "${KUBEONE_VERSION}" != "${KUBEONE_OLD}" ]; then \
		echo "\033[41;103mWARNING:\033[0m Current version ${KUBEONE_OLD} is newer than target version ${KUBEONE_VERSION}. Skipping download."; \
	elif [ "${KUBEONE_VERSION}" = "${KUBEONE_OLD}" ]; then \
		echo "\033[41;42mOK:\033[0m kubeone version ${KUBEONE_VERSION} is already installed and up to date"; \
	else \
		echo "\033[41;44mINFO:\033[0m Downloading new kubeone version ${KUBEONE_VERSION} (current: ${KUBEONE_OLD})"; \
		test -f $(KUBEONE_BINARY) && cp $(KUBEONE_BINARY) $(KUBEONE_BINARY)_v${KUBEONE_OLD} || echo "\033[41;101mERROR:\033[0m kubeone binary not found, downloading now"; \
		wget -q --show-progress https://github.com/kubermatic/kubeone/releases/download/v${KUBEONE_VERSION}/kubeone_${KUBEONE_VERSION}_${BIN_OS}_${BIN_ARCH}.zip -O kubeone_${KUBEONE_VERSION}_${BIN_OS}_${BIN_ARCH}.zip; \
		unzip -o kubeone_${KUBEONE_VERSION}_${BIN_OS}_${BIN_ARCH}.zip 'kubeone' -d ${ROOT_DIR}/; \
		rm kubeone_${KUBEONE_VERSION}_${BIN_OS}_${BIN_ARCH}.zip; \
	fi
