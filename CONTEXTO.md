# Contexto del proyecto: T / Gravity

## Resumen
Juego de plataformas de gravedad invertida con 3 mundos y 10 niveles por mundo. Hay dos versiones:
- **Godot 4.3 (GDScript)**: `scripts/game_session.gd`, `level.gd`, `player.gd`, `ui.gd`, `enemy.gd`, tests en `tests/`.
- **Web HTML5 Canvas**: todo en `index.html`. Es la versión que el usuario prueba en el navegador.

Repositorio: https://github.com/aaleo0408-bri/thomas-y-moi (rama `main`, un commit: "creacion del juego"). `index.html` tiene cambios sin commitear.

## Reglas del juego
- 5 vidas. Cada muerte resta una. Con 0 vidas aparece "Fin de la partida".
- Se desbloquea el siguiente nivel con 3 estrellas en el anterior. Se desbloquea el siguiente mundo con 3 estrellas en el nivel 10.
- Controles: A/D o flechas, Espacio para saltar, G para invertir la gravedad, Esc para pausar. Hay controles táctiles.
- Hay coyote time, jump buffer, enemigos que se pisan, pinchos y huecos.
- El progreso se guarda en `localStorage` (web) o en `user://` (Godot).

## Pedidos del usuario
1. Más detalle visual: siluetas y fondos pixel-art bien hechos.
2. Bug: al morir no reaparecía al inicio del nivel y había que refrescar la página.
3. Mapa de mundos: poder navegar entre mundos, con candado en lo bloqueado.
4. Investigar pantallas de otros juegos y usar Playwright para revisar la UI y corregir hallazgos.
5. **Pedido más reciente**: tomar ideas de Tomb of the Mask (siluetas e interfaz), Geometry Dash, el juego de Fernanfloo y Level Devil. Quiere fondo y personaje detallados al estilo Mario, y una UI bien estructurada y bonita.

## Estado
Hecho en `index.html`:
- Sprites del héroe con sombreado (paletas `HP`, `HEAD`, `BODY_*`).
- Navegación de mundos con flechas ‹ › (cíclica), sprites `LOCK_SPR` y `LOCK_LOCKED`.
- `die()` programa `respawn()` con `setTimeout` además del temporizador `lostT` en `update()`.
- `newRun()` ahora borra `state.stars`.

Hecho en `scripts/ui.gd`:
- Candado 🔒 en niveles bloqueados, overlay "MUNDO BLOQUEADO" y navegación libre entre mundos.

Verificación: `test_ui.js` y `test_ui_full.js` (Playwright, servidor en el puerto 8000) generan capturas de título, mapa, juego y mapa del mundo 2.

## Problemas conocidos
- La captura `test_4_map_world2.png` muestra la pantalla de título, no el mapa del mundo 2. El flujo de Playwright (clics por coordenadas y Esc) no llegó al mapa; falta depurarlo.
- `die()` usa `setTimeout` y también el temporizador `lostT`, así que `respawn()` puede dispararse dos veces. Conviene dejar solo uno.
- Los mensajes anteriores afirmaron que todo estaba verificado, pero el test no lo confirma del todo.
- En Godot, `_change_world` ya no comprueba mundos desbloqueados y `show_map` no se probó en el motor.
- Hay una captura sobrescrita y archivos de prueba (`test_*.js`, `*.png`, `node_modules`) sin ignorar en git.
- La búsqueda web de referencias no devolvió resultados. El análisis de Tomb of the Mask, Geometry Dash, Fernanfloo y Level Devil sigue pendiente; se haría con conocimiento general o con otras fuentes.
- El usuario preguntó cómo hacer que el modelo admita imágenes y compartió un endpoint de generación (`/v1/images/generations`, túnel Cloudflare). No se ha usado ni validado. No lo contacto sin su confirmación.

## Siguientes pasos propuestos
1. Corregir el flujo de Playwright y mirar cada pantalla (título, mapa, juego, pausa, muerte, resultados).
2. Quitar el doble respawn.
3. Rediseño visual: fondos por capas estilo Mario (colinas, nubes, árboles, tuberías o edificios), héroe con silueta marcada y contorno oscuro al estilo Tomb of the Mask, botones gruesos con sombra y animación estilo Geometry Dash, y mapa con camino y nodos.
4. Sincronizar los cambios con `ui.gd` y `level.gd`.
5. Commit y push solo cuando el usuario lo pida.
