# Triển khai LabX lên Linux

## Kiến trúc

```text
push / pull request
  -> GitHub Actions CI
  -> build image theo commit SHA
  -> GitHub Container Registry
  -> SSH deployment
  -> Linux VPS
       -> Caddy :80/:443
       -> api-production:8080
       -> api-staging:8080
```

Một VPS chạy hai API container tách biệt và một Caddy container dùng chung. Chỉ Caddy mở cổng 80/443;
API chỉ nằm trong Docker network. Caddy cấp HTTPS và chuyển request theo domain. Image triển khai dùng tag commit
SHA để có thể chạy lại workflow thủ công với image cũ khi cần rollback. Caddy được ghim theo version và digest;
CI render Compose và chạy `caddy validate` trước khi publish application image.

## Điều kiện trên Linux host

- Linux server có public IP; khuyến nghị một bản phân phối còn được hỗ trợ.
- Docker Engine và Docker Compose plugin được cài theo
  [hướng dẫn Docker chính thức](https://docs.docker.com/engine/install/).
- `curl` có trong `PATH` để chạy health check sau deploy.
- Firewall cho phép SSH, TCP 80, TCP/UDP 443.
- Deploy user đăng nhập được bằng SSH key và có quyền chạy Docker.
- Hai DNS A/AAAA record trỏ production và staging domain về server trước lần deploy đầu.

Không dùng root password trong GitHub. Tạo SSH key riêng cho deployment và giới hạn quyền của deploy user ở mức
cần thiết. Thành viên nhóm `docker` có quyền gần tương đương root trên host; chỉ cấp cho tài khoản deployment được
quản lý.

## Chuẩn bị cấu hình trên server

Chạy workflow `deploy-linux` thủ công với `sync_only=true` để upload các file trong `deploy/linux/` đến
`DEPLOY_PATH` mà không thay đổi container. Sau đó đăng nhập server và tạo file cấu hình không commit:

```bash
cd /opt/labx
cp deploy.env.example deploy.env
nano deploy.env
chmod 600 deploy.env
```

Điền đầy đủ:

```dotenv
PRODUCTION_IMAGE_REF=ghcr.io/dat23052004/stm-be:main
STAGING_IMAGE_REF=ghcr.io/dat23052004/stm-be:develop
PRODUCTION_DOMAIN=api.your-domain.com
STAGING_DOMAIN=staging-api.your-domain.com
PRODUCTION_CORS_ORIGIN=https://your-frontend.com
STAGING_CORS_ORIGIN=https://staging.your-frontend.com
ACME_EMAIL=your-email@example.com
```

`deploy.env` đã nằm trong `.gitignore` và `.dockerignore`. Không đặt password, SSH private key hoặc GHCR token
trong file này.

Nếu GHCR package để private, đăng nhập registry một lần trên server bằng token chỉ có `read:packages`:

```bash
docker login ghcr.io
```

Không ghi token vào script hoặc repository. Nếu package được chuyển sang public thì host có thể pull không cần
registry credential.

## GitHub Environments

Tạo hai environment trong `Settings -> Environments`:

```text
staging
production
```

Trong mỗi environment, cấu hình variables:

```text
APP_DOMAIN    Domain tương ứng để GitHub hiển thị deployment URL
DEPLOY_HOST   IP hoặc hostname của Linux VPS
DEPLOY_PORT   SSH port, thường là 22
DEPLOY_USER   Tài khoản deployment
DEPLOY_PATH   /opt/labx
```

Thêm environment secrets:

```text
DEPLOY_SSH_KEY      Private key riêng cho GitHub Actions
DEPLOY_KNOWN_HOSTS  Dòng known_hosts đã xác minh của server
```

Lấy known-host entry từ máy tin cậy và đối chiếu fingerprint với server trước khi lưu:

```bash
ssh-keyscan -H -p 22 your-server.example.com
```

Không chấp nhận host key mới tự động trong workflow. Production environment nên bật required reviewers để việc
deploy chờ phê duyệt.

## Bật tự động triển khai

Tạo repository variables trong `Settings -> Secrets and variables -> Actions -> Variables`:

```text
STAGING_DEPLOY_ENABLED=true
PRODUCTION_DEPLOY_ENABLED=true
```

Để `false` hoặc chưa tạo biến thì job tương ứng bị skip. Nhờ đó CI và publish image vẫn chạy trong thời gian chưa
điền xong server/domain/secrets.

- Push `develop`: CI -> publish image SHA + tag `develop` -> deploy staging.
- Push `main`: CI -> publish image SHA + tag `main` -> chờ production approval -> deploy production.
- Pull request: chỉ chạy CI, không publish hoặc deploy.

GitHub Actions dùng `GITHUB_TOKEN` với quyền `packages: write` để publish
`ghcr.io/dat23052004/stm-be`. Image có nhãn liên kết về repository.

## Deploy thủ công và rollback

Workflow `deploy-linux` cho phép chọn `staging` hoặc `production` và nhập image cũ:

```text
ghcr.io/dat23052004/stm-be:<commit-sha>
```

Script cập nhật đúng slot, pull image, restart container và gọi `https://<domain>/health/ready`. Nếu health check
không trả 200 trong khoảng một phút, script khôi phục image reference trước và khởi động lại container cũ.

## Việc cần kiểm tra sau lần deploy đầu

```bash
cd /opt/labx
docker compose --project-name labx --env-file deploy.env --file compose.yml ps
docker compose --project-name labx --env-file deploy.env --file compose.yml logs --tail 100
curl --fail https://api.your-domain.com/health/ready
curl --fail https://staging-api.your-domain.com/health/ready
```

Caddy data được giữ trong named volume `caddy_data`; không xóa volume này tùy tiện vì chứa certificate và TLS
state. Log container không chứa request body hoặc authorization header theo cấu hình hiện tại của API.
