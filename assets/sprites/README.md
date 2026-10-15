# Sprites del juego

Esta es la raíz única de sprites que usa el runtime y sus recursos de interfaz. Las rutas conservan categorías y subcategorías para que sea fácil ubicar y reemplazar cada asset.

| Carpeta | Contenido |
|---|---|
| `base/` | Sprite de Main Tower |
| `enemies/` | Sprites de enemigos y jefes |
| `terrain/` | Suelos, fachadas, obstáculos, props, portales y cofres; consulta su [catálogo](terrain/README.md) |
| `ui/` | Botones y marcos, más `icons/` y propuestas visuales |
| `third_party/tiny_swords/` | Cursores locales del pack Tiny Swords; están ignorados por Git por su licencia de redistribución. Consulta su [README](third_party/tiny_swords/README.md) |

Las imágenes llevan sus sidecars `.import` en la misma carpeta. Las referencias de runtime, Resources, escenas y herramientas apuntan a esta raíz. Las fuentes de tipografía permanecen en `assets/fonts/`; las propuestas y renders de trabajo permanecen en `art_generation/` y no forman parte del catálogo runtime.
