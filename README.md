# Base de Datos Privium

Este repositorio contiene los scripts SQL utilizados para crear y poblar la base de datos del proyecto **Privium**. Incluye las definiciones de tablas, procedimientos almacenados y algunos datos iniciales.

## Estructura del repositorio

- **`Tables/`**: scripts para la creación de todas las tablas.
- **`SPs/`**: procedimientos almacenados organizados por tipo.
  - `CategoriesSps`
  - `CountriesSps`
  - `ListingsSps`
  - `UserSps`
- **`Data/`**: carga opcional de datos (categorías y países).

## Uso

1. Ejecutar primero todos los archivos de `Tables/` para crear las tablas.
2. De forma opcional, cargar los archivos de `Data/` para insertar datos base.
3. Finalmente, ejecutar los procedimientos almacenados ubicados en `SPs/`.

Es recomendable utilizar MySQL (versión 8 o superior) para una correcta compatibilidad con las sentencias y delimitadores usados en los scripts.

