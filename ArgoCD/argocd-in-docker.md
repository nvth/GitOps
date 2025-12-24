## 📑 Mục lục

- [📌 Mục tiêu](#-mục-tiêu)
- [🧩 Yêu cầu hệ thống](#-yêu-cầu-hệ-thống-requirements)
- [⚙️ Chuẩn bị môi trường](#️-chuẩn-bị-môi-trường)
  - [Kích hoạt WSL 2 Integration trong Docker Desktop](#1️⃣-kích-hoạt-wsl-2-integration-trong-docker-desktop)
- [📦 Cài đặt Minikube & kubectl](#-cài-đặt-minikube--kubectl-trong-wsl-2)
  - [Cài đặt Minikube](#-cài-đặt-minikube)
  - [Cài đặt kubectl](#-cài-đặt-kubectl)
- [▶️ Khởi chạy Minikube](#️-khởi-chạy-minikube)
- [✅ Kiểm tra trạng thái cluster](#-kiểm-tra-trạng-thái-cluster)
- [🔐 Cài đặt ArgoCD](#-cài-đặt-argocd)
  - [Tạo namespace cho ArgoCD](#1️⃣-tạo-namespace-cho-argocd)
  - [Cài đặt các thành phần ArgoCD](#2️⃣-cài-đặt-các-thành-phần-argocd)
  - [Theo dõi trạng thái Pod](#3️⃣-theo-dõi-trạng-thái-pod)
- [🌐 Truy cập ArgoCD UI](#-truy-cập-argocd-ui)
  - [Port Forward](#1️⃣-port-forward)
  - [Truy cập trình duyệt](#2️⃣-truy-cập-trình-duyệt)
  - [Thông tin đăng nhập](#3️⃣-thông-tin-đăng-nhập)
- [📎 Best Practices](#-best-practices)
- [📚 Tài liệu tham khảo](#-tài-liệu-tham-khảo)


# 🚀 Triển khai Minikube & ArgoCD trên WSL 2 (Docker Driver)

## 📌 Mục tiêu
Thiết lập môi trường Kubernetes local trên **Windows + WSL 2**, sử dụng **Docker Desktop** làm container runtime, sau đó cài đặt và truy cập **ArgoCD** để quản lý GitOps.

Tài liệu này phù hợp cho:
- Dev / DevOps
- Security Lab
- PoC
- Học và demo GitOps với ArgoCD

---

## 🧩 Yêu cầu hệ thống (Requirements)

- **Windows 10/11** (đã bật WSL 2)
- **WSL 2** (Ubuntu khuyến nghị)
- **Docker Desktop**
- **Minikube**
- **kubectl**

---

## ⚙️ Chuẩn bị môi trường

### 1️⃣ Kích hoạt WSL 2 Integration trong Docker Desktop

1. Mở **Docker Desktop**
2. Vào:
   ```
   Settings → Resources → WSL Integration
   ```
3. Bật **Enable integration with my default WSL distro**
4. Bật thêm cho distro Linux đang sử dụng (ví dụ: Ubuntu)
5. Apply & Restart Docker Desktop

> 💡 Minikube sẽ dùng Docker daemon từ Docker Desktop thông qua WSL 2.

---

## 📦 Cài đặt Minikube & kubectl (trong WSL 2)

Mở terminal **WSL 2 (Ubuntu)**.

### 🔹 Cài đặt Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Kiểm tra:

```bash
minikube version
```

---

### 🔹 Cài đặt kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl
```

Kiểm tra:

```bash
kubectl version --client
```

---

## ▶️ Khởi chạy Minikube

> ⚠️ **Không chạy Minikube bằng quyền root hoặc sudo**

```bash
minikube start --driver=docker
```

---

## ✅ Kiểm tra trạng thái cluster

```bash
kubectl get nodes
```

### Kết quả mong đợi

```text
NAME       STATUS   ROLES           AGE    VERSION
minikube   Ready    control-plane   3m9s   v1.34.0
```

> ✔️ `STATUS = Ready` là điều kiện bắt buộc trước khi tiếp tục.

---

## 🔐 Cài đặt ArgoCD

### 1️⃣ Tạo namespace cho ArgoCD

```bash
kubectl create namespace argocd
```

---

### 2️⃣ Cài đặt các thành phần ArgoCD

```bash
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

### 3️⃣ Theo dõi trạng thái Pod

```bash
kubectl get pods -n argocd -w
```

> 🎉 ArgoCD đã được cài đặt thành công khi tất cả Pod ở trạng thái `Running`.

---

## 🌐 Truy cập ArgoCD UI

### 1️⃣ Port Forward

```bash
kubectl port-forward svc/argocd-server \
  -n argocd 9889:443
```

### 2️⃣ Truy cập trình duyệt

```
https://localhost:9889
```

### 3️⃣ Thông tin đăng nhập

- **Username**: admin
- **Password**:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

---

## 📎 Best Practices

- Không chạy Minikube bằng root
- Đổi mật khẩu admin ngay sau khi login
- Không expose ArgoCD public trong môi trường local

---

## 📚 Tài liệu tham khảo

- https://minikube.sigs.k8s.io/docs/
- https://argo-cd.readthedocs.io/
- https://kubernetes.io/docs/
