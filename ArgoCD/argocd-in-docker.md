## Mục lục

- [Mục tiêu](#mục-tiêu)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống-requirements)
- [Chuẩn bị môi trường](#chuẩn-bị-môi-trường)
  - [Kích hoạt WSL 2 Integration trong Docker Desktop](#1-kích-hoạt-wsl-2-integration-trong-docker-desktop)
- [Cài đặt Minikube & kubectl](#cài-đặt-minikube--kubectl-trong-wsl-2)
  - [Cài đặt Minikube](#cài-đặt-minikube)
  - [Cài đặt kubectl](#cài-đặt-kubectl)
- [Khởi chạy Minikube](#khởi-chạy-minikube)
- [Kiểm tra trạng thái cluster](#kiểm-tra-trạng-thái-cluster)
- [Cài đặt ArgoCD](#cài-đặt-argocd)
  - [Tạo namespace cho ArgoCD](#1-tạo-namespace-cho-argocd)
  - [Cài đặt các thành phần ArgoCD](#2-cài-đặt-các-thành-phần-argocd)
  - [Theo dõi trạng thái Pod](#3-theo-dõi-trạng-thái-pod)
- [Truy cập ArgoCD UI](#truy-cập-argocd-ui)
  - [Port Forward](#1-port-forward)
  - [Truy cập trình duyệt](#2-truy-cập-trình-duyệt)
  - [Thông tin đăng nhập](#3-thông-tin-đăng-nhập)
- [Best Practices](#best-practices)
- [Tài liệu tham khảo](#tài-liệu-tham-khảo)

---

# Triển khai Minikube & ArgoCD trên WSL 2 (Docker Driver)

## Mục tiêu

Thiết lập môi trường Kubernetes local trên Windows kết hợp WSL 2, sử dụng Docker Desktop làm container runtime, sau đó cài đặt và truy cập ArgoCD để quản lý GitOps.

Tài liệu này phù hợp cho:
- Dev / DevOps
- Security Lab
- Proof of Concept
- Học và demo GitOps với ArgoCD

---

## Yêu cầu hệ thống (Requirements)

- Windows 10/11 (đã bật WSL 2)
- WSL 2 (khuyến nghị Ubuntu)
- Docker Desktop
- Minikube
- kubectl

---

## Chuẩn bị môi trường

### 1. Kích hoạt WSL 2 Integration trong Docker Desktop

1. Mở Docker Desktop
2. Truy cập:
   ```
   Settings → Resources → WSL Integration
   ```
3. Bật Enable integration with my default WSL distro
4. Bật thêm cho distro Linux đang sử dụng (ví dụ: Ubuntu)
5. Apply và Restart Docker Desktop

---

## Cài đặt Minikube & kubectl (trong WSL 2)

### Cài đặt Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

---

### Cài đặt kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl
```

---

## Khởi chạy Minikube

```bash
minikube start --driver=docker
```

---

## Kiểm tra trạng thái cluster

```bash
kubectl get nodes
```

---

## Cài đặt ArgoCD

### Tạo namespace cho ArgoCD

```bash
kubectl create namespace argocd
```

---

### Cài đặt ArgoCD

```bash
kubectl apply -n argocd   -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## Truy cập ArgoCD UI

### Port Forward

```bash
kubectl port-forward svc/argocd-server -n argocd 9889:443
```

---

### Lấy mật khẩu admin

```bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d; echo
```

---

## Best Practices

- Không chạy Minikube bằng quyền root
- Đổi mật khẩu admin ngay sau khi đăng nhập
- Không expose ArgoCD public trong môi trường local

---

## Tài liệu tham khảo

- https://minikube.sigs.k8s.io/docs/
- https://argo-cd.readthedocs.io/
- https://kubernetes.io/docs/
