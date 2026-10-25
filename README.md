# APEX Media Manager

Reproductor IPTV para Windows, Android y Android TV. Importa listas M3U y cuentas Xtream Codes, agrupa calidades, reproduce canales, películas y episodios y guarda favoritos. No incluye suscripciones ni listas de contenido.

## Desarrollo

- Flutter 3.47.3 / Dart 3.13.3; Android SDK y herramientas C++ de Visual Studio para Windows.
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter run -d windows`

Consulta [CLAUDE.md](CLAUDE.md) para la arquitectura y el procedimiento de publicación. `AGENTS.md` y `SKILLS.md` remiten a ese documento.

## Android TV

La misma APK admite móvil y televisión. Incluye launcher Leanback, banner, orientación horizontal en TV y navegación por foco. Usa las flechas del mando para desplazarte y OK para activar. En los canales, el botón de capas permite elegir calidad y la estrella guarda favoritos. En el reproductor, OK muestra los controles; el botón multimedia pausa/reanuda; atrás oculta los controles y después vuelve. En películas y episodios se puede avanzar y retroceder.

Selecciona la APK adecuada: `arm64-v8a` para equipos ARM de 64 bits, `armeabi-v7a` para ARM de 32 bits y `x86_64` para dispositivos Intel compatibles. La compatibilidad de códecs y el rendimiento final también dependen del televisor y de la fuente.

## Cuentas y modo local

La app usa el proyecto Supabase configurado en `lib/main.dart`. La URL y la clave pública pueden sustituirse mediante `--dart-define=SUPABASE_URL=...` y `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`. Las claves de servidor nunca forman parte de la app.

«Continuar en este dispositivo» guarda los perfiles localmente y permite usar IPTV sin iniciar sesión. Los perfiles de una cuenta se aíslan mediante políticas RLS. La app conserva HTTP para proveedores que lo requieren y valida los certificados de HTTPS.

## Publicación

1. Copia `.env.example` a `.env.local` y configura las credenciales administrativas. Este archivo está excluido de Git.
2. Sincroniza las versiones de `pubspec.yaml`, `installer.iss` y Ajustes.
3. Ejecuta `flutter build windows` e Inno Setup con `installer.iss`.
4. Ejecuta `flutter build apk --split-per-abi --release`.
5. Ejecuta `node upload.js`, `node upload_windows.js` y `node scripts/publish_release.cjs`.

Los paquetes se publican con rutas por versión y hashes SHA-256. Los metadatos OTA solo se actualizan tras subir todas las plataformas. La APK conserva la firma de desarrollo utilizada por este proyecto; configura una clave de distribución propia antes de publicarla en una tienda y ten en cuenta la continuidad de firma para actualizar instalaciones existentes.

`supabase/schema.sql` contiene el esquema inicial. `dart run tool/backend_admin.dart inspect|apply|verify` permite administrarlo con credenciales locales, TLS verificado y la CA pública de Supabase. `node tool/verify_backend.cjs` comprueba autenticación y aislamiento con cuentas temporales y las elimina al terminar.

## Rendimiento y VPN

Los canales usan slivers y construcción diferida; la sincronización no se repite en bucle; las imágenes se cargan bajo demanda con caché y concurrencia limitada; los favoritos comparten un índice y los efectos de desenfoque se desactivan en TV. La fuente Outfit se incluye localmente con su licencia.

Si el sistema no permite abrir Isar, la app utiliza almacenamiento local compatible para perfiles y favoritos. Los archivos Isar existentes se conservan.

Zen Shield genera claves de dispositivo al registrar WARP y admite importar una configuración WireGuard propia. El registro depende de una API de Cloudflare que puede rechazar clientes; las claves privadas compartidas del prototipo se han retirado. Activar un túnel real requiere permiso VPN en Android y elevación en Windows.

Los scripts de experimentación, datos descargados, configuraciones privadas y ejecutables históricos conservados en la raíz se excluyen de Git. El código mantenido está en `lib/`, `test/`, `tool/`, `scripts/`, `android/` y `windows/`.

## Validación del 25/10/2026

`flutter analyze` sin incidencias y 23 pruebas automatizadas superadas: sincronización acotada, almacenamiento alternativo, rejilla diferida con 20.000 canales, mando y teclado de TV, VOD/episodios, VPN y descargas verificadas. La corrección HTTPS rechaza certificados no confiables y nombres de servidor incorrectos; las pruebas mantienen HTTPS confiable y listas HTTP.

Compilados el instalador Windows y las APK ARM64, ARMv7 y x86_64. Backend verificado con cuentas temporales: aislamiento de perfiles, inserción propia y lectura pública de metadatos. Publicación 2.2.54 con hashes por plataforma.

En el emulador Android TV se verificaron arranque, detección de TV, navegación, foco, catálogo y temporadas. La reproducción llegó al motor de vídeo, pero la captura permaneció negra bajo traducción ARM del emulador x86: la imagen de vídeo **queda pendiente de validar en un televisor físico**. No se ha verificado un túnel VPN real ni el arranque gráfico de Windows con UAC.

`tool/tv_smoke_main.dart` es un punto de entrada exclusivo de pruebas con `tool/smoke_server.cjs`; nunca se utiliza para publicar. Los paquetes publicados se generan desde `lib/main.dart`.
