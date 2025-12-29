# Tài liệu thực hành GitOps cơ bản (Argo CD & Minikube)

Phương pháp: Thủ công

Công cụ:

    WSL2

    Docker Desktop

    Minikube

    ArgoCD

## 1. Khái niệm cốt lõi: GitOps là gì?
GitOps là mô hình vận hành phần mềm Single Source of Truth.

* **Công thức:** GitOps = IaC (Infrastructure as Code) + Pull Request + CI/CD tự động.
* **Sự khác biệt:** Thay vì "Push" (đẩy lệnh) từ CI server, GitOps dùng cơ chế "Pull" (kéo cấu hình) từ bên trong Cluster thông qua một Agent (Argo CD).

## 2. Thiết lập môi trường Lab
- **Công cụ:** Minikube (chạy trong Docker), Argo CD.
- **Repository:** Một repo GitHub public chứa file `deployment.yaml`.

### Chi tiết file `deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
## 3. Các bước triển khai luồng GitOps
### Kết nối Git với ArgoCD step-by-step

  **Tạo New App trên giao diện Argo CD.** 
  
  ---

  Tại phần `GENERAL`

  **Application Name**: gitops-lab

  **Project Name**: default

  **Sync Policy**: Manual

  ---

  **Trỏ Source về GitHub repo và Destination (default) về cluster**

  Tại phần `SOURCE`

  **Repository** URL: `.git` url

  **Revision**: HEAD hoặc default

  **Path**: . (. nếu `deployment.yml` nằm ngay ngoài thư mục root)

  ---


  Tại phần `DESTINATION`

  **Cluster URL**: https://kubernetes.default.svc

  **Namespace**: default

  ---

**Hoặc import tệp tin yaml vào ArgoCD thực hiện cấu hình trên (IaC)**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gitops-lab
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    path: .
    repoURL: https://github.com/pentesterh404/my-gitops-lab.git
    targetRevision: HEAD
  sources: []
  project: default
  syncPolicy:
    automated: null
```
  -   Save

  -   Sync để triển khai

=> Triển khai thành công luồng GitOps

## 4. Phá để hiểu

### Drift Detection

Vào WSL sử dụng command Scale lại pod cho ứng dụng:

`kubectl scale deployment web-app --replicas=3`

Lúc này: 

**Desired State** (trạng thái mong muốn trên git) là 1.

**Live State** (Trạng thái thực tế local) được scale lên 3.

Lúc này **Argo CD** lập tức phát hiện và cảnh báo bằng màu vàng (**OutOfSync**).

=> Hiểu thêm về Drift Detection và chứng minh Git là nguồn, mọi thay đổi không nằm trên Git đều được coi là tạm thời

=> Luồng dữ liệu trong gitops là một chiều (Git -> Cluster).

### Self-Healing

#### **Manual Sync**
Sau khi sử dụng command scale lại pod khiến cho `ArgoCD` phát hiện sự sai lệch trong quá trình đồng bộ (**Manual Sync**), Kubernetest cluster tự động tạo thêm pod, sau đó nếu tiếp tục được `Sync` tại dashboard ArgoCD, ArgoCD lúc này sẽ tham gia xem xét sự thay đổi, ArgoCD tin tưởng Git và tiến hành xoá đi 2 pod vừa khởi tạo bằng kubectl đang tồn tại trong cluster.

Có thể sử dụng Auto-Sync để quá trình này được thực hiện tự động.

#### **Auto-Sync**

Tại `Application` > `gitops-lab` > `Details` > tìm tới mục `SYNC POLICY` > `Enable Auto-Sync`


### After the Sence

#### Revision

Def: Nơi mà ArgoCD sẽ pull

- HEAD: ArgoCD sẽ lấy commit mới nhất trên nhánh mặc định (main, master)

- Branch Name: tên nhánh (staging, dev, prod)

- Tag: phiên bản code đã được thống nhất đi vào sử dụng, v1.0.0

- SHA: git commit hash, fix cứng không cho argocd tự động cập nhật nếu có sư thay đổi.


Ví dụ: 

Tạo nhánh `dev` từ nhánh `main` trên `git` và thay đổi giá `replicas : 3`, sau đó tiến hành sync lại argocd

Tại phần `DETAILS` > `SUMMARY`, thay đổi giá trị `TARGET REVISION` từ HEAD sang dev sau đó `Save` và `Synchronize`

Lúc này ArgoCD nhận dạng dev thành công, tạo ra 1 commit hash mới

#### Rollback

Tất cả lịch sử các phiên bản sau khi được Sync sẽ tồn tại trong `History and Rollback` sẵn sàng cho việc rollback

Không nên dùng rollback tại ArgoCD - dẫn đến tính trạng `out of sync` do không đồng bộ với `git`

Chỉ sự dụng `rollback` trên `git`


