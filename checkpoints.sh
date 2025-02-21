#!/bin/bash

# Yêu cầu người dùng nhập địa chỉ ví Nexus
read -p "Nhập địa chỉ ví Nexus của bạn: " WALLET

# Kiểm tra xem người dùng đã nhập địa chỉ ví chưa
if [[ -z "$WALLET" ]]; then
  echo "Bạn chưa nhập địa chỉ ví. Vui lòng thử lại."
  exit 1
fi

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

# Hàm để kiểm tra nodeType:2 và lấy ID
extract_id_from_response() {
  local response="$1"
  # Sử dụng grep và regex để lọc ra ID có 7 chữ số từ nodeType:2
  echo "$response" | grep -oP '(?<="nodeType":2,"id":")\d{7}'
}

# Vòng lặp thử nghiệm tối đa 100 lần
for ((i=1; i<=100; i++)); do
  echo "Thử lần #$i"

  # Gửi request và nhận response
  RESPONSE=$(curl -s "${URL}" "${HEADERS[@]}")
  
  # Hiển thị toàn bộ kết quả JSON nhận được
  echo "Kết quả JSON nhận được:"
  echo "$RESPONSE"

  # Kiểm tra nếu response không chứa "Gateway"
  if [[ "$RESPONSE" != *"Gateway"* ]]; then
    echo "Success! Breaking the loop."

    # Lấy ID từ response
    ID=$(extract_id_from_response "$RESPONSE")
    if [[ -n "$ID" ]]; then
      echo "Đã tìm thấy ID với nodeType:2 -> ID: $ID"
      break
    else
      echo "Không tìm thấy ID hợp lệ với nodeType:2 trong kết quả JSON."
    fi
  else
    echo "Response chứa 'Gateway'. Thử lại sau 1 giây..."
  fi

  # Đợi 1 giây trước khi thử lại
  sleep 1
done
