#!/bin/bash

# Kiểm tra xem người dùng đã cung cấp địa chỉ ví chưa
if [[ -z "$1" ]]; then
  echo "Vui lòng cung cấp địa chỉ ví Nexus làm tham số."
  echo "Ví dụ: curl <URL> | sh -s YOUR_WALLET_ADDRESS"
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

# Gửi request và nhận response
RESPONSE=$(curl -s "${URL}" "${HEADERS[@]}")

# Hiển thị toàn bộ kết quả JSON nhận được
echo "Kết quả JSON nhận được:"
echo "$RESPONSE"

# Lọc và xử lý dữ liệu
WEB_NODE_POINTS=0
CLI_NODE_POINTS=0
TOTAL_POINTS=0

# Sử dụng jq để phân tích JSON
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
