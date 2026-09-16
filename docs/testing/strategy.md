# Chiến lược kiểm thử

## Các cấp độ

- Unit: dành cho logic cô lập, không khởi động host/DB.
- Integration: dành cho HTTP pipeline bằng WebApplicationFactory và tích hợp với dependency đã chọn.
- Architecture: dành cho guard project references và dependency framework giữa các layer.
- System: workflow xuyên module/môi trường thực; chỉ thực hiện khi có nghiệp vụ và môi trường test được xác định.

Ba project test hiện là scaffold trống: chưa có test case, fixture hoặc kết quả Passed/Failed.
Base chưa có DB nên chưa có kiểm chứng persistence.

Không đặt tỷ lệ coverage tùy ý hoặc tạo test getter để tăng số lượng. Dùng coverage để tìm luồng quan trọng chưa kiểm tra.

## Lệnh

```powershell
./scripts/verify.ps1
dotnet test tests/UnitTests -c Release --no-build
dotnet test tests/IntegrationTests -c Release --no-build
dotnet test tests/ArchitectureTests -c Release --no-build
```

TRX và Cobertura được ghi vào `artifacts/test-results/` bằng script verify và CI.
`verify.ps1` dùng locked restore có NuGet audit và kiểm tra format trước khi build/test.
`security-check.ps1` lưu báo cáo quét vào `artifacts/security/`; xem [hướng dẫn](../guides/verification.md).
Đọc output thực tế trước khi báo Passed. Khi project chưa có test case, báo rõ 0 test thay vì coi là đã pass hành vi.

## Khi có database/auth

Chọn DB test riêng, reset dữ liệu deterministic, không dùng connection string production.
Kiểm tra constraint, transaction, concurrency và migration với đúng provider.
Thêm test 401/403, ownership, permission và token/cookie expiration theo contract đã chọn.
Đăng ký dependency health checks cho readiness; liveness tiếp tục chỉ kiểm tra tiến trình.

Test plan dùng `docs/templates/test-plan.md`; báo cáo dùng `docs/templates/test-report.md`.
