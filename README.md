# ChaliTaxi

App multiplataforma (Flutter) para rastreo de distancia y rutas recomendadas — desarrollada para facilitar la selección de destinos y el cálculo estimado de tarifas en la ciudad (incluye sistema de rutas con API OSRM y rastreo GPS).

Este README reúne lo esencial sobre qué hace el proyecto, su arquitectura, cómo ejecutarlo en diferentes plataformas, configuración importante y notas para desarrolladores.

---

## Resumen / Qué hace este proyecto

- Rastrea la posición del dispositivo usando geolocalización (paquetes: `geolocator`, `permission_handler`).
- Calcula la distancia recorrida y muestra la velocidad aproximada.
- Sistema de Rutas Recomendadas (módulo documentado en `RUTAS_README.md`) con:
  - Modelos para destinos y rutas (`lib/models/destination.dart`, `lib/models/route.dart`).
  - Servicio cliente para consultar rutas (ej. OSRM) en `lib/services/route_service.dart`.
  - Pantallas para selección de destino y visualización en mapa (`lib/screens/destination_selection_screen.dart`, `lib/screens/route_map_screen.dart`).
- Proyecto Flutter configurado para móvil, web y escritorio (carpeta `linux/`, `windows/`, `web/` con CMake y archivos runner).

---

## Estructura principal del repo (resumen)
- lib/
  - main.dart — punto de entrada; contiene la pantalla de rastreo y arranque.
  - models/
    - destination.dart
    - route.dart
  - services/
    - route_service.dart
  - screens/
    - destination_selection_screen.dart
    - route_map_screen.dart
- RUTAS_README.md — documentación específica del sistema de rutas recomendadas.
- web/ — assets y `index.html` para la versión web.
- linux/, windows/ — CMake y código nativo/runner para build desktop.
- README.md — (este archivo) documentación general.

(Para ver más detalles de la estructura y las implementaciones, consulte los archivos listados arriba.)

---

## Requisitos previos

- Flutter SDK (recomendado: versión estable reciente; si usas features específicas verifica con `flutter --version`).
- Para compilación desktop:
  - Linux: CMake >= 3.13, dependencias GTK/GLib (pkg-config, gtk+-3.0, glib-2.0, gio).
  - Windows: Visual Studio con herramientas CMake/MSVC.
- Para Android/iOS: Android Studio / Xcode según plataforma.
- Conexión a Internet (el servicio de rutas consulta APIs externas como OSRM).

---

## Dependencias importantes (detectadas en el código)
- geolocator — obtener posición GPS y velocidad.
- permission_handler — pedir y revisar permisos al usuario.
- Dependencias Flutter estándar (SDK, plugins que puedan estar en `pubspec.yaml`).
- Servicios para rutas (OSRM u otras APIs gratuitas según `RUTAS_README.md`).

---

## Configuración y ejecución (desarrollo)

1. Clonar el repositorio:
   - git clone https://github.com/German-Zelaya/chalitaxi.git
   - cd chalitaxi

2. Instalar paquetes:
   - flutter pub get

3. Ejecutar en dispositivo/emulador móvil:
   - flutter run
   - Para un dispositivo específico: flutter run -d <deviceId>

4. Ejecutar en web:
   - flutter run -d chrome
   - o para build: flutter build web

5. Ejecutar en Linux (desktop):
   - Asegúrate de tener CMake y dependencias de GTK instaladas.
   - flutter build linux
   - o flutter run -d linux

6. Ejecutar en Windows (desktop):
   - Configura Visual Studio y herramientas CMake.
   - flutter build windows
   - o flutter run -d windows

7. Limpieza común si hay problemas:
   - flutter clean && flutter pub get

---

## Permisos y configuración de geolocalización

- Android: verifica que `AndroidManifest.xml` incluya permisos de ubicación (ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION). Para Android 10+ puede requerir permisos de foreground/background dependiendo del uso.
- iOS: añade las claves `NSLocationWhenInUseUsageDescription` / `NSLocationAlwaysAndWhenInUseUsageDescription` en `Info.plist`.
- El proyecto ya usa `permission_handler` para solicitar permisos en tiempo de ejecución (revisa `lib/main.dart` y las pantallas).

---

## Sistema de Rutas Recomendadas (resumen y uso)

Ver `RUTAS_README.md` para documentación completa (ya incluida). Puntos clave:

- Models:
  - `destination.dart` contiene destinos predefinidos (ej. lugares de Sucre).
  - `route.dart` encapsula la ruta, distancias y cálculo de tarifa.
- Service:
  - `route_service.dart` implementa consultas HTTP a un motor de ruteo (ej. OSRM). Revisa el archivo para la URL base y parámetros.
- Uso:
  - Pantalla de selección de destino → invoca `route_service` → presenta la ruta en `route_map_screen.dart` y muestra tarifa estimada.
- Configuración de endpoints: ajusta el host/URL en `route_service.dart` si deseas usar un servidor OSRM local o un proveedor diferente.

---

## Cálculo de tarifas

- La lógica de cálculo de tarifa está en `lib/models/route.dart` o donde se documente en `RUTAS_README.md`. Ajusta la fórmula según tarifas locales o agrega parámetros (tarifa base, precio por km, cargos por tiempo).

---

## Build y empaquetado (notas)

- Mobile (Android/iOS): usa los comandos estándar de Flutter (`flutter build apk`, `flutter build ios`).
- Web: `flutter build web`
- Desktop:
  - Linux/Windows: el proyecto contiene archivos CMake (`linux/CMakeLists.txt`, `windows/CMakeLists.txt`) y runners nativos en `linux/runner` y `windows/runner`.
  - Para distribuciones Linux/Windows revisa las secciones de instalación en los CMakeLists (instalación de assets y AOT library). El runner crea la ventana nativa y carga el FLutter view.

---

## Pruebas y depuración

- Para depuración de ubicación: usa emuladores que permitan simular coordenadas o herramientas para mockear GPS.
- Revisar logs: `flutter run` muestra salida de la app; para desktop se puede ver la consola nativa (los runners ya intentan adjuntar/crear consola para depuración).

---

## Qué revisé en el repositorio (qué entendí y confirmé)
- Punto de entrada: `lib/main.dart` — app con pantalla de rastreo y uso de `geolocator` y `permission_handler`.
- Módulo de rutas documentado en `RUTAS_README.md` (modelos, servicios y pantallas).
- Configuración multiplataforma:
  - Archivos CMake para Linux y Windows (`linux/CMakeLists.txt`, `windows/CMakeLists.txt`).
  - Código nativo runner para Windows (`windows/runner/main.cpp`, `flutter_window.cpp` etc.) y Linux (`linux/runner/my_application.cc`).
- Web: `web/index.html` y assets presentes.
- No encontré variables secretas ni tokens en el código indexado (si usas APIs con clave, agrega un mecanismo seguro de configuración).

---

## Sugerencias rápidas / Próximos pasos recomendados

- Añadir encriptación/gestión de claves si el servicio de rutas necesita API keys (no commit de claves en repo).
- Tests unitarios para:
  - Cálculo de tarifas.
  - Parsing de respuestas de la API de rutas.
- Documentar versión mínima de Flutter en `pubspec.yaml` y en este README.
- Añadir screenshots o GIFs en el README para mejorar la presentación.
- Completar sección "Contribuir" con guía de estilo, PR template y issues.

---

## Contribución

- Si quieres contribuir, crea PRs contra la rama principal y sigue las buenas prácticas: Describe el cambio, añade pruebas si aplica y actualiza `RUTAS_README.md` cuando modifiques la lógica de rutas.

---

## Solución de problemas comunes

- Problema: permisos de ubicación no funcionan → ejecutar `flutter clean`, verificar permisos en AndroidManifest/Info.plist y solicitar permiso en tiempo de ejecución.
- Problema: build desktop falla por CMake → instalar dependencias del sistema (GTK/GLib en Linux, toolchain MSVC en Windows).
- Problema: rutas no devuelven datos → comprobar endpoint de OSRM en `route_service.dart` y probar la URL con curl/postman.

---

## Licencia

- No se encontró un archivo LICENSE en el repo. Si quieres abrirlo al público, añade un archivo `LICENSE` con la licencia deseada (MIT, Apache-2.0, etc.).

---

Si quieres, puedo:
- Generar README.md final (listo para reemplazar el actual) con secciones de badges, screenshots y comandos exactos (incluyendo ejemplos de `flutter run` por plataforma).
- Añadir instrucciones concretas para Android/iOS (fragments de AndroidManifest/Info.plist).
- Extraer y colocar aquí los puntos específicos encontrados en `route_service.dart` o calcular ejemplos de tarifa usando los modelos actuales.

Dime cuál de estas opciones quieres que haga ahora y lo hago de inmediato.
