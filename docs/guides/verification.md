# Kiểm tra base tại local và CI

## Công cụ

- .NET 9 SDK 9.0.300 hoặc bản vá mới hơn cùng feature band, theo `global.json`.
- Cài SDK toàn máy từ [Microsoft](https://dotnet.microsoft.com/en-us/download/dotnet/9.0).
- Trivy 0.74.0 từ [release chính thức](https://github.com/aquasecurity/trivy/releases/tag/v0.74.0).
  Chỉ cần khi chạy security scan local; đặt executable trong `PATH`.
- Docker Engine hoạt động khi build/quét image. Restore/audit và cập nhật Trivy DB cần mạng.

## Quy trình

Từ repository root:

```powershell
./scripts/verify.ps1
./scripts/smoke-test.ps1
docker build -t backend-api:local .
./scripts/smoke-test.ps1 -Image backend-api:local
./scripts/security-check.ps1 -Image backend-api:local
```

- Verify: locked restore → NuGet audit → format/analyzer check → build Release → tests và coverage.
  `NuGetAuditMode=all`, mức `low`, warnings-as-errors: lỗ hổng NuGet trực tiếp/gián tiếp hoặc lỗi audit
  làm bước restore thất bại. Không tắt audit để chạy offline rồi gọi kết quả đó là đã quét.
- Smoke: chạy DLL trong tiến trình riêng, kiểm tra root, health và OpenAPI;
  script dừng tiến trình do chính nó khởi động khi hoàn tất.
  Với `-Image`, cùng bộ kiểm tra chạy trên container tạm ở Development, bind cổng vào loopback;
  script lưu log và dừng container do nó tạo sau khi kiểm tra.
- Security: Trivy quét repository gồm lockfiles và secrets. Khi truyền `-Image`, quét thêm image.
  HIGH/CRITICAL làm lệnh thất bại; lỗi tải DB hoặc lỗi scanner cũng làm thất bại.
  Không bỏ qua lỗ hổng chưa có bản sửa. Kết quả sạch chỉ áp dụng phạm vi/ngưỡng và DB tại thời điểm quét.
- `./scripts/security-check.ps1` không có `-Image` chỉ quét repository.

Kết quả test/coverage ở `artifacts/test-results/`; log smoke ở `artifacts/smoke/`;
Trivy JSON ở `artifacts/security/repository.json` và `image.json` khi có quét image.
Giữ báo cáo scan trong phạm vi nhóm vì có thể chứa thông tin source cần hạn chế chia sẻ.
Khi các project test còn trống, bước test chỉ xác nhận runner chạy thành công và phải được báo là 0 test case.

## Khi đổi dependency

Sửa phiên bản tập trung trong `Directory.Packages.props`, rồi chạy:

```powershell
./scripts/verify.ps1 -UpdateLockFile
./scripts/verify.ps1
```

Đọc thay đổi của từng `packages.lock.json` trước khi chấp nhận. Docker cũng restore với `--locked-mode`.
Không dùng `-UpdateLockFile` trong CI; sai khác dependency phải được phát hiện và sửa tại source.
Giữ target .NET 9 theo yêu cầu; không tự nâng major. Kiểm tra lịch hỗ trợ và bản vá định kỳ tại
[chính sách .NET](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core).

## CI trên GitHub

`.github/workflows/build-test.yml` chạy cùng các script bằng PowerShell 7 trên Ubuntu, build image,
quét repository/image và upload bằng chứng. Actions ghim bằng commit SHA;
`.github/dependabot.yml` chuẩn bị cập nhật NuGet, Docker và Actions hàng tuần.
SDK trong global.json và phiên bản Trivy vẫn cần cập nhật có kiểm soát.
Workflow đang hoạt động tại [GitHub Actions](https://github.com/dat23052004/stm-be/actions) và được kích hoạt bởi
pull request, push vào `main`/`develop` hoặc `workflow_dispatch`. Dependabot bỏ qua bản nâng major của Docker image
.NET để giữ target .NET 9. Mỗi pull request cập nhật vẫn phải được review; CI pass không tự động cho phép merge.

Sau khi CI pass trên `main` hoặc `develop`, workflow publish image theo commit SHA và tag branch lên GHCR. Các job
deploy Linux chỉ chạy khi repository variable của môi trường bằng `true`; khi chưa điền host/domain/secrets chúng
bị skip và không làm CI thất bại. Xem [hướng dẫn Linux](linux-deployment.md) để cấu hình GitHub Environments,
automatic deployment, health check và rollback.

## Runtime image

Dockerfile ghim cả version và digest. Runtime dùng .NET 9 Ubuntu Noble chiseled-extra của Microsoft,
giảm công cụ hệ điều hành không cần cho API; biến thể extra giữ ICU/tzdata cho globalization.
Image này không có shell/package manager, nên kiểm tra bằng HTTP và công cụ từ host.
Tham khảo [các biến thể image chính thức](https://learn.microsoft.com/en-us/dotnet/core/docker/container-images).
Khi nâng phiên bản/digest, build và quét lại; kết quả scan không áp dụng vĩnh viễn cho tag.
