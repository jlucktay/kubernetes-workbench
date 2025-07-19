FROM debian:12-slim

# https://docs.github.com/en/packages/learn-github-packages/connecting-a-repository-to-a-package#connecting-a-repository-to-a-container-image-using-the-command-line
LABEL org.opencontainers.image.source=https://github.com/jlucktay/kubernetes-workbench

ARG KUBECTL_VERSION="1.31"
ARG KUBECTL_VERSION_LONG="1.31.11-1.1"

VOLUME [ "/schema" ]

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update the apt package index and install packages needed to use the Kubernetes apt repository and the entrypoint/conversion scripts:
RUN apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
  apt-transport-https=2.6.1 \
  ca-certificates=20230311 \
  curl=7.88.1-10+deb12u12 \
  gnupg=2.2.40-1.1 \
  jq=1.6-2.1 \
  moreutils=0.67-1 \
  python3-pip=23.0.1+dfsg-1 \
  python3=3.11.2-1+b1 \
  && apt-get clean \
  && rm --force --recursive /var/lib/apt/lists/*

RUN pip3 install --break-system-packages --no-cache-dir pyyaml==6.0.2

# Download the public signing key for the Kubernetes package repositories.
# The same signing key is used for all repositories so you can disregard the version in the URL:
RUN curl --fail --location --show-error --silent "https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/Release.key" | gpg --dearmor --output /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# Allow unprivileged APT programs to read this keyring:
RUN chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the appropriate Kubernetes apt repository.
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list:
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
# Help tools such as command-not-found to work correctly:
RUN chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, then install kubectl:
RUN apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
  kubectl=${KUBECTL_VERSION_LONG} \
  && apt-get clean \
  && rm --force --recursive /var/lib/apt/lists/*

RUN curl --location --output /bin/openapi2jsonschema.py https://github.com/yannh/kubeconform/raw/6ae8c45bc156ceeb1d421e9b217cfc0c7ba5828d/scripts/openapi2jsonschema.py

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT [ "/bin/entrypoint.sh" ]
