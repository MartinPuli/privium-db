DELETE FROM listings_categories;
DELETE FROM categories;

INSERT INTO categories (id, name, hasChild) VALUES
/* ======== Raíces ======== */
('1', 'Productos', 1),
('2', 'Vehículos', 1),
('3', 'Muebles', 1),
('4', 'Inmuebles', 1),
('5', 'Servicios', 1),

/* ======== Productos (1) ======== */
('1>1', 'Electrónica', 1),
('1>1>1', 'Celulares y Smartphones', 0),
('1>1>2', 'Computadoras y Notebooks', 0),
('1>1>3', 'Televisores y Video', 0),
('1>1>4', 'Audio y Parlantes', 0),
('1>1>5', 'Cámaras y Fotografía', 0),
('1>1>6', 'Accesorios Electrónicos', 0),
('1>1>7', 'Smart Home', 0),

('1>2', 'Hogar y Cocina', 1),
('1>2>1', 'Electrodomésticos', 0),
('1>2>2', 'Decoración', 0),
('1>2>3', 'Utensilios de Cocina', 0),
('1>2>4', 'Ropa de Cama', 0),
('1>2>5', 'Baño', 0),
('1>2>6', 'Limpieza Hogar', 0),
('1>2>7', 'Seguridad Doméstica', 0),

('1>3', 'Moda', 1),
('1>3>1', 'Ropa Hombre', 0),
('1>3>2', 'Ropa Mujer', 0),
('1>3>3', 'Calzado', 0),
('1>3>4', 'Accesorios de Moda', 0),
('1>3>5', 'Joyería', 0),
('1>3>6', 'Bolsos y Mochilas', 0),
('1>3>7', 'Relojes', 0),

('1>4', 'Deportes y Outdoor', 1),
('1>4>1', 'Fitness y Gimnasio', 0),
('1>4>2', 'Deportes de Equipo', 0),
('1>4>3', 'Camping y Trekking', 0),
('1>4>4', 'Ciclismo', 0),
('1>4>5', 'Deportes Acuáticos', 0),
('1>4>6', 'Running', 0),
('1>4>7', 'Yoga y Pilates', 0),

('1>5', 'Bebés y Niños', 1),
('1>5>1', 'Juguetes', 0),
('1>5>2', 'Puericultura', 0),
('1>5>3', 'Ropa Infantil', 0),
('1>5>4', 'Útiles Escolares', 0),
('1>5>5', 'Calzado Infantil', 0),
('1>5>6', 'Seguridad Bebé', 0),
('1>5>7', 'Muebles Infantiles', 0),

('1>6', 'Salud y Belleza', 1),
('1>6>1', 'Cuidado Personal', 0),
('1>6>2', 'Cosmética', 0),
('1>6>3', 'Suplementos', 0),
('1>6>4', 'Perfumería', 0),
('1>6>5', 'Equipamiento Fitness', 0),
('1>6>6', 'Spa & Relax', 0),

('1>7', 'Herramientas y Jardín', 1),
('1>7>1', 'Herramientas', 0),
('1>7>2', 'Jardinería', 0),
('1>7>3', 'Materiales de Construcción', 0),
('1>7>4', 'Iluminación Exterior', 0),
('1>7>5', 'Pinturas', 0),
('1>7>6', 'Sistemas de Riego', 0),
('1>7>7', 'Climatización Exterior', 0),

('1>8', 'Consolas y Videojuegos', 1),
('1>8>1', 'Consolas', 0),
('1>8>2', 'Videojuegos', 0),
('1>8>3', 'Accesorios para Consolas', 0),

('1>9', 'Libros, Películas y Música', 1),
('1>9>1', 'Libros', 0),
('1>9>2', 'Películas', 0),
('1>9>3', 'Música', 0),

('1>10', 'Otros Productos', 0),

/* ======== Vehículos (2) ======== */
('2>1', 'Autos', 1),
('2>1>1', 'Sedán', 0),
('2>1>2', 'Hatchback', 0),
('2>1>3', 'Coupé', 0),
('2>1>4', 'Descapotable', 0),

('2>2', 'Motos', 1),
('2>2>1', 'Deportivas', 0),
('2>2>2', 'Scooters', 0),
('2>2>3', 'Todo Terreno', 0),

('2>3', 'Bicicletas', 1),
('2>3>1', 'Montaña', 0),
('2>3>2', 'Ruta', 0),
('2>3>3', 'BMX', 0),

('2>4', 'Camionetas', 1),
('2>4>1', 'SUV', 0),
('2>4>2', 'Pickup', 0),
('2>4>3', 'Furgoneta', 0),

('2>5', 'Otros Vehículos', 0),

/* ======== Muebles (3) ======== */
('3>1', 'Sala de Estar', 1),
('3>1>1', 'Sofás', 0),
('3>1>2', 'Sillones', 0),
('3>1>3', 'Mesas de Centro', 0),

('3>2', 'Comedor', 1),
('3>2>1', 'Mesas de Comedor', 0),
('3>2>2', 'Sillas de Comedor', 0),
('3>2>3', 'Vitrinas', 0),

('3>3', 'Dormitorio', 1),
('3>3>1', 'Camas', 0),
('3>3>2', 'Mesas de Noche', 0),
('3>3>3', 'Armarios', 0),

('3>4', 'Exterior', 1),
('3>4>1', 'Muebles de Jardín', 0),
('3>4>2', 'Mesas de Exterior', 0),
('3>4>3', 'Reposeras', 0),

('3>5', 'Otros Muebles', 0),

/* ======== Inmuebles (4) ======== */
('4>1', 'Casas', 1),
('4>1>1', 'Casa Urbana', 0),
('4>1>2', 'Casa en Country', 0),
('4>1>3', 'Casa de Playa', 0),

('4>2', 'Departamentos', 1),
('4>2>1', 'Departamento Urbano', 0),
('4>2>2', 'Departamento en Playa', 0),
('4>2>3', 'Loft/Studio', 0),

('4>3', 'Terrenos y Lotes', 1),
('4>3>1', 'Terreno Urbano', 0),
('4>3>2', 'Terreno Rural', 0),

('4>4', 'Otros Inmuebles', 0),

/* ======== Servicios (5) ======== */
('5>1', 'Reparaciones del Hogar', 1),
('5>1>1', 'Plomería', 0),
('5>1>2', 'Electricidad', 0),
('5>1>3', 'Pintura', 0),
('5>1>4', 'Cerrajería', 0),

('5>2', 'Transporte y Mudanzas', 1),
('5>2>1', 'Mudanzas', 0),
('5>2>2', 'Transporte de Carga', 0),
('5>2>3', 'Mensajería', 0),

('5>3', 'Eventos', 1),
('5>3>1', 'Organización de Eventos', 0),
('5>3>2', 'Catering', 0),
('5>3>3', 'Fotografía y Video', 0),

('5>4', 'Clases y Tutorías', 1),
('5>4>1', 'Idiomas', 0),
('5>4>2', 'Tutorías Académicas', 0),
('5>4>3', 'Arte y Manualidades', 0),

('5>5', 'Otros Servicios', 0);
