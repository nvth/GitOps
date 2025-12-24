# Tạo Application trên Argo CD (Demo Guestbook)

## 1. Truy cập Argo CD UI
- Vào **Application**
- Chọn **New App**
- Chọn **Edit as YAML**

## 2. Import YAML cấu hình Application

Sao chép và dán nội dung YAML sau:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: test-guestbook
  namespace: argocd

spec:
  project: default

  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook

  destination:
    server: https://kubernetes.default.svc
    namespace: default

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 3. Hoàn tất
- Nhấn **Save**
- Nhấn **Create**

## 4. Kết quả mong đợi
- Application `test-guestbook` được tạo thành công
- Argo CD tự động:
  - **Sync** manifests từ Git
  - **Prune** tài nguyên không còn trong Git
  - **Self-heal** khi có drift so với trạng thái mong muốn

---

**Ghi chú**
- Repo sử dụng: `argocd-example-apps`
- Đây là ứng dụng mẫu chuẩn để test Argo CD hoạt động end-to-end
- Phù hợp cho demo và kiểm tra pipeline GitOps
