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
2. Confirmar que el archivo existe en la carpeta (`app-release.apk`, `app-debug.apk`) y que su fecha es posterior al inicio del build.
3. **Renombrarlo** (ver "Nombre del archivo") y decir su tamaño en MB.
4. Si el release se firmó con la llave de debug (no hay `android/key.properties`), decirlo: sirve para instalar en el celular, no para Play Store. Para instalarlo encima de un APK firmado con otra llave hay que desinstalar el anterior.
5. Instalar con `adb install -r <archivo renombrado>` solo si el usuario lo pide.

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
5. **Renombrar** el `app-release.aab` (ver "Nombre del archivo"). Play Console acepta cualquier nombre.
6. **Revisar el bundle.** Confirmar que el `.aab` tiene fecha posterior al inicio del build (si el build falla puede quedar el de antes). Si el bundle se hizo para llevar una función nueva (por ejemplo widgets), confirmar que va adentro: el manifiesto del `.aab` es binario pero los nombres de clase se leen con `unzip -p <aab> base/manifest/AndroidManifest.xml | tr -d '\0' | grep -a -o -E "[A-Za-z]*WidgetProvider"`.
7. **Anotarlo en el registro de bundles** (sección de abajo). Un bundle que no quedó en el registro no cuenta como entregado.

## Registro de bundles

Cada AAB generado queda anotado en la nota del proyecto en el vault (`E:/Vault/Software/Proyectos/<App>.md`, ver skill `documentar`), para saber siempre qué versión lleva qué. Así se contesta "¿el último bundle ya trae X?" sin adivinar.

### Antes del build

Leer la sección `# Bundles` de la nota y las entradas de Pendientes y Decisiones con fecha posterior al último bundle de la tabla. Eso es lo que va a incluir el bundle nuevo; decirlo en una línea al proponer la versión.

### Después del build

En la sección `# Bundles` (si no existe, crearla justo antes de `# Decisiones`), agregar una fila arriba, la más nueva primero:

```markdown
# Bundles

| Versión | Generado | Archivo | Qué trae de nuevo | Estado |
| --- | --- | --- | --- | --- |
| 1.1.0+11 | 2026-11-22 | `eloisa-1.1.0-11.aab` | Widgets de Android (Grabar, Grabando, Grabaciones recientes) | Generado, sin subir |
```

- **Qué trae de nuevo**: solo lo que entró desde el bundle anterior, en pocas palabras, sacado de Pendientes y Decisiones. Si no hubo nada nuevo (rebuild), decirlo.
- **Estado**: `Generado, sin subir`, y cuando el usuario diga que lo subió, `Prueba interna`, `Prueba cerrada`, `Producción` con la fecha (por ejemplo `Producción 2026-11-25`). Solo se cambia cuando el usuario lo dice.
- Poner `version:` del frontmatter de la nota en la versión del último bundle generado.
- En Pendientes y Decisiones, las funciones que entraron pasan de "pendiente de bundle" a "en el bundle X.Y.Z+N".

### Al terminar una función sin bundle

Si se termina algo y no se genera bundle en ese momento, en la nota se escribe "pendiente de bundle", nunca "en el bundle X.Y.Z+N" aunque esa sea la versión que ya tiene el `pubspec.yaml`. Una versión en el `pubspec.yaml` no es un bundle generado.

### Si preguntan si un bundle trae algo

Ver la tabla de `# Bundles`. Si la tabla no lo resuelve (bundles de antes del registro), revisar el `.aab` de `build/app/outputs/bundle/release`: su fecha contra la de la función y, si hace falta, su manifiesto (paso 6). Decir de dónde salió la respuesta.

## Nombre del archivo

Flutter siempre saca `app-release.apk`, `app-debug.apk` y `app-release.aab`, igual en todos los proyectos. Como el usuario maneja varios, después de cada build se renombra en la misma carpeta con el nombre de la app y la versión:

| Build | Nombre |
| --- | --- |
| APK release | `<app>-<X.Y.Z>-<N>-release.apk` |
| APK debug | `<app>-<X.Y.Z>-<N>-debug.apk` |
| AAB | `<app>-<X.Y.Z>-<N>.aab` |

- `<app>` es el `name:` del `pubspec.yaml` (por ejemplo `ardilla`, `gakoken`) y `X.Y.Z+N` su `version:`. Sin `+` en el nombre: se cambia por `-`. Ejemplo: `ardilla-1.0.0-1-release.apk`.
- Se mueve (no se copia) para que en la carpeta no quede el genérico. Si ya existe uno con ese nombre (mismo build repetido sin subir versión), se reemplaza.
- En PowerShell, desde el proyecto Flutter:

  ```powershell
  $app = ((Select-String -Path pubspec.yaml -Pattern '^name:\s*(\S+)').Matches[0].Groups[1].Value)
  $ver = ((Select-String -Path pubspec.yaml -Pattern '^version:\s*(\S+)').Matches[0].Groups[1].Value) -replace '\+', '-'
  Move-Item -Force build\app\outputs\flutter-apk\app-release.apk "build\app\outputs\flutter-apk\$app-$ver-release.apk"
  ```

  Con `app-debug.apk` y `-debug.apk` para el debug, y `build\app\outputs\bundle\release\app-release.aab` a `$app-$ver.aab` para el AAB.

## Respuesta

En pocas líneas:

1. Versión en el `pubspec.yaml` (solo AAB).
2. Resultado de cada build: OK o el error en breve.
3. **Ruta absoluta de la carpeta** donde quedó el archivo (la carpeta padre), lista para copiar, primero y visible. Nunca la ruta completa del archivo. También se puede abrir con `explorer "<ruta>"`.
   - **Sacarla en el momento**, después del build, de la carpeta real: en PowerShell `(Resolve-Path build\app\outputs\flutter-apk).Path` desde el proyecto Flutter. No escribirla de memoria, ni copiarla de una respuesta anterior, ni de este archivo: el proyecto puede estar en otro disco o en otra carpeta.
   - Bien: `<proyecto>\build\app\outputs\flutter-apk`, por ejemplo `E:\Software\Zontle\Zontle\build\app\outputs\flutter-apk`
   - Mal: `<proyecto>\build\app\outputs\flutter-apk\ardilla-1.0.0-1-release.apk`
4. Nombre de los archivos que quedaron dentro, solo el nombre ya renombrado (`ardilla-1.0.0-1-release.apk`), sin ruta, con su tamaño. Nunca repetir la ruta junto al nombre del archivo, ni en la respuesta ni en un resumen al final de otra tarea.
5. Solo AAB: que quedó anotado en `# Bundles` de la nota del vault, con lo que trae de nuevo.

## Qué no hacer

- No leer ni tocar `key.properties`, keystores (`.jks`), `.ppk` ni `.env`.
- No subir versión ni hacer el AAB sin confirmación.
- No dar por entregado un AAB sin anotarlo en `# Bundles` de la nota del vault.
- No inventar rutas de salida; si el archivo no aparece, revisar la carpeta antes de responder.
- No hacer git add, commit ni push.
