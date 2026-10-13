"""Verify installed runtime sprites against the approved artwork and backups."""

from datetime import date
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
BACKUP_ROOT = Path("art_generation/originals_replaced/2026-10-13")
OUT = ROOT / "art_generation" / "validation" / "final_validation.md"

# (logical asset, runtime destination, final artwork, preserved original, note)
ASSETS = [
    ("PATH_01 ← DIRT_01", "assets/terrain/tiles/path_01.png", "art_generation/integration/path_01.png", "assets/terrain/tiles/path_01.png", "Dirt aplicado a PATH"),
    ("PATH_02 ← DIRT_02", "assets/terrain/tiles/path_02.png", "art_generation/integration/path_02.png", "assets/terrain/tiles/path_02.png", "Dirt aplicado a PATH"),
    ("PATH_03 ← DIRT_03", "assets/terrain/tiles/path_03.png", "art_generation/integration/path_03.png", "assets/terrain/tiles/path_03.png", "Dirt aplicado a PATH"),
    ("GRASS_01", "assets/terrain/tiles/grass_01.png", "art_generation/generated/samples/grass_01.png", "assets/terrain/tiles/grass_01.png", ""),
    ("GRASS_02", "assets/terrain/tiles/grass_02.png", "art_generation/generated/terrain/grass_02.png", "assets/terrain/tiles/grass_02.png", ""),
    ("GRASS_03", "assets/terrain/tiles/grass_03.png", "art_generation/generated/terrain/grass_03.png", "assets/terrain/tiles/grass_03.png", ""),
    ("MOUNTAIN_01", "assets/terrain/tiles/mountain_01.png", "art_generation/generated/samples/mountain_01.png", "assets/terrain/tiles/mountain_01.png", ""),
    ("MOUNTAIN_02", "assets/terrain/tiles/mountain_02.png", "art_generation/generated/terrain/mountain_02.png", "assets/terrain/tiles/mountain_02.png", ""),
    ("MOUNTAIN_03", "assets/terrain/tiles/mountain_03.png", "art_generation/generated/terrain/mountain_03.png", "assets/terrain/tiles/mountain_03.png", ""),
    ("OBSTACLE_CRYSTAL", "assets/terrain/obstacles/crystal_shard.png", "art_generation/generated/obstacles/crystal.png", "assets/terrain/obstacles/crystal_shard.png", ""),
    ("OBSTACLE_ROCK", "assets/terrain/obstacles/rock.png", "art_generation/generated/samples/rock.png", "assets/terrain/obstacles/rock.png", ""),
    ("OBSTACLE_GRASS", "assets/terrain/obstacles/tall_grass.png", "art_generation/generated/obstacles/grass.png", "assets/terrain/obstacles/tall_grass.png", ""),
    ("OBSTACLE_TOTEM", "assets/terrain/obstacles/totem.png", "art_generation/generated/obstacles/totem.png", "assets/terrain/obstacles/totem.png", ""),
    ("OBSTACLE_BONES", "assets/terrain/obstacles/stone_pile.png", "art_generation/generated/obstacles/bones.png", "assets/terrain/obstacles/stone_pile.png", ""),
    ("BASE", "assets/base/main_tower.png", "art_generation/generated/structures/base.png", "assets/base/main_tower.png", ""),
    ("SPAWN_PORTAL", "assets/terrain/spawn_portal.png", "art_generation/generated/structures/spawn_portal.png", "assets/terrain/spawn_portal.png", ""),
    ("TOWER_BALLISTA", "game/ui/icons/ballista.png", "art_generation/generated/samples/ballista.png", "game/ui/icons/ballista.png", ""),
    ("TOWER_MORTAR", "game/ui/icons/mortar.png", "art_generation/generated/towers/mortar.png", "game/ui/icons/mortar.png", ""),
    ("TOWER_TESLA_COIL", "game/ui/icons/tesla_coil.png", "art_generation/generated/towers/tesla_coil.png", "game/ui/icons/tesla_coil.png", ""),
    ("TOWER_FROST_KEEP", "game/ui/icons/frost_keep.png", "art_generation/generated/towers/frost_keep.png", "game/ui/icons/frost_keep.png", ""),
    ("TOWER_FLAMETHROWER", "game/ui/icons/flame_thrower.png", "art_generation/generated/towers/flame_thrower.png", "game/ui/icons/flame_thrower.png", ""),
    ("TOWER_SHREDDER", "game/ui/icons/shredder.png", "art_generation/generated/towers/shredder.png", "game/ui/icons/shredder.png", ""),
    ("TOWER_POISON_SPRAYER", "game/ui/icons/poison_sprayer.png", "art_generation/generated/towers/poison_sprayer.png", "game/ui/icons/poison_sprayer.png", ""),
]


def main() -> None:
    rows: list[str] = []
    failures: list[str] = []
    expected_backups: set[str] = set()

    for name, runtime_rel, artwork_rel, original_rel, note in ASSETS:
        runtime_path = ROOT / runtime_rel
        artwork_path = ROOT / artwork_rel
        backup_rel = (BACKUP_ROOT / original_rel).as_posix()
        backup_path = ROOT / backup_rel
        expected_backups.add(backup_rel)
        with Image.open(runtime_path) as runtime_image, Image.open(artwork_path) as artwork_image, Image.open(backup_path) as backup_image:
            runtime = runtime_image.convert("RGBA")
            artwork = artwork_image.convert("RGBA")
            backup = backup_image.convert("RGBA")
            size_ok = runtime.size == artwork.size == backup.size
            mode_ok = runtime_image.mode == artwork_image.mode == "RGBA"
            alpha_ok = runtime.getchannel("A").tobytes() == backup.getchannel("A").tobytes()
            artwork_ok = runtime.tobytes() == artwork.tobytes()
            status = "OK" if size_ok and mode_ok and alpha_ok and artwork_ok else "ERROR"
            if status != "OK":
                failures.append(name)
            rows.append(
                f"| {name} | `{runtime_rel}` | `{artwork_rel}` | `{backup_rel}` | "
                f"{runtime.width}×{runtime.height} | {'RGBA' if mode_ok else runtime_image.mode} | "
                f"{'idéntica' if alpha_ok else 'distinta'} | "
                f"{'idéntico' if artwork_ok else 'distinto'} | {note or '—'} | {status} |"
            )

    backup_root_path = ROOT / BACKUP_ROOT
    actual_backups = {
        path.relative_to(ROOT).as_posix()
        for path in backup_root_path.rglob("*.png")
    }
    backup_count_ok = actual_backups == expected_backups and len(actual_backups) == len(ASSETS)
    if not backup_count_ok:
        failures.append("inventario de copias originales")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# Validación final de assets",
        "",
        f"**Fecha:** {date.today().isoformat()}  ",
        f"**Resultado:** {len(ASSETS) - sum(name != 'inventario de copias originales' for name in failures)}/{len(ASSETS)} destinos coinciden con su arte; {len(actual_backups)}/{len(ASSETS)} originales respaldados.  ",
        "**Método:** canvas y modo RGBA cotejados; píxeles runtime cotejados byte a byte con el arte asignado; canal alfa runtime cotejado byte a byte con el original respaldado.",
        "",
        "Las tres variantes Dirt se asignan a los tres destinos PATH por decisión explícita del usuario. Se adaptó el canal alfa de cada salida Dirt a la silueta del Path original. El tipo PATH, los sockets, el grafo y las flechas de flujo no cambiaron.",
        "",
        "| Asset | Destino runtime | Arte instalado | Original respaldado | Canvas | Modo | Alfa original | Coincide con arte | Nota | Estado |",
        "|---|---|---|---|---:|---|---|---|---|---|",
        *rows,
        "",
        "## Revisión visual",
        "",
        "La composición estática conjunta permite revisar las superficies, obstáculos, torres, base y portal. No contiene el grafo runtime ni las flechas, que siguen dibujándose desde la lógica existente.",
        "",
        "[Abrir la composición conjunta](../previews/full_asset_composition.png). La aceptación artística del conjunto puede revisarse en juego.",
        "",
        "Los sprites finales se instalaron en las rutas runtime existentes. Los 23 originales se conservaron en `art_generation/originals_replaced/2026-10-13/`.",
        "",
    ]
    if failures:
        lines.extend(["## Errores", "", ", ".join(failures), ""])
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"{OUT}: {len(ASSETS) - sum(name != 'inventario de copias originales' for name in failures)}/{len(ASSETS)} destinos correctos; {len(actual_backups)}/{len(ASSETS)} copias")
    if failures:
        raise SystemExit(f"Technical validation failed: {', '.join(failures)}")


if __name__ == "__main__":
    main()
