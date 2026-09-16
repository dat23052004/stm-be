# Cấu hình và vận hành local

Config chung trong `src/Api/appsettings.json`; override theo `appsettings.{Environment}.json`,
user-secrets ở Development và biến môi trường. Biến dạng nested dùng `__`.
Hiện chỉ cần `appsettings.Development.json` để override CORS. Staging/Production kế thừa cấu hình chung;
chỉ thêm file môi trường khi có giá trị khác thực tế.

```powershell
$env:Cors__AllowedOrigins__0 = 'https://frontend.example.com'
dotnet run --project src/Api --launch-profile http
```

Launch profile `http` đặt Development và cổng 5033; `https` thêm HTTPS cổng 7024, cần certificate local hợp lệ.
Khi chạy Production local, dùng `--no-launch-profile` để không bị profile ghi đè environment.

```powershell
$env:ASPNETCORE_ENVIRONMENT = 'Production'
dotnet run --project src/Api --no-launch-profile --urls http://localhost:5033
```

- Base chưa có secret bắt buộc. `UserSecretsId` đã sẵn sàng cho cấu hình cần bảo mật khi có feature.
- ASP.NET Core không tự nạp `.env` trong cấu hình hiện tại; đặt biến môi trường trực tiếp.
- Docker Compose khai báo biến trong `compose.yaml`; muốn thêm biến cần khai báo rõ cho service.
- CORS chỉ ảnh hưởng browser, không thay thế authentication/authorization.
- Host HTTP hiện cho phép truy cập local/container; cấu hình TLS tại host hoặc reverse proxy trước khi triển khai.
- Không bật forwarded headers nếu chưa định nghĩa proxy đáng tin cậy.
- OpenAPI JSON chỉ bật ở Development; chưa cài Swagger UI.
- Root và health hiện public. `/health/ready` chưa có kiểm tra DB/external dependency.

CI đã cấu hình locked restore/NuGet audit, format, build/test, HTTP smoke, Docker build và Trivy scan;
chưa có deploy workflow hoặc production secrets. Xem [cách chạy kiểm tra](verification.md).
