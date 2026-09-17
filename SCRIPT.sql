-- First Stage

-- Para Album (Actividad 1)
SELECT * FROM public."Album" LIMIT 10;

-- Para Track
SELECT * FROM public."Track" LIMIT 10;

-- Para Customer
SELECT * FROM public."Customer" LIMIT 10;

-- Para Invoice
SELECT * FROM public."Invoice" LIMIT 10;

-- Para InvoiceLine
SELECT * FROM public."InvoiceLine" LIMIT 10;





-- Para Artist (Actividad 2)
SELECT COUNT(*) AS cantidad_artistas FROM public."Artist";

-- Para Album
SELECT COUNT(*) AS cantidad_albumes FROM public."Album";

-- Para Track
SELECT COUNT(*) AS cantidad_canciones FROM public."Track";

-- Para Customer
SELECT COUNT(*) AS cantidad_clientes FROM public."Customer";

-- Para Invoice
SELECT COUNT(*) AS cantidad_facturas FROM public."Invoice";

-- Para InvoiceLine
SELECT COUNT(*) AS cantidad_lineas_factura FROM public."InvoiceLine";



-- Second Stage 

/* 
Etapa 2: Consultas básicas
Taller de Consultas y Optimización en PostgreSQL con Chinook
*/

/* Ejercicio 1: Filtros y ordenamiento */
/* Obten las canciones cuyo precio sea mayor o igual a 1.00. Muestra el identificador, el nombre y el precio, ordenando desde la canción más costosa. */
SELECT 
    "TrackId", 
    "Name", 
    "UnitPrice" 
FROM public."Track" 
WHERE "UnitPrice" >= 1.00 
ORDER BY "UnitPrice" DESC;





/* Ejercicio 2: Búsqueda de clientes */
/* Consulta los clientes de Brasil, Canadá o Estados Unidos. Muestra nombre completo, país, ciudad y correo electrónico. Utiliza IN para el filtro. */
SELECT 
    "FirstName", 
    "LastName", 
    "Country", 
    "City", 
    "Email" 
FROM public."Customer" 
WHERE "Country" IN ('Brazil', 'Canada', 'United States')
ORDER BY "Country", "FirstName", "LastName";

/* Ejercicio 3: Búsqueda de canciones */
/* Encuentra las canciones cuyo nombre contenga la palabra Love, sin importar mayúsculas o minúsculas. */
SELECT 
    "TrackId", 
    "Name", 
    "Composer", 
    "UnitPrice"
FROM public."Track"
WHERE "Name" ILIKE '%love%'
ORDER BY "Name";

/* Ejercicio 4: Funciones de agregación */
/* Obtén en una sola consulta:
   - Cantidad total de canciones.
   - Precio promedio, mínimo y máximo.
   - Duración promedio en milisegundos. */
SELECT 
    COUNT(*) AS total_canciones,
    AVG("UnitPrice") AS precio_promedio,
    MIN("UnitPrice") AS precio_minimo,
    MAX("UnitPrice") AS precio_maximo,
    AVG("Milliseconds") AS duracion_promedio_ms
FROM public."Track";

/* Ejercicio 5: Agrupación */
/* Obtén la cantidad de clientes por país y ordena el resultado desde el país con más clientes. */
SELECT 
    "Country", 
    COUNT(*) AS cantidad_clientes
FROM public."Customer"
GROUP BY "Country"
ORDER BY cantidad_clientes DESC;

/* Ejercicio 6: Condición sobre agrupaciones */
/* Modifica el ejercicio anterior para mostrar únicamente los países que tengan al menos dos clientes. */
SELECT 
    "Country", 
    COUNT(*) AS cantidad_clientes
FROM public."Customer"
GROUP BY "Country"
HAVING COUNT(*) >= 2
ORDER BY cantidad_clientes DESC;


-- Third Stage 

/* 
Etapa 3: Consultas con JOIN
Taller de Consultas y Optimización en PostgreSQL con Chinook
*/

/* Ejercicio 7: Álbumes y artistas */
/* Obten cada álbum junto con el nombre de su artista. */
SELECT 
    ar."Name" AS artista, 
    al."Title" AS album 
FROM public."Artist" AS ar 
INNER JOIN public."Album" AS al ON ar."ArtistId" = al."ArtistId" 
ORDER BY ar."Name", al."Title";

/* Ejercicio 8: Canciones, álbumes y artistas */
/* Relaciona Track, Album y Artist. Muestra canción, álbum, artista, precio y duración en minutos. */
SELECT 
    t."Name" AS canción,
    al."Title" AS álbum,
    ar."Name" AS artista,
    t."UnitPrice" AS precio,
    ROUND((t."Milliseconds" / 60000.0)::numeric, 2) AS duracion_minutos
FROM public."Track" t
INNER JOIN public."Album" al ON t."AlbumId" = al."AlbumId"
INNER JOIN public."Artist" ar ON al."ArtistId" = ar."ArtistId"
ORDER BY ar."Name", al."Title", t."Name";

/* Ejercicio 9: Clientes y facturas */
/* Obtén todas las facturas junto con el cliente. Muestra número de factura, nombre completo, país, fecha y total. Ordena desde la factura más reciente. */
SELECT 
    i."InvoiceId" AS "Número de factura",
    c."FirstName" || ' ' || c."LastName" AS "Nombre completo",
    c."Country" AS país,
    i."InvoiceDate" AS fecha,
    i."Total" AS total
FROM public."Invoice" i
INNER JOIN public."Customer" c ON i."CustomerId" = c."CustomerId"
ORDER BY i."InvoiceDate" DESC;

/* Ejercicio 10: Detalle completo de ventas */
/* Relaciona Customer, Invoice, InvoiceLine y Track para mostrar cada canción vendida. */
SELECT 
    c."FirstName" || ' ' || c."LastName" AS Cliente,
    i."InvoiceId" AS "Número de factura",
    t."Name" AS Canción,
    il."UnitPrice" AS "Precio unitario",
    il."Quantity" AS Cantidad,
    il."UnitPrice" * il."Quantity" AS Subtotal
FROM public."Customer" c
INNER JOIN public."Invoice" i ON c."CustomerId" = i."CustomerId"
INNER JOIN public."InvoiceLine" il ON i."InvoiceId" = il."InvoiceId"
INNER JOIN public."Track" t ON il."TrackId" = t."TrackId"
ORDER BY i."InvoiceDate" DESC, c."LastName", c."FirstName";

/* Ejercicio 11: Ventas por país */
/* Calcula el dinero facturado por país. Muestra país de facturación, cantidad de facturas y total vendido. Ordena desde el país con mayores ventas. */
SELECT 
    c."Country" AS "País de facturación",
    COUNT(i."InvoiceId") AS "Cantidad de facturas",
    SUM(i."Total") AS "Total vendido"
FROM public."Customer" c
INNER JOIN public."Invoice" i ON c."CustomerId" = i."CustomerId"
GROUP BY c."Country"
ORDER BY "Total vendido" DESC;

/* Ejercicio 12: Cinco artistas con mayores ventas */
/* Relaciona Artist, Album, Track e InvoiceLine. Muestra artista, unidades vendidas e ingresos generados. Devuelve únicamente los cinco primeros resultados. */
SELECT 
    ar."Name" AS artista,
    SUM(il."Quantity") AS "Unidades vendidas",
    SUM(il."UnitPrice" * il."Quantity") AS "Ingresos generados"
FROM public."Artist" ar
INNER JOIN public."Album" al ON ar."ArtistId" = al."ArtistId"
INNER JOIN public."Track" t ON al."AlbumId" = t."AlbumId"
INNER JOIN public."InvoiceLine" il ON t."TrackId" = il."TrackId"
GROUP BY ar."Name"
ORDER BY "Ingresos generados" DESC
LIMIT 5;