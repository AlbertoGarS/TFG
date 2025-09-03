#!/bin/bash
set -euo pipefail

# Lista de carpetas
case_folders=(

    simpleFoam192AoA0
    simpleFoam192AoA2
    simpleFoam192AoA4
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

for case_name in "${case_folders[@]}"; do
    echo ">>> Running case: $case_name"
    cd "$case_name"

    # Permitir y ejecutar Allclean si existe
    if [[ -f Allclean ]]; then
        chmod +x Allclean || true
        echo ">>> Ejecutando ./Allclean"
        ./Allclean
    else
        echo ">>> No se encontró Allclean (continuo igualmente)"
    fi

    # Limpiar antes de descomponer
    echo ">>> Limpiando restos: processor*, postProcessing, dynamicCode"
    rm -rf processor* postProcessing dynamicCode || true

    # Guardar log para cada paso con el nombre de la carpeta
    echo ">>> decomposePar"
    decomposePar > "log.decomposePar_${case_name}" 2>&1

    echo ">>> renumberMesh -parallel -overwrite"
    mpirun -np 8 renumberMesh -parallel -overwrite > "log.renumber_${case_name}" 2>&1

    echo ">>> simpleFoam -parallel"
    mpirun -np 8 simpleFoam -parallel > "log.simpleFoam_${case_name}" 2>&1

    echo ">>> reconstructPar"
    reconstructPar > "log.reconstructPar_${case_name}" 2>&1

    echo ">>> Done: $case_name"
    cd ..
done

echo "All cases completed successfully."