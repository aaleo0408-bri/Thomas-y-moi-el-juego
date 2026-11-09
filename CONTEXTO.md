# Contexto del proyecto: T / Gravity

## Qué es
Juego de plataformas 2D horizontal con **gravedad invertible**. El jugador corre, salta y pulsa G para voltear la gravedad (así camina por el techo). Tiene 3 mundos con 10 niveles cada uno, enemigos que se pisan, pinchos, huecos, estrellas y vidas persistentes. El estilo visual es **pixel art de 8 bits** (una unidad del arte = 2 px en pantalla).

Hay dos implementaciones del mismo juego:
- **Web (HTML5 Canvas)**: `index.html`, un solo archivo. Es la versión que el usuario prueba en el navegador (Chrome, en `http://localhost`). Es la versión de referencia para el arte y la lógica.
- **Godot 4.3 (GDScript)**: `project.godot` y `scripts/`. Es la versión para escritorio/móvil. Va por detrás de la web en arte (ver "Pendiente").

Repositorio: `origin` = https://github.com/aaleo0408-bri/Thomas-y-moi-el-juego.git. Rama de trabajo actual: `pixel-art-8bit` (creada desde `main`). El commit `44533cf` contiene el estado de esta fase. **No hay push hecho**: no subir sin que el usuario lo pida.

## Reglas del juego
- **Vidas:** 5. Cada muerte resta una. Con 0 vidas aparece "FIN DE LA PARTIDA" (volver al mapa o nueva partida).
- **Desbloqueos:** para jugar el nivel N, el N-1 debe tener **3 estrellas**. Para entrar al mundo siguiente, hay que tener 3 estrellas en el nivel 10 del mundo actual.
- **Estrellas:** 3 por nivel, se recogen en el recorrido. Al terminar el nivel se guarda el mejor resultado.
- **Muerte:** caer en un hueco, tocar un enemigo por un lado, tocar pinchos (solo en el suelo, con gravedad normal) o salir de la pantalla. Se reaparece al inicio del nivel (sin refrescar la página).
- **Nueva partida:** si ya hay progreso, pide confirmación ("¿Empezar de cero?") y borra estrellas, mundos y vidas.
- **Pausa:** Esc (PC) o botón II. Desde pausa: continuar, salir al mapa o reiniciar el nivel.

## Controles
- **PC:** A/D o flechas para moverse; Espacio o flecha arriba para saltar; **G** invierte la gravedad; Esc pausa.
- **Táctil (móvil/tablet):** botones ◀ ▶ ▲ en la parte inferior y ↕ para invertir gravedad. Solo aparecen con puntero táctil real (`pointer:coarse`).
- Mecánica de salto: coyote time (0.11 s), buffer de salto (0.13 s) y salto variable (soltar la tecla corta el impulso).

## Guardado
- **Web:** `localStorage` con la clave `tgravity-save-v2` (`{v:2, lives, stars, world, level}`). Valida y descarta datos fuera de rango.
- **Godot:** `user://gravity_runner_save.json` (versión 1). Es un formato distinto al de la web; no se comparten partidas.

## Estructura del repo
```
index.html              Juego web completo (lógica + render + pixel art). Versión de referencia.
project.godot           Proyecto Godot 4.3 (resolución 1152x648, renderer GL Compatibility).
scenes/main.tscn        Escena de arranque (solo llama a boot.gd).
scripts/
  boot.gd               Crea los autoloads GameSession y GameUI al arrancar.
  game_session.gd       Estado global: vidas, estrellas, mundo/nivel actual, guardado, reglas de desbloqueo.
  level.gd              Construye un nivel: suelo, techo, plataformas, huecos, estrellas, pinchos, salida, enemigos y fondo.
  player.gd             Movimiento, salto, coyote time, gravedad invertible, pisotones y daño. Alimenta la animación del héroe.
  enemy.gd              Enemigo que patrulla (slime) y se derrota al pisarlo.
  ui.gd                 Pantallas en CanvasLayer: título, mapa de mundos, HUD, pausa, resultados, fin de partida.
  backdrop.gd           Fondo por capas con parallax (vectorial, todavía sin pasar a pixel art).
  sprite_bank.gd        Convierte las rejillas de sprite_data.gd en texturas (héroe por fotogramas, slime con tono por mundo, plataformas, franjas de suelo, portal, etc.).
  sprite_data.gd        Datos generados de los sprites (rejillas y paletas). No editar a mano.
  sprite_node.gd        Nodo genérico que dibuja una textura de pixel art (estrellas, pinchos, portal).
  hero_art.gd           Nodo visual del héroe: idle, run (4 fotogramas), jump y fall.
  slime_art.gd          Nodo visual del slime (sigue la dirección de patrulla).
  surface_art.gd        Plataformas con textura pixel art.
  ground_art.gd         Suelo y techo del nivel (franjas en textura).
tests/
  test_game_session.gd  Prueba del gestor de sesión (24 comprobaciones). Corre en headless.
test_ui.js, test_ui_full.js
                        Scripts antiguos de Playwright (apuntan a file:// y al puerto 8000 respectivamente; revisar antes de usar).
README.md               Descripción original del proyecto Godot (algunos datos están desactualizados).
package.json            Dependencias de Playwright (devDependencies). node_modules no está versionado.
.gitignore              Excluye node_modules, .godot, .claude, capturas de prueba y referencias .webp.
```

**Referencias de arte (no versionadas, en la raíz):** `heroe 1.webp` (personaje, define el estilo), `slime.webp`, `estrella.webp`, `corazon.webp`, `pinchos.webp`, `portal.webp`. Están ignoradas por `.gitignore` (`/*.webp`).

## Arte y escala (decisión tomada)
- **Escala:** 1 celda de las referencias ≈ 2 px en pantalla. El personaje mide ~58 px (reducción 2x de la referencia de 58 celdas).
- **Personaje:** 16×29 celdas, reducido de `heroe 1.webp` con paleta de 8 clases (K contorno, S piel, H pelo, R camiseta, Y "T" amarilla, B pantalón, G tenis verdes, W suela). El mapeo color→parte se hizo a mano porque la reducción automática confundía el pantalón con el pelo.
- **Animación del personaje:** recorte por partes (cabeza, torso y cada pierna se desplazan por fotograma). No es una animación dibujada a mano. Los brazos no se animan porque no pudieron separarse de la referencia.
- **Estrellas, corazones, pinchos y slime:** reducción 2x de sus referencias, con la misma paleta limitada. El slime cambia de tono por mundo (rotación de matiz, conservando brillo y saturación).
- **Portal de salida:** referencia que gira suavemente, con el color de acento del mundo.
- **Candado:** sigue siendo un sprite generado por código (no hay referencia).
- **Fondos y plataformas de la web:** generados por código (bandas de cielo, montañas, pinos, edificios, cristales), a 2 px por unidad.
- **Regenerar `sprite_data.gd`:** se generó con scripts auxiliares que no están en el repo (hechos en la carpeta temporal del equipo). Si cambian las referencias, hay que regenerarlo.

## Cómo probar
- **Godot (headless, sin ventana):** `Godot_v4.3-stable_win64_console.exe --headless --path . -s res://tests/test_game_session.gd` → debe mostrar 24 PASS y 0 FAIL. Instalado en `%LOCALAPPDATA%\Godot-install\`.
- **Godot (con ventana):** las pruebas headless no cargan el nivel. Para detectar errores de compilación en `level.gd` y los scripts visuales hace falta correr una escena con ventana y entrar al nivel. Ya se hizo así antes (aparecieron errores que el headless no mostraba).
- **Web:** abrir `index.html` por `http://localhost` (las capturas con canvas fallan con `file://` por CORS). Playwright está en `node_modules` (`npm install`). Validar siempre: que no haya errores de JavaScript y que las pantallas (título, mapa, nivel, pausa, resultados) se vean bien.
- **Sintaxis de la web:** extraer el bloque `<script>` y ejecutarlo con `new Function(js)`.

## Historial de pedidos del usuario (resumen)
1. Juego base en Godot 4.3 y versión web (`index.html`).
2. Revisión de funcionalidad y UI con Playwright; investigar reglas de juegos de plataformas.
3. Bugs: al morir no reaparecía al inicio (había que refrescar); mapa de mundos navegable con candados.
4. Pedido más reciente: UI y personajes al nivel de juegos actuales (referencias: Mario, Geometry Dash, Tomb of the Mask). Se decidió no copiar estilos ni personajes de otros juegos.
5. Corrección: el juego era de **8 bits** (no 16). Se rehízo el arte a pixel art con la escala de la referencia del personaje.
6. Animación del personaje al caminar y saltar (en la web, ya hecho).
7. Sprites de referencia (estrella, corazón, pinchos, portal, slime) integrados en la web y en Godot.
8. Commit en rama nueva y `.gitignore`.

## Estado actual
**Hecho**
- Web: juego completo en pixel art a 2 px por unidad; personaje animado (caminar, saltar); sprites de referencia; pantallas de título, mapa, nivel, pausa, resultados, fin de partida y confirmación de borrado; sin errores de JavaScript en las pruebas.
- Godot: personaje, slime, estrellas, pinchos, portal, plataformas y suelo con texturas pixel art; compila; pruebas de sesión en verde.
- Repo: commit `44533cf` en la rama `pixel-art-8bit`, `.gitignore` configurado.

**Pendiente (Godot)**
- Fondos: `backdrop.gd` sigue vectorial; no coincide con el fondo pixel art de la web.
- Pantallas de título, mapa, botones y HUD: siguen con el estilo anterior. Los corazones del HUD son texto (♥), no los sprites de referencia.
- Verificar el juego completo en Godot con ventana (recorrido, muerte, pausa, mapa).

**Pendiente (general)**
- Sprites hechos a mano para estrellas, pinchos, portal, slime y candado (ahora son reducciones de referencias o generados por código).
- Fondos y plataformas de la web pasados a arte dibujado a mano, si el usuario lo pide.
- Decidir si el repo versiona las referencias `.webp` o no.
- Push a GitHub: solo cuando el usuario lo pida.

## Problemas conocidos
- **Animación del personaje:** la caminata y el salto son recortes de la imagen, así que los movimientos son sencillos. Los brazos no se mueven.
- **Mapa de mundos en Godot:** la navegación entre mundos no comprueba el desbloqueo (el de la web sí).
- **Portal de salida:** flota en el aire en los niveles (decisión de diseño de los niveles, no de arte).
- **Pinchos:** solo son mortales con gravedad normal (no al revés).
- **Colores de los fondos en Godot:** no coinciden con la web; la paleta de Godot (`level.gd`, `_world_palette`) es anterior.
- **Pruebas de Playwright antiguas:** `test_ui.js` apunta a `file://` y `test_ui_full.js` al puerto 8000; no reflejan el estado actual.
- **Servidor local:** un servidor de Python en el puerto 8000 pudo quedar corriendo desde las pruebas. Cerrarlo a mano si estorba.
- **CRLF:** git avisa de finales de línea CRLF en los archivos. No afecta al juego.

## Decisiones importantes
- La versión web es la referencia de arte y de lógica. Godot debe seguirla.
- Los estilos de otros juegos se toman como inspiración de género, no se copian sus personajes ni su arte.
- El trabajo se hace por pasos y se verifica con capturas (Playwright para web, ventana de Godot para Godot). Las pruebas headless de Godot no bastan.
- No hacer commit ni push sin pedirlo.
