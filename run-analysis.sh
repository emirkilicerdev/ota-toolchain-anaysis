#!/bin/bash
# =============================================================================
# BIL 304 - Part 2: Toplu Firmware Analiz Betigi
# -----------------------------------------------------------------------------
# firmware-samples/ icindeki tum firmware dosyalarini, uzantilarina gore dogru
# araç zinciri (toolchain) ile analiz eder ve ciktilari analysis-output/'a doker.
#
#   .z1 / .sky    -> MSP430 toolchain   (msp430-*)
#   .simplelink   -> ARM toolchain      (arm-none-eabi-*)
#   .cooja        -> native x86-64      (standart GNU binutils)
#
# Kullanim (Docker konteyneri icinde):
#   bash run-analysis.sh [firmware-dizini] [cikti-dizini]
# =============================================================================
set -u

FW_DIR="${1:-firmware-samples}"
OUT_DIR="${2:-analysis-output}"
ARM_BIN="/opt/arm/gcc-arm-none-eabi-9-2020-q2-update/bin"

mkdir -p "$OUT_DIR"

for fw in "$FW_DIR"/*; do
  [ -f "$fw" ] || continue
  base=$(basename "$fw")
  ext="${base##*.}"

  # Uzantiya gore arac ailesini (prefix) sec
  case "$ext" in
    z1|sky)      P="msp430-" ;;
    simplelink)  P="$ARM_BIN/arm-none-eabi-" ;;
    cooja)       P="" ;;
    *)           echo "ATLANDI (bilinmeyen uzanti): $base"; continue ;;
  esac

  echo ">>> Analiz: $base   (toolchain prefix: '${P:-native}')"

  # NOT: cikti isimleri buyuk/kucuk harf cakismasini onleyecek sekilde secildi
  # (Windows dosya sistemi case-insensitive: readelf-S ile readelf-s cakisirdi)
  ${P}readelf -h            "$fw" > "$OUT_DIR/$base.elf-header.txt"  2>&1
  ${P}readelf -S            "$fw" > "$OUT_DIR/$base.sections.txt"    2>&1
  ${P}readelf -l            "$fw" > "$OUT_DIR/$base.segments.txt"    2>&1
  ${P}readelf -s            "$fw" > "$OUT_DIR/$base.symtab.txt"      2>&1
  ${P}size                  "$fw" > "$OUT_DIR/$base.size.txt"        2>&1
  ${P}nm -n                 "$fw" > "$OUT_DIR/$base.nm.txt"          2>&1
  ${P}objdump -h            "$fw" > "$OUT_DIR/$base.obj-headers.txt" 2>&1
  ${P}objdump -d            "$fw" > "$OUT_DIR/$base.disasm.txt"      2>&1
  ${P}strings               "$fw" > "$OUT_DIR/$base.strings.txt"     2>&1
  ${P}objdump -d -j .vectors "$fw" > "$OUT_DIR/$base.vectors.txt"    2>&1
done

echo ""
echo "=== TAMAMLANDI. Uretilen cikti dosyasi: $(ls "$OUT_DIR" | wc -l) ==="
