# Cilium Installation Guide

## Prerequisites

- Kubernetes cluster (minikube, EKS, GKE, etc.)
- kubectl configured to access your cluster

## Installation Options

### Option 1: Using Cilium CLI (Recommended)

```bash
# Download and install Cilium CLI
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}

# For macOS (Apple Silicon)
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-darwin-arm64.tar.gz{,.sha256sum}
shasum -a 256 -c cilium-darwin-arm64.tar.gz.sha256sum
sudo tar xzvfC cilium-darwin-arm64.tar.gz /usr/local/bin
rm cilium-darwin-arm64.tar.gz{,.sha256sum}

# For macOS (Intel)
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-darwin-amd64.tar.gz{,.sha256sum}
shasum -a 256 -c cilium-darwin-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-darwin-amd64.tar.gz /usr/local/bin
rm cilium-darwin-amd64.tar.gz{,.sha256sum}
```

### Option 2: Using Helm

```bash
# Add Cilium Helm repository
helm repo add cilium https://helm.cilium.io/

# Install Cilium
helm install cilium cilium/cilium --version 1.18.2 \
  --namespace kube-system \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true
```

### Option 3: Using kubectl

```bash
# Install Cilium using kubectl
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.18.2/install/kubernetes/quick-install.yaml
```

## Verify Installation

```bash
# Check Cilium status
cilium status

# Check pods
kubectl get pods -n kube-system -l k8s-app=cilium

# Check Hubble
kubectl get pods -n kube-system -l k8s-app=hubble-ui
```

## Enable Hubble UI (Optional)

```bash
# Port forward Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 8080:80

# Access Hubble UI at http://localhost:8080
```

## Troubleshooting

### If Cilium CLI is not found:
```bash
# Make sure cilium is in your PATH
which cilium

# If not found, add to PATH or use full path
export PATH=$PATH:/usr/local/bin
```

### If pods are not ready:
```bash
# Check pod logs
kubectl logs -n kube-system -l k8s-app=cilium

# Check node status
kubectl get nodes
```

## Next Steps

After installation, you can proceed with the use cases:

1. **Use Case 1**: Basic Network Policies
2. **Use Case 2**: Observability with Hubble
3. **Use Case 3**: Service Mesh Capabilities

## Version Information

This repository is tested with:
- **Cilium**: v1.18.2
- **Kubernetes**: v1.28+
- **Minikube**: v1.31+

For the latest version, check: https://github.com/cilium/cilium/releases
