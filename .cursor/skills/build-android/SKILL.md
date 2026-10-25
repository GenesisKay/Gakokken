---
name: build-android
description: Genera el build Android de una app Flutter - APK de release para el celular (más chico; el de debug solo si se pide) o App Bundle (AAB) para Play Store - y entrega la ruta de la carpeta, no la del archivo. Para el AAB sube la versión del pubspec.yaml solo después de que el usuario confirme. Usar cuando el usuario pida build, APK, bundle, AAB, appbundle, release o subir a Play Store.
---

# build-android: APK (release por defecto) o AAB para Play Store

Skill genérica para apps Flutter. Es la misma en todos los proyectos. Sin emojis.

Se usa siempre que se genere un APK o AAB, aunque sea como último paso de otra tarea (por ejemplo, al terminar una fase): la respuesta sigue la sección "Respuesta".

## Configuración

La ruta del proyecto Flutter está en la sección "Configuración del proyecto" del `CLAUDE.md` del repo. Si esa sección no da una ruta, el proyecto Flutter es la raíz del repo (donde está `pubspec.yaml`). Trabajar siempre desde esa ruta.

## Qué build

| Pide | Build | Carpeta de salida (relativa al proyecto Flutter) |
| --- | --- | --- |
| "APK", "para mi cel", "para probar", "release" | `flutter build apk --release` | `build/app/outputs/flutter-apk` |
| "APK debug" (para depurar con `flutter run` o ver logs) | `flutter build apk --debug` | `build/app/outputs/flutter-apk` |
| "Los dos", "debug y release" | Primero release, después debug | `build/app/outputs/flutter-apk` |
| "bundle", "AAB", "Play Store" | `flutter build appbundle` | `build/app/outputs/bundle/release` |

Si no queda claro, preguntar cuál.

## APK

Por defecto solo el **release**: pesa mucho menos que el debug (no lleva el modo de depuración y queda optimizado). El debug solo se hace si el usuario lo pide.

1. `flutter build apk --release` (puede tardar varios minutos). Si se pidió el debug, `flutter build apk --debug`.
2. Confirmar que el archivo existe en la carpeta (`app-release.apk`, `app-debug.apk`) y decir su tamaño en MB.
3. Si el release se firmó con la llave de debug (no hay `android/key.properties`), decirlo: sirve para instalar en el celular, no para Play Store. Para instalarlo encima de un APK firmado con otra llave hay que desinstalar el anterior.
4. Instalar con `adb install -r` solo si el usuario lo pide.

No pide versión ni confirmación. Si se pidieron los dos y uno falla, reportar el error y entregar el que sí salió.

## AAB para Play Store (orden estricto)

1. **Leer la versión** del `pubspec.yaml`: `version: X.Y.Z+N`. `X.Y.Z` es el nombre de versión; `N` es el número que Play Store exige subir en cada envío.
2. **Proponer y preguntar.** Por defecto: `X.Y.Z+(N+1)`. Si el usuario pide subir patch, minor o major, ajustar `X.Y.Z` y usar `N+1` si no dice otro número. Ejemplo:
   - Versión actual: `1.0.0+3`
   - Propuesta: `1.0.0+4`
   - ¿Confirmas?

   **No editar el pubspec ni hacer el build sin un sí explícito.**
3. **Aplicar.** Editar solo la línea `version:`.
4. **Build.** `flutter build appbundle`. Si falla por firma, decir que falta `android/key.properties` o el keystore que referencia, sin abrirlos ni mostrarlos.

## Respuesta

En pocas líneas:

1. Versión en el `pubspec.yaml` (solo AAB).
2. Resultado de cada build: OK o el error en breve.
3. **Ruta absoluta de la carpeta** donde quedó el archivo (la carpeta padre), lista para copiar, primero y visible. Nunca la ruta completa del archivo. También se puede abrir con `explorer "<ruta>"`.
   - **Sacarla en el momento**, después del build, de la carpeta real: en PowerShell `(Resolve-Path build\app\outputs\flutter-apk).Path` desde el proyecto Flutter. No escribirla de memoria, ni copiarla de una respuesta anterior, ni de este archivo: el proyecto puede estar en otro disco o en otra carpeta.
   - Bien: `<proyecto>\build\app\outputs\flutter-apk`, por ejemplo `D:\3-Projects\Software\Zontle\Zontle\build\app\outputs\flutter-apk`
   - Mal: `<proyecto>\build\app\outputs\flutter-apk\app-release.apk`
4. Nombre de los archivos que quedaron dentro, solo el nombre (`app-release.apk`, y `app-debug.apk` si se pidió), sin ruta, con su tamaño. Nunca repetir la ruta junto al nombre del archivo.

## Qué no hacer

- No leer ni tocar `key.properties`, keystores (`.jks`), `.ppk` ni `.env`.
- No subir versión ni hacer el AAB sin confirmación.
- No inventar rutas de salida; si el archivo no aparece, revisar la carpeta antes de responder.
- No hacer git add, commit ni push.
