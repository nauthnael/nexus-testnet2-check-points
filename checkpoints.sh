#!/bin/bash

# Kiểm tra xem jq đã được cài đặt chưa
if ! command -v jq &> /dev/null; then
  echo "Lỗi: Công cụ 'jq' chưa được cài đặt. Vui lòng cài đặt 'jq' trước khi chạy script."
  echo "Hướng dẫn cài đặt:"
  echo "- Trên Ubuntu/Debian: sudo apt install -y jq"
  echo "- Trên CentOS/RHEL: sudo yum install -y jq"
  echo "- Trên macOS: brew install jq"
  exit 1
fi

# Kiểm tra xem người dùng đã cung cấp địa chỉ ví chưa
if [[ -z "$1" ]]; then
  echo "Vui lòng cung cấp địa chỉ ví Nexus làm tham số."
  echo "Ví dụ: curl <URL> | bash -s YOUR_WALLET_ADDRESS"
  exit 1
fi

WALLET="$1"

# URL để gửi request
URL="https://beta.orchestrator.nexus.xyz/users/${WALLET}"

# Headers cho request
HEADERS=(
  -H "Accept: application/json"
  -H "Accept-Language: en-US,en;q=0.9,vi;q=0.8"
  -H "Connection: keep-alive"
  -H "Content-Type: application/json"
  -H "Origin: https://app.nexus.xyz"
  -H "Referer: https://app.nexus.xyz/"
)

# Hàm để gửi request và xử lý response
fetch_data() {
  for ((i = 1; i <= 100; i++)); do
    echo "Thử lần #$i..."

    # Gửi request và nhận response
    RESPONSE=$(curl -s "${URL}" "${HEADERS[@]}")
    echo "Response:"
    echo "$RESPONSE"

    # Kiểm tra nếu response là JSON hợp lệ và chứa dữ liệu nodes không rỗng
    if echo "$RESPONSE" | jq -e '.data.nodes | length > 0' >/dev/null 2>&1; then
      # Kiểm tra nếu walletAddress trong JSON khớp với địa chỉ ví đã nhập
      RESPONSE_WALLET=$(echo "$RESPONSE" | jq -r '.data.walletAddress')
      if [[ "$RESPONSE_WALLET" == "$WALLET" ]]; then
        echo "Success! Dữ liệu JSON hợp lệ và chứa đúng walletAddress."
        echo "$RESPONSE" > response.json  # Lưu response vào file tạm thời để debug
        break
      else
        echo "Lỗi: walletAddress trong JSON không khớp với địa chỉ ví đã nhập."
        echo "walletAddress trong JSON: $RESPONSE_WALLET"
        echo "Địa chỉ ví đã nhập: $WALLET"
      fi
    else
      echo "Lỗi: Phản hồi không hợp lệ hoặc không chứa dữ liệu nodes."
      echo "Phản hồi lỗi:"
      echo "$RESPONSE"
    fi

    # Đợi 4 giây trước khi thử lại
    sleep 4
  done
}

# Gọi hàm fetch_data để lấy dữ liệu
fetch_data

# Đọc response từ file tạm thời (hoặc sử dụng biến RESPONSE)
if [[ -f "response.json" ]]; then
  RESPONSE=$(cat response.json)
else
  echo "Lỗi: Không thể lấy dữ liệu từ API sau 100 lần thử."
  exit 1
fi

# Lọc và xử lý dữ liệu
WEB_NODE_POINTS=0
CLI_NODE_POINTS=0
TOTAL_POINTS=0

echo "Danh sách các node có điểm testnet_two_points > 0:"
echo "-----------------------------------------------"
echo "$RESPONSE" | jq -r '.data.nodes[] | select(.testnet_two_points > 0) | [.id, .nodeType, .testnet_two_points] | @tsv' | while IFS=$'\t' read -r ID NODE_TYPE POINTS; do
  # Xác định loại node
  if [[ "$NODE_TYPE" == "1" ]]; then
    NODE_TYPE_NAME="Web node"
    WEB_NODE_POINTS=$((WEB_NODE_POINTS + POINTS))
  elif [[ "$NODE_TYPE" == "2" ]]; then
    NODE_TYPE_NAME="CLI node"
    CLI_NODE_POINTS=$((CLI_NODE_POINTS + POINTS))
  fi

  # Cập nhật tổng số điểm
  TOTAL_POINTS=$((TOTAL_POINTS + POINTS))

  # Hiển thị thông tin node
  echo "ID: $ID, Loại: $NODE_TYPE_NAME, Điểm: $POINTS"
done

# Hiển thị tổng số điểm theo loại node và tổng tất cả điểm
echo "-----------------------------------------------"
echo "Tổng số điểm Web node: $WEB_NODE_POINTS"
echo "Tổng số điểm CLI node: $CLI_NODE_POINTS"
echo "Tổng tất cả điểm: $TOTAL_POINTS"
