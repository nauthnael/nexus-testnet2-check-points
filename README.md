### **1. Cập nhật `README.md`**

```markdown
# Nexus Testnet 2 Checkpoints Script

Script này được sử dụng để tự động gửi request đến API của Nexus Testnet 2 và lọc ra ID có `nodeType:2` từ kết quả JSON trả về.

## Yêu cầu hệ thống
- Hệ điều hành: Linux, macOS hoặc Windows (với WSL).
- Công cụ: `curl`, `grep`.

## Cách sử dụng

### 1. Tải script về máy
Bạn có thể tải script này bằng lệnh `curl` hoặc `wget`:

#### Sử dụng `curl`:
```bash
curl -o checkpoints.sh https://raw.githubusercontent.com/nauthnael/nexus-testnet2-check-points/main/checkpoints.sh
```

#### Sử dụng `wget`:
```bash
wget -O checkpoints.sh https://raw.githubusercontent.com/nauthnael/nexus-testnet2-check-points/main/checkpoints.sh
```

### 2. Cấp quyền thực thi
Sau khi tải về, cấp quyền thực thi cho script:
```bash
chmod +x checkpoints.sh
```

### 3. Chạy script
Chạy script bằng lệnh sau:
```bash
./checkpoints.sh
```

Script sẽ yêu cầu bạn nhập địa chỉ ví Nexus, sau đó tự động gửi request và hiển thị kết quả JSON. Nếu tìm thấy ID hợp lệ với `nodeType:2`, script sẽ in ra ID đó.

## Lưu ý
- Đảm bảo rằng bạn đã cài đặt `curl` và `grep` trên hệ thống.
- Nếu gặp lỗi, vui lòng kiểm tra kết nối mạng và đảm bảo địa chỉ ví Nexus bạn nhập là chính xác.

## Đóng góp
Nếu bạn muốn đóng góp hoặc báo cáo lỗi, vui lòng tạo một issue trong repository này.

## License
MIT License
```
