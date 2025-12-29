## Mục lục

- [Mục tiêu](#mục-tiêu)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống-requirements)
- [Chuẩn bị môi trường](#chuẩn-bị-môi-trường)
  - [Enable WSL 2 Integration trong Docker Desktop](#1-enable-wsl-2-integration-trong-docker-desktop)
- [Cài đặt Minikube & kubectl](#cài-đặt-minikube--kubectl-trong-wsl-2)
  - [Cài đặt Minikube](#cài-đặt-minikube)
  - [Cài đặt kubectl](#cài-đặt-kubectl)
- [Khởi chạy Minikube](#khởi-chạy-minikube)
- [Kiểm tra trạng thái cluster](#kiểm-tra-trạng-thái-cluster)
- [Cài đặt ArgoCD](#cài-đặt-argocd)
  - [Tạo namespace cho ArgoCD](#tạo-namespace-cho-argocd)
  - [Cài đặt ArgoCD](#cài-đặt-argocd-1)
- [Truy cập ArgoCD UI](#truy-cập-argocd-ui)
  - [Port Forward](#port-forward)
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

### 1. Enable WSL 2 Integration trong Docker Desktop

1. Mở Docker Desktop
2. Truy cập:
   ```
   Settings → Resources → WSL Integration
   ```
3. Enable integration with my default WSL distro
4. Enable distro Linux đang sử dụng (ví dụ: Ubuntu)
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

Automation script: [argocd.sh](https://github.com/nvth/GitOps/blob/master/ArgoCD/argocd.sh)

Hoặc manual install từng bước
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

Port forwarding, sử dụng port khác 8080 tránh conflict với các dịch vụ khác

```bash
kubectl port-forward svc/argocd-server -n argocd 9889:443
```

---
### Truy cập WebUI
https://localhost:9889

### Thông tin đăng nhập

**Username**: admin

**Password**:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d; echo
```
Trạng thái đăng nhập thành công vào dashboard của ArgoCD
<img width="1049" height="667" alt="image" src="https://github.com/user-attachments/assets/9770b840-c214-48a8-a55d-79668cc89a43" />

---
## ArgoCD CLI trên WSL (rất quan trọng, để sử dụng `argocd` cli)

### 1. Tải bản mới nhất của Argo CD CLI
```bash
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
```

### 2. Cấp quyền thực thi cho tệp vừa tải
```bash
sudo chmod +x /usr/local/bin/argocd
```

### 3. Kiểm tra argocd cli
``````bash
argocd version
``````

Kết quả như thế này là thành công
```bash
nvth@LAPTOP-530M3F5E:/mnt/c/Users/Admin$ argocd version
argocd: v3.2.3+2b6251d
  BuildDate: 2025-12-24T12:35:36Z
  GitCommit: 2b6251dfedb54de40596272a73ed1fb19d740219
  GitTreeState: clean
  GoVersion: go1.25.0
  Compiler: gc
  Platform: linux/amd64
{"level":"fatal","msg":"Argo CD server address unspecified","time":"2025-12-29T02:54:20Z"}
```
### 4. Kết nối ArgoCD cli với ArgoCD in Docker

Vì ArgoCD trong lab này được cài tại Docker và port forward của nó là `9889`, nên địa chỉ sẽ là `localhost:9889`

```bash
argocd login localhost:9889 --username admin --password '!1111111' --insecure 
```

Kết quả mong muốn

```bash
nvth@LAPTOP-530M3F5E:/mnt/c/Users/Admin$ argocd login localhost:9889 --username admin --password '!1111111' --insecure
'admin:login' logged in successfully
Context 'localhost:9889' updated
```
Kiểm tra lại 1 lần nữa với `argo version`

Kết quả mong muốn

```bash
nvth@LAPTOP-530M3F5E:/mnt/c/Users/Admin$ argocd version
argocd: v3.2.3+2b6251d
  BuildDate: 2025-12-24T12:35:36Z
  GitCommit: 2b6251dfedb54de40596272a73ed1fb19d740219
  GitTreeState: clean
  GoVersion: go1.25.0
  Compiler: gc
  Platform: linux/amd64
argocd-server: v3.2.3+2b6251d
  BuildDate: 2025-12-24T12:10:11Z
  GitCommit: 2b6251dfedb54de40596272a73ed1fb19d740219
  GitTreeState: clean
  GoVersion: go1.25.0
  Compiler: gc
  Platform: linux/amd64
  Kustomize Version: v5.7.0 2025-06-28T07:00:07Z
  Helm Version: v3.18.4+gd80839c
  Kubectl Version: v0.34.0
  Jsonnet Version: v0.21.0
nvth@LAPTOP-530M3F5E:/mnt/c/Users/Admin$
```

## Best Practices

- Không chạy Minikube bằng quyền root
- Đổi mật khẩu admin ngay sau khi đăng nhập
- Không expose ArgoCD public trong môi trường local

---

## Tài liệu tham khảo

- https://minikube.sigs.k8s.io/docs/
- https://argo-cd.readthedocs.io/
- https://kubernetes.io/docs/
