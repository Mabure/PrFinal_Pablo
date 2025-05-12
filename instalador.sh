#!/bin/bash
# init_structure.sh

# Colores
VERDE='\033[0;32m'
AZUL='\033[1;34m'
AMARILLO='\033[1;33m'
NC='\033[0m' # Sin color

mkdir -p raw_data scripts db exports
echo "Directorios creados correctamente."

#Crear script para crear DB
echo '
#!/bin/bash

# Detectar en qué directorio estás actualmente
CURRENT_DIR=$(basename "$PWD")

# Definir la ruta de la base de datos según el directorio actual
if [[ "$CURRENT_DIR" == "scripts" ]]; then
    DB_PATH="../db/cafeteria.db"
else
    DB_PATH="db/cafeteria.db"
fi

sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    email TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    precio REAL NOT NULL
);

CREATE TABLE IF NOT EXISTS pedidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER,
    producto_id INTEGER,
    fecha TEXT,
    FOREIGN KEY(cliente_id) REFERENCES clientes(id),
    FOREIGN KEY(producto_id) REFERENCES productos(id)
);
EOF

echo "Base de datos creada en $DB_PATH"
' > scripts/create_db.sh

#Crear script para realizar las consultas
echo '
#!/bin/bash

DB_PATH="../db/cafeteria.db"
EXPORT_DIR="../exports"

echo "Selecciona una consulta:"
echo "1) Listar todos los clientes"
echo "2) Listar pedidos con nombres de productos"
echo "3) Ventas totales por producto"
read -p "Opción (1-3): " opcion

case $opcion in
    1)
        sqlite3 -json "$DB_PATH" "SELECT * FROM clientes;" > "$EXPORT_DIR/clientes.json"
        echo "Consulta exportada a clientes.json"
        ;;
    2)
        sqlite3 -json "$DB_PATH" "
            SELECT pedidos.id, clientes.nombre AS cliente, productos.nombre AS producto, pedidos.fecha 
            FROM pedidos 
            JOIN clientes ON pedidos.cliente_id = clientes.id 
            JOIN productos ON pedidos.producto_id = productos.id;" > "$EXPORT_DIR/pedidos.json"
        echo "Consulta exportada a pedidos.json"
        ;;
    3)
        sqlite3 -json "$DB_PATH" "
            SELECT productos.nombre, COUNT(*) AS cantidad, SUM(productos.precio) AS total 
            FROM pedidos 
            JOIN productos ON pedidos.producto_id = productos.id 
            GROUP BY productos.id;" > "$EXPORT_DIR/ventas_por_producto.json"
        echo "Consulta exportada a ventas_por_producto.json"
        ;;
    *)
        echo "Opción inválida"
        ;;
esac
' > scripts/consultas.sh

#Crear script para pasar de datos crudos a la base de datos
echo '
#!/bin/bash

DB_PATH="../db/cafeteria.db"
DATA_DIR="../raw_data"

echo "Archivos disponibles:"
ls "$DATA_DIR"
read -p "Nombre del archivo CSV (ej: clientes.csv): " archivo
read -p "Nombre de la tabla destino (clientes, productos o pedidos): " tabla

csv_path="$DATA_DIR/$archivo"

if [[ ! -f "$csv_path" ]]; then
    echo "Archivo no encontrado."
    exit 1
fi

# Importar el CSV usando cabecera como nombres de columnas
sqlite3 "$DB_PATH" <<EOF
.mode csv
.separator ","
.import $csv_path $tabla
EOF

echo "Datos importados en la tabla $tabla."
' > scripts/csv_db.sh

#Crear script para pasar la base de datos a csv
echo '
#!/bin/bash

DB_PATH="../db/cafeteria.db"
EXPORT_DIR="../exports"

for tabla in clientes productos pedidos; do
    sqlite3 "$DB_PATH" <<EOF
.headers on
.mode csv
.output $EXPORT_DIR/${tabla}.csv
SELECT * FROM $tabla;
EOF
    echo "Tabla $tabla exportada a ${tabla}.csv"
done
' > scripts/db_csv.sh

chmod +x scripts/*.sh

echo -e "${VERDE} Instalación finalizada.${NC}"
echo -e "${AZUL} Puedes ejecutar los scripts desde la carpeta ${AMARILLO}/scripts${NC}"

echo
read -n1 -p "$(echo -e "${AMARILLO}Deseas crear la base de datos ahora? (s/n): ${NC}")" RESPUESTA
echo

if [[ "$RESPUESTA" =~ ^[sS]$ ]]; then
    echo -e "${AZUL}Creando base de datos...${NC}"
    bash ./scripts/create_db.sh
    echo -e "${VERDE} Base de datos creada correctamente.${NC}"
else
    echo -e "${AMARILLO} Puedes crearla mas tarde ejecutando: bash scripts/create_db.sh${NC}"
fi