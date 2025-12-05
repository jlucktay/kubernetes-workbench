FROM debian:13-slim

# https://docs.github.com/en/packages/learn-github-packages/connecting-a-repository-to-a-package#connecting-a-repository-to-a-container-image-using-the-command-line
LABEL org.opencontainers.image.source=https://github.com/jlucktay/kubernetes-workbench

ARG KUBECTL_VERSION="1.33"
ARG KUBECTL_VERSION_LONG="1.33.6-1.1"

VOLUME [ "/schema" ]

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update the apt package index and install packages needed to use the Kubernetes apt repository and the entrypoint/conversion scripts:
RUN apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
  apt-transport-https=3.0.3 \
  ca-certificates=20250419 \
  curl=8.14.1-2+deb13u2 \
  gnupg=2.4.7-21 \
  jq=1.7.1-6+deb13u1 \
  moreutils=0.69-1+b1 \
  python3-pip=25.1.1+dfsg-1 \
  python3=3.13.5-1 \
  && apt-get clean \
  && rm --force --recursive /var/lib/apt/lists/*

RUN pip3 install --break-system-packages --no-cache-dir pyyaml==6.0.3

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
