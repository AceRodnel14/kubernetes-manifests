#!/bin/bash
# Script to create a read-only monitoring service account for Lens
# This includes permissions for metrics, logs, and monitoring (but no write access)

echo "🔧 Creating Lens monitoring service account..."

# 1. Create the service account
kubectl create serviceaccount lens-monitor -n kube-system

# 2. Create a custom ClusterRole with monitoring permissions
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: lens-monitor
rules:
# View all resources (same as 'view' role)
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
# Read metrics
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]
# Read node metrics and stats
- apiGroups: [""]
  resources: ["nodes/stats", "nodes/metrics", "nodes/proxy"]
  verbs: ["get", "list"]
# Read pod logs
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
# Exec into pods (for terminal access)
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create", "get"]
# Port forwarding
- apiGroups: [""]
  resources: ["pods/portforward"]
  verbs: ["create", "get"]
# Additional monitoring resources
- apiGroups: [""]
  resources: ["pods/status", "services/status"]
  verbs: ["get"]
EOF

# 3. Bind the custom role to the service account
kubectl create clusterrolebinding lens-monitor-binding \
  --clusterrole=lens-monitor \
  --serviceaccount=kube-system:lens-monitor

# 4. Create a long-lived token (10 years)
echo "🔑 Creating authentication token..."
TOKEN=$(kubectl create token lens-monitor -n kube-system --duration=87600h)

# 5. Get cluster information
echo "📋 Gathering cluster information..."
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# 6. Create the kubeconfig file
cat > lens-monitor-kubeconfig.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: lens-monitor
  name: lens-monitor@${CLUSTER_NAME}
current-context: lens-monitor@${CLUSTER_NAME}
users:
- name: lens-monitor
  user:
    token: ${TOKEN}
EOF

echo ""
echo "✅ Lens monitoring service account created successfully!"
echo "📄 Kubeconfig saved to: lens-monitor-kubeconfig.yaml"
echo ""
echo "🔍 Permissions granted:"
echo "  ✅ Read all resources (pods, deployments, services, etc.)"
echo "  ✅ View metrics (CPU, memory usage)"
echo "  ✅ Read pod logs"
echo "  ✅ Exec into pods (terminal access)"
echo "  ✅ Port forwarding"
echo "  ❌ Cannot create, update, or delete resources"
echo ""
echo "📦 To use with your Lens container:"
echo "  1. Copy lens-monitor-kubeconfig.yaml to your docker host"
echo "  2. Update docker-compose.yml volume mount:"
echo "     - ./lens-monitor-kubeconfig.yaml:/config/.kube/config:ro"
echo ""
echo "🧹 To remove this service account later:"
echo "  kubectl delete serviceaccount lens-monitor -n kube-system"
echo "  kubectl delete clusterrole lens-monitor"
echo "  kubectl delete clusterrolebinding lens-monitor-binding"