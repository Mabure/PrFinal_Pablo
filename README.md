# Automatización de Base de Datos para Cafetería

Este proyecto contiene una serie de scripts bash para automatizar la gestión de una base de datos SQLite en un servidor Ubuntu. La base de datos gestiona pedidos de una cafetería y permite importar/exportar datos fácilmente.

## Estructura de Carpetas

- `/raw_data/`: Carpeta donde se colocan los archivos CSV de entrada.
- `/scripts/`: Carpeta donde se guardan todos los scripts `.sh`.
- `/db/`: Carpeta donde se crea la base de datos `cafeteria.db`.
- `/exports/`: Carpeta donde se exportan resultados en formato JSON o CSV.

## Scripts Incluidos

### `init_structure.sh`
Crea las carpetas necesarias para organizar el proyecto.
./scripts/instalador.sh

create_db.sh
Crea una base de datos SQLite con tres tablas: clientes, productos y pedidos.
./scripts/create_db.sh

csv_db.sh
Importa un archivo CSV desde /raw_data/ a la tabla especificada de la base de datos.
./scripts/csv_db.sh

consultas.sh
Permite al usuario elegir entre 3 consultas SQL y exporta los resultados a archivos JSON en /exports/.
./scripts/consultas.sh

db_csv.sh
Exporta todas las tablas de la base de datos a archivos CSV en la carpeta /exports/.
./scripts/db_csv.sh

RequisitosUbuntu Server
sqlite3 instalado:
sudo apt install sqlite3
Notas
Asegúrate de dar permisos de ejecución a los scripts:

chmod +x ./scripts/*.sh
