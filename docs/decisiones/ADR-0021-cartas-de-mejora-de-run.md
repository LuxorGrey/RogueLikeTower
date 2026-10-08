# ADR-0021 — Cartas de mejora dentro de la run

- Estado: aceptado para el prototipo; lista de operaciones ampliada por ADR-0023; calendario y balance provisionales.
- Fecha: 2026-10-08.
- Contexto: M11 del roadmap requiere `CardData`, oferta/selección, modificadores de torre/globales/maná, filtro por unlocks y un pool inicial. M10 ya coloca una pieza de terreno tras cada ronda 1–19. El diseño deja abierta la cantidad/frecuencia final de cartas y define la fase de carta después de la expansión.

## Decisiones

1. Separar definición, pool y estado runtime: `CardModifierOperation` describe una operación; `CardData` contiene texto/rareza/unlock/operaciones/límite; `CardPoolData` define el pool y calendario; `RunCardService` mantiene ofertas y elecciones de la run.
2. Ejecutar el ciclo en el orden documentado: completar ronda → recompensa → expansión/colocación de terreno → si corresponde, `CARD_OFFER` → preparar la siguiente ronda. `CARD_OFFER` bloquea la siguiente ronda hasta elegir una carta. Las cards de M10 para terreno no son `CardData`.
3. Usar tres opciones, primera oferta después de ronda 3 y luego cada tres rondas hasta la 18. Los datos `offer_size`, `first_offer_round` y `offer_interval` son configurables en `data/cards/demo_card_pool.tres`; esta decisión habilita pruebas de la demo y no cierra el calendario final.
4. Elegir sin duplicados en una oferta, usando `offer_weight`; `unlock_requirement` filtra contenido específico, y `max_per_run` limita repeticiones elegidas. Las cartas ofrecidas pero no seleccionadas permanecen disponibles.
5. Usar modificadores aditivos que se suman y multiplicadores que se componen multiplicando. El set admite daño, alcance, radio de área, coste de maná, duración de estado, maná máximo/regeneración, crítico y suma al multiplicador Health/Armor/Shield. RPM es fijo salvo Frost Keep por cobertura PATH; la operación histórica de cadencia no se ofrece en cartas. Un servicio de run local a `Main` aplica los resultados a torres nuevas/existentes y a la economía.
6. No modificar Resources compartidos. Los status payloads se duplican antes de ajustar duración; `TowerData` y `RunEconomyData` conservan los valores base. La selección y los efectos no se guardan entre runs; M12 conserva los unlocks meta, no las cartas elegidas ni sus modificadores temporales.
7. Configurar 12 cartas originales placeholder para los siete perfiles actuales, estadísticas globales y maná. M12 añade dos cartas de Archivo y M12A añade una global de crítico y tres mejoras globales de multiplicador H/A/S: 18 cartas en el pool actual. Los nombres, pesos, rarezas y cifras son provisionales; las tres mejoras por capa reproducen la forma general de `Monster Studies` consultada como referencia, no una copia completa de sus árboles.

## Consecuencias

- La elección puede cambiar el comportamiento de una run sin añadir sistemas de inventario o edificios de soporte.
- La selección modifica también torres construidas antes de obtenerla, ya que estas consultan el proveedor común de modificadores.
- El HUD de torre/economía presenta los valores efectivos y el preview de construcción incorpora alcance global/específico.
- M12 conecta el filtro a `MetaProgression.get_unlocked_content_ids()` y añade dos cartas que requieren el upgrade permanente `card_archive`; las 12 opciones originales mantienen su configuración M11.
- Ver criterios y procedimiento de aceptación manual en [M11](../fuente_de_verdad/10_ACCEPTANCE_TESTS.md#m11-cartas-de-mejora).
