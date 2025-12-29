# Tạo User và thực hiện phân quyền trong ArgoCD

## Yêu cầu
- WSL
- ArgoCD CLI (đã cài đặt trong wsl)

## Tạo User

1. Sử dụng command line

```bash
kubectl edit cm argocd-cm -n argocd 
```

2. Thêm accounts.<tên-người-dùng> vào phần data. Ví dụ tạo user dev:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  accounts.dev: login, apiKey   # cho phép dùng apikey cho tài khoản này
```

3. Kiểm tra trạng thái argocd account đang tồn tại trong hệ thống

```bash
argocd account list
```

Kết quả mong muốn

```bash
nvth@LAPTOP-530M3F5E:/mnt/c/Users/Admin$ argocd account list
NAME   ENABLED  CAPABILITIES
admin  true     login
dev    true     login, apiKey
```

4. Update password cho user `dev`
argocd account update-password \
  --account dev \
  --current-admin-password '!1111111' \
  --new-password '!1111111'

5. Kiểm tra lại lần nữa
argocd account list

```bash
nvth@LAPTOP-530M3F5E:/mnt/c/Users/Admin$ argocd account list
NAME   ENABLED  CAPABILITIES
admin  true     login
dev    true     login, apiKey
```

## Thực hiện phân quyền cho user vừa tạo

1. Chỉnh sửa argocd RBAC

```bash
kubectl edit cm argocd-rbac-cm -n argocd
```

Thêm `data` vào tệp `argocd-rbac-cm` 

```bash
data:
  policy.csv: |
    # Cho phép user 'dev' có quyền xem và sync ứng dụng
    p, dev, applications, get, */*, allow
    p, dev, applications, sync, */*, allow
    # Cho phép xem các thiết lập project
    p, dev, projects, get, *, allow
```

**Lưu ý:**

- `data` cùng cấp với `metadata`

Kết quả mong muốn 
```bash
apiVersion: v1
data:
  policy.csv: |
    # Cho phép user 'dev' có quyền xem và sync ứng dụng
    p, dev, applications, get, */*, allow
    p, dev, applications, sync, */*, allow
    # Cho phép xem các thiết lập project
    p, dev, projects, get, *, allow
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"ConfigMap","metadata":{"annotations":{},"labels":{"app.kubernetes.io/name":"argocd-rbac-cm","app.kubernetes.io/part-of":"argocd"},"name":"argocd-rbac-cm","namespace":"argocd"}}
  creationTimestamp: "2025-12-25T02:02:51Z"
  labels:
    app.kubernetes.io/name: argocd-rbac-cm
    app.kubernetes.io/part-of: argocd
  name: argocd-rbac-cm
  namespace: argocd
  resourceVersion: "148007"
  uid: 974c3888-1434-4557-98bf-7c79d21d33fc
~
~
~
"/tmp/kubectl-edit-2894137660.yaml" 25L, 1035B 
```

## Bảng định nghĩa các quyền hạn trong ArgoCD

| Tài nguyên (Resource) | Hành động (Actions) | Ý nghĩa |
|-----------------------|---------------------|---------|
| applications          | get, create, update, delete, sync, override, action/<action-name> | Quản lý vòng đời ứng dụng, đồng bộ và ghi đè thông số. |
| projects              | get, create, update, delete | Quản lý App Projects (nhóm ứng dụng). |
| clusters              | get, create, update, delete | Quản lý các Cluster kết nối với Argo CD. |
| repositories          | get, create, update, delete | Quản lý kết nối Git hoặc Helm repository. |
| accounts              | get, update, can-login | Quản lý tài khoản và quyền đăng nhập. |
| certificates          | get, create, update, delete | Quản lý chứng chỉ SSL/TLS. |
| gpgkeys               | get, create, delete | Quản lý khóa GPG xác thực commit. |
| logs                  | get | Xem log của Pod từ giao diện web. |
| exec                  | create | Truy cập terminal vào thẳng Pod (Shell). |
