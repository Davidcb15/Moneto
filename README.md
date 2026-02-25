# Aplicación de Gestión de Gastos Personales

Esta es una aplicación móvil desarrollada con Flutter para ayudarte a gestionar tus finanzas personales de manera sencilla y eficiente. Con esta aplicación, puedes registrar tus ingresos y gastos en diversas categorías, visualizar informes y generar documentos PDF para tener un control total sobre tu economía.

## Funcionalidades Principales

* **Registro de Ingresos:** Guarda tus fuentes de ingresos y el monto correspondiente.
* **Registro de Gastos:** Realiza un seguimiento detallado de tus gastos, categorizándolos por hogar, coche, hobbies, viajes y transporte público.
* **Gestión de Ahorros:** Lleva un control de tus ahorros y visualiza el total acumulado.
* **Informes Visuales:** Obtén una visión clara de tus ingresos y gastos a través de gráficos comparativos.
* **Generación de Reportes PDF:** Exporta informes detallados de tus gastos para tener un registro fuera de la aplicación.
* **Interfaz Intuitiva:** Diseño amigable y fácil de usar para una experiencia de usuario óptima.
* **Persistencia de Datos:** Los datos se almacenan localmente utilizando bases de datos SQLite para garantizar la privacidad y el acceso sin conexión.

## Estructura de la Aplicación

La aplicación se organiza en las siguientes carpetas y archivos principales:
├── Databases/
│   ├── DatabaseCar.dart
│   ├── DatabaseHobbies.dart
│   ├── DatabaseHome.dart
│   ├── DatabaseMoney.dart
│   ├── DatabasePublicTransport.dart
│   └── DatabaseSaveMoney.dart
├── lib/ (Aquí esta el resto del código fuente de Flutter)
│   ├── main.dart
│   ├── report_page.dart
│   ├── travel_page.dart
│   ├── public_transport_page.dart
│   └── resto de las páginas.dart
├── assets/
│   ├──Roboto-Regular.ttf
│   ├──imagenes del proyecto.png
│
├──models/
│   ├──hobby.dart
│
└──auth/
    ├──auth.dart

* **`Databases/`:** Contiene los archivos Dart que gestionan las bases de datos locales para cada categoría de gasto, ingresos y ahorros.
* **`lib/`:** Alberga el código fuente de la aplicación Flutter, incluyendo:
    * `main.dart`: Punto de entrada de la aplicación.
    * `report_page.dart`: Interfaz para generar informes visuales y en PDF.
    * `DashBoardPage.dart` : Interfaz donde se encuentras las tarjetas de gastos e ingresos como 'Trasnporte' o 'Ahorros'
    * `LoginPage.dart` : Interfaz de logeo para acceder a la app
    * `RegisterPage.dart` : Interfaz para registrar un usuario y poder acceder a la app
* **`assets/`:** Contiene recursos como fuentes (`Roboto-Regular.ttf`) e imágenes (`report.png`).

## Cómo Utilizar la Aplicación

1.  **Descarga e Instalación:** Hay dos formas de instalar la aplicacion las cuales son
   -Conectar un dispositivo via usb, y clicar en el boton run para instalar la aplicación directamente desde Android Studio (Vease con mas detalle en la memoria)
   -Crear el archivo apk y abrirlo con Android Studio (Vease con mas detalle en la memoria)
2.  **Registro de Datos:** Navega por las diferentes secciones (Ingresos, Hogar, Coche, Hobbies, Viajes, Transporte Público, Ahorros) para registrar tus movimientos financieros.
3.  **Visualización de Informes:** Dirígete a la sección de "Generar Reportes" para ver gráficos comparativos de tus ingresos y gastos.
4.  **Generación de PDF:** En la misma sección, podrás generar un reporte detallado de tus gastos en formato PDF para su almacenamiento o impresión.

## Tecnologías Utilizadas

* **Flutter:** Framework de desarrollo de UI de Google para construir aplicaciones nativas para móvil, web y escritorio desde una única base de código.
* **Dart:** Lenguaje de programación utilizado por Flutter.
* **`pdf` package:** Para la generación de documentos PDF.
* **`printing` package:** Para la impresión y visualización de documentos PDF.
* **`fl_chart` package:** Para la creación de gráficos interactivos.
* **`path_provider` package:** Para acceder a las ubicaciones del sistema de archivos.
* **`intl` package:** Para la internacionalización y formateo de fechas y números.
* **`shared_preferences` package:** Usado para el registro de usuarios.
* **`sqflite` (implícito en los archivos `Database*.dart`):** Plugin de SQLite para Flutter para el almacenamiento local de datos.

## Próximas Mejoras (Opcional)

* Autenticación de usuarios.
* Sincronización de datos en la nube.
* Recordatorios de pagos y suscripciones.
* Presupuestos personalizables por categoría.
* Análisis más avanzado de los datos financieros.

## Contribución

Si deseas contribuir a este proyecto, ¡eres bienvenido! Puedes abrir un "issue" para reportar errores o sugerir nuevas funcionalidades, o enviar un "pull request" con tus propias mejoras.

¡Esperamos que esta aplicación te sea de gran utilidad para gestionar tus finanzas!