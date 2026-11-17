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

# أيقونات ثلاثية الأبعاد (Microsoft Fluent Emoji — رخصة MIT)
mkdir -p assets/icons
while IFS='|' read -r name folder; do
  [ -z "${name:-}" ] && continue
  out="assets/icons/${name}.png"
  [ -s "$out" ] && continue
  file="$(echo "$folder" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')_3d.png"
  url="https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/${folder// /%20}/3D/${file}"
  if curl -fsSL -o "$out" "$url"; then
    echo "OK $out"
  else
    rm -f "$out"; echo "MISSING $name ($folder)"
  fi
done < scripts/icons.txt
