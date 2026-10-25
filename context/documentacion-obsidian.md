# Documentación: qué va en el vault y qué va en el repo

Regla para personas y agentes (Claude, Cursor u otros). El vault de Obsidian `D:/3-Projects/Software/Vault` es compartido entre el usuario y Claude.

## Regla

1. **El vault guarda el producto:** qué hace hoy la app, pendientes, decisiones de producto e historial. Una sola nota: `D:/3-Projects/Software/Vault/Proyectos/Gakoken.md`.
2. **El repo guarda lo técnico:** arquitectura, código, cómo correr, probar y publicar. También `qa/`, completa y sin referencias a Obsidian, porque QA solo ve el repo.
3. **No duplicar.** Si en el repo hace falta algo del vault, se cita la ruta de la nota, no se copia.
4. **Si un cambio de código cierra una tarea o toma una decisión de producto,** se actualiza la nota del vault en el mismo turno.
5. Sin emojis en ninguno de los dos lados.

## Dónde está cada cosa

| Qué | Dónde |
| --- | --- |
| Producto: qué hace, pendientes, decisiones, historial | `D:/3-Projects/Software/Vault/Proyectos/Gakoken.md` |
| Design System: principios, niveles, decisiones | `D:/3-Projects/Software/Vault/Design System/Design System.md` |
| Tokens, paletas y reglas de la serie | `D:/3-Projects/Software/Vault/Design System/` (`Tokens.md`, `Paletas.md`, `Herramientas Origami.md`, `Temas Flutter.md`) |
| Código | `context/context.md` (mapa del código), `docs/architecture.md` (motor Rust y decisiones técnicas) y `docs/design_rules.md` |
| QA | `qa/` |
| Configuración para agentes | `CLAUDE.md` |
