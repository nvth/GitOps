#!/bin/bash
set -e

NAMESPACE="argocd"
ARGOCD_PORT=9889

echo "==> [1/6] Kiểm tra Minikube..."
kubectl get nodes >/dev/null

echo "==> [2/6] Tạo namespace argocd (nếu chưa có)..."
kubectl get ns $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

echo "==> [3/6] Cài Argo CD..."
kubectl apply -n $NAMESPACE \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "==> [4/6] Đợi Argo CD pods sẵn sàng..."
kubectl wait --for=condition=Available deployment/argocd-server \
  -n $NAMESPACE --timeout=300s

echo "==> [5/6] Lấy mật khẩu admin..."
ADMIN_PASS=$(kubectl get secret argocd-initial-admin-secret \
  -n $NAMESPACE -o jsonpath="{.data.password}" | base64 -d)

echo "----------------------------------------"
echo " Argo CD Admin Login"
echo "----------------------------------------"
echo " URL      : https://localhost:${ARGOCD_PORT}"
echo " Username : admin"
echo " Password : ${ADMIN_PASS}"
echo "----------------------------------------"

echo "==> [6/6] Port-forward Argo CD (Ctrl+C để dừng)"
kubectl port-forward svc/argocd-server -n $NAMESPACE ${ARGOCD_PORT}:443
