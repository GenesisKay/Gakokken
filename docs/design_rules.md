# Reglas de Diseño - Centavito (MIDIKKI)

Este documento define las reglas estrictas de diseño para asegurar una interfaz consistente, moderna y mantenible.

## 1. Colores y Temas

**Regla de Oro:** NUNCA usar colores hardcoded (ej. `Colors.red`, `Color(0xFF...)`).

### Uso de `AppColorExtension`
Todos los colores del sistema deben provenir exclusivamente de `context.colors` (definido en `lib/core/theme/color_extensions.dart`).

- **Fondos:**
    - `bgInfoCard`: Para tarjetas principales o destacados.
    - `bgElevated`: Para tarjetas y superficies elevadas.
    - `bgSecondary`: Para fondos secundarios o secciones sutiles.
    - `surfaceHover`: Para elementos interactivos o pistas de fondo (background tracks).

- **Estados:**
    - `stateSuccess`: Para ingresos y balances positivos (Verde).
    - `stateError`: Para gastos y balances negativos (Rojo).
    - `stateInfo`: Para ahorros o información neutral (Azul).
    - `stateWarning`: Para alertas o estados intermedios (Naranja).

- **Gráficos:**
    - Usar `chart1` hasta `chart8` para visualizaciones de datos generales.

### Excepción
La **ÚNICA** excepción a esta regla son los colores definidos dinámicamente por el usuario para entidades específicas:
- **Carteras (Wallets)**
- **Categorías**
- **Metas de Ahorro**

En estos casos, se permite usar `Color(entity.color)` o convertir el string hexagonal almacenado en base de datos.

---

## 2. Tipografía

**Regla de Oro:** NUNCA definir estilos de texto manualmente (ej. `TextStyle(fontSize: 20)`).

### Uso de `AppTypography`
Todos los estilos de texto deben provenir de `context.typography` (definido en `lib/core/theme/typography.dart`).

- **Títulos:** `pageTitle`, `sectionHeader`, `cardTitle`.
- **Cuerpo:** `body`, `bodySmall`.
- **Datos:** `bigStat`, `small`.

### Modificaciones
Si se requiere ajustar un estilo (ej. cambiar color o peso), usar `.copyWith()` sobre el estilo base del tema.

```dart
// Correcto
Text('Saldo', style: context.typography.body.copyWith(fontWeight: FontWeight.bold));

// Incorrecto
Text('Saldo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
```

---

## 3. Componentes Reutilizables

- **Tarjetas:** Usar `AppCard` (o contenedores con decoración consistente `bgElevated`/`bgSecondary` con bordes sutiles) en lugar de `Card` nativo de Material.
- **Gráficos:** Encapsular lógica compleja de gráficos en widgets independientes (ej. `MonthlySummaryChart`, `DashboardCategoryPies`) para mantener las pantallas limpias.

---

> [!IMPORTANT]
> Cualquier nueva implementación de UI debe ser validada contra estas reglas antes de ser aprobada.
