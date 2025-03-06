#!/bin/bash

# Solicitud del archivo
echo "Introduce la ruta del archivo:"
read filepath

# Validación de la existencia del archivo
if [ ! -f "$filepath" ]; then
    echo "Error: El archivo no existe."
    exit 1
fi

# Obtener el nombre del archivo y su extensión
filename=$(basename -- "$filepath")
extension="${filename##*.}"

# Detección del lenguaje basado en la extensión
case $extension in
    py)
        language="python"
        dockerfile="Dockerfile_python"
        ;;
    java)
        language="java"
        dockerfile="Dockerfile_java"
        ;;
    cpp|cc)
        language="cpp"
        dockerfile="Dockerfile_cpp"
        ;;
    js)
        language="js"
        dockerfile="Dockerfile_js"
        ;;
    rb)
        language="ruby"
        dockerfile="Dockerfile_ruby"
        ;;
    *)
        echo "Error: Lenguaje no soportado."
        exit 1
        ;;
esac

# Crear un directorio temporal para copiar el archivo
temp_dir=$(mktemp -d)
cp "$filepath" "$temp_dir/$filename"

# Construcción del contenedor con el nombre del archivo como argumento
echo "Construyendo el contenedor..."
if ! docker build -t $language-container -f $dockerfile --build-arg FILENAME=$filename "$temp_dir"; then
    echo "Error: Fallo al construir el contenedor."
    rm -rf "$temp_dir"
    exit 1
fi

# Ejecución del contenedor y captura del tiempo
echo "Ejecutando el contenedor..."
start_time=$(date +%s%N)
output=$(docker run --rm $language-container 2>&1)
end_time=$(date +%s%N)

# Cálculo del tiempo de ejecución en milisegundos
execution_time=$(( (end_time - start_time) / 1000000 ))

# Guardar la salida en un archivo .txt
output_file="${filename%.*}_output.txt"
echo "$output" > "$output_file"

# Limpiar el directorio temporal
rm -rf "$temp_dir"

# Salida en consola
echo "Salida del programa:"
echo "$output"
echo "Tiempo de ejecución: $execution_time ms"
echo "La salida se ha guardado en: $output_file"