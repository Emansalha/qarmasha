#!/usr/bin/env bash
# يحمّل صور الأطعمة (Pexels — رخصة مجانية للاستخدام التجاري) إلى assets/images
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p assets/images
while read -r name id; do
  [ -z "${name:-}" ] && continue
  out="assets/images/${name}.jpg"
  [ -s "$out" ] && continue
  curl -fsSL -A "Mozilla/5.0" -o "$out" \
    "https://images.pexels.com/photos/${id}/pexels-photo-${id}.jpeg?auto=compress&cs=tinysrgb&w=1000&h=800&fit=crop"
  echo "OK $out ($(stat -c%s "$out") bytes)"
done < scripts/images.txt
