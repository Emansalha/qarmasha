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

# خط Tajawal العربي (Google Fonts — رخصة OFL)
mkdir -p assets/fonts
for w in Regular Medium Bold ExtraBold Black; do
  out="assets/fonts/Tajawal-${w}.ttf"
  [ -s "$out" ] && continue
  curl -fsSL -o "$out" "https://raw.githubusercontent.com/google/fonts/main/ofl/tajawal/Tajawal-${w}.ttf"
  echo "OK $out ($(stat -c%s "$out") bytes)"
done
