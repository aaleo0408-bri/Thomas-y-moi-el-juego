# T / Gravity

Juego de plataformas 2D horizontal con arte geométrico pixelado, gravedad invertible y controles táctiles. Proyecto nuevo para Godot 4.x.

## Arranque

1. Instala Godot 4.x (renderer compatible con Android/GL Compatibility recomendado).
2. Abre `project.godot` desde el Project Manager o importa la carpeta `juego 1`.
3. Ejecuta el proyecto con F6/F5 o abre la escena principal `scenes/main.tscn`.
4. En escritorio: A/D o flechas para moverse, espacio/flecha arriba para saltar; el botón `↕` invierte gravedad.
5. En móvil: controles táctiles en paisaje. Se necesita Android export template y Android SDK/JDK configurados para generar APK.

## Estado del prototipo

El prototipo tiene 3 mundos con mapas y 10 nodos por mundo, circuitos generados con plataformas, tres estrellas, enemigos patrulleros, obstáculos de suelo, salida, vidas persistentes, resultados y controles táctiles. El jugador tiene salto con tolerancia al borde (coyote time), buffer de salto y gravedad invertible con efecto visual. Los nodos sucesivos se abren con 3 estrellas en el nivel anterior. El avance de mundos requiere 3/3 en el décimo nivel. El guardado valida y descarta claves de progreso fuera de rango.

Todavía no es una versión comercial ni se ha compilado aquí: este entorno no tiene Godot instalado. Los niveles comparten una estructura procedural y los 30 no están hechos a mano; el pixel art es placeholder geométrico; no hay audio, tutorial, jefes, localización completa, arte final, exportación APK ni pruebas en dispositivo real. Existe un test de gestor de sesión en `tests/test_game_session.gd`, pendiente de ejecutarse con Godot instalado.

## Estructura

- `project.godot`: configuración de resolución apaisada y entradas de teclado.
- `scenes/main.tscn`: escena de arranque.
- `scripts/boot.gd`: crea sesión y UI.
- `scripts/game_session.gd`: estado global, guardado local, vidas y desbloqueos.
- `scripts/player.gd`: movimiento, salto, gravedad y daño.
- `scripts/enemy.gd`: enemigo cuerpo a cuerpo patrullero y stomp.
- `scripts/level.gd`: nivel jugable generado, estrellas, salida y muerte.
- `scripts/ui.gd`: título, mapa, HUD, pausa y resultados.

## Próximo paso para validar

Instalar Godot 4.x y ejecutar el proyecto en el editor. Revisar errores del parser, hacer la prueba funcional en ventana horizontal y corregir warnings/errores antes de exportar a Android. Luego probar en móvil con distintas relaciones de aspecto y safe areas.