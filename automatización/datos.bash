#!/bin/bash
set -euo pipefail

# Lista de carpetas
case_folders=(
    simpleFoam192AoA0
    simpleFoam192AoA2
    simpleFoam192AoA4
    simpleFoam192AoA5
    simpleFoam192AoA6
    simpleFoam192AoA8
    simpleFoam192AoA10
    simpleFoam192AoA12
    simpleFoam192AoA14
    simpleFoam192AoA15
    simpleFoam192AoA16
    simpleFoam192AoA18
    simpleFoam192AoA20
)

# Archivo de salida
output_file="resumen_forceCoeffs.txt"
: > "$output_file"     # Vaciar o crear

for case_name in "${case_folders[@]}"; do
    # Busca el fichero más reciente tipo forceCoeffs* dentro de postProcessing
    file_path=$(ls -1t "${case_name}"/postProcessing/forceCoeffs*/[0-9]*/forceCoeffs* 2>/dev/null | head -n1 || true)

    if [[ -n "${file_path:-}" && -f "$file_path" ]]; then
        # Última línea con datos (sin comentarios)
        last_line=$(grep -v '^#' "$file_path" | tail -n 1)
        printf "%s %s\n" "$case_name" "$last_line" >> "$output_file"
    else
        printf "%s %s\n" "$case_name" "Archivo no encontrado" >> "$output_file"
    fi
done

echo "Resumen guardado en $output_file"
