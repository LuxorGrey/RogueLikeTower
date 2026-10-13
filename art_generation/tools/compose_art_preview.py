"""Compose the generated sprites at their existing gameplay render sizes."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "art_generation" / "previews" / "full_asset_composition.png"
TERRAIN = ROOT / "art_generation" / "generated" / "terrain"
SAMPLES = ROOT / "art_generation" / "generated" / "samples"
OBSTACLES = ROOT / "art_generation" / "generated" / "obstacles"
TOWERS = ROOT / "art_generation" / "generated" / "towers"
STRUCTURES = ROOT / "art_generation" / "generated" / "structures"

TILES = {
    "g1": SAMPLES / "grass_01.png",
    "g2": TERRAIN / "grass_02.png",
    "g3": TERRAIN / "grass_03.png",
    "m1": SAMPLES / "mountain_01.png",
    "m2": TERRAIN / "mountain_02.png",
    "m3": TERRAIN / "mountain_03.png",
    "d1": SAMPLES / "dirt_01.png",
    "d2": TERRAIN / "dirt_02.png",
    "d3": TERRAIN / "dirt_03.png",
}

LAYOUT = [
    ["g1", "g1", "g2", "g3", "m1", "m2", "m3", "d1"],
    ["g1", "g2", "g2", "g3", "m1", "m2", "m3", "d2"],
    ["g3", "g3", "g2", "d1", "d2", "d3", "m2", "m3"],
    ["g1", "d1", "d2", "d3", "d3", "d2", "m3", "m3"],
    ["g1", "g1", "d1", "d2", "d3", "m1", "m2", "m3"],
    ["g2", "g3", "d1", "d2", "m1", "m2", "d3", "d1"],
]


def open_rgba(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def paste_center(canvas: Image.Image, path: Path, size: tuple[int, int], center: tuple[int, int]) -> None:
    sprite = open_rgba(path).resize(size, Image.Resampling.LANCZOS)
    canvas.alpha_composite(sprite, (round(center[0] - size[0] / 2), round(center[1] - size[1] / 2)))


def main() -> None:
    width, height = 1080, 820
    canvas = Image.new("RGBA", (width, height), (38, 35, 32, 255))
    cell_w, cell_h = 90, 104
    origin_x, origin_y = 145, 160

    for row, entries in enumerate(LAYOUT):
        for col, tile_key in enumerate(entries):
            left = origin_x + col * cell_w + (row % 2) * (cell_w // 2)
            top = origin_y + row * 78 - cell_h // 2
            tile = open_rgba(TILES[tile_key]).resize((cell_w, cell_h), Image.Resampling.LANCZOS)
            canvas.alpha_composite(tile, (left, top))

    def cell_center(col: int, row: int) -> tuple[int, int]:
        return (
            origin_x + col * cell_w + (row % 2) * (cell_w // 2) + cell_w // 2,
            origin_y + row * 78,
        )

    # Obstacles render at 86x86, centered on a cell with the project's +6 Y offset.
    obstacle_positions = [
        (OBSTACLES / "crystal.png", 0, 0),
        (SAMPLES / "rock.png", 6, 0),
        (OBSTACLES / "grass.png", 4, 1),
        (OBSTACLES / "totem.png", 0, 4),
        (OBSTACLES / "bones.png", 5, 5),
    ]
    for path, col, row in obstacle_positions:
        cx, cy = cell_center(col, row)
        paste_center(canvas, path, (86, 86), (cx, cy + 6))

    # Tower icons render at approximately 84x84 with their existing -36 Y anchor.
    tower_positions = [
        (SAMPLES / "ballista.png", 1, 1),
        (TOWERS / "mortar.png", 3, 2),
        (TOWERS / "tesla_coil.png", 5, 3),
        (TOWERS / "frost_keep.png", 7, 1),
        (TOWERS / "flame_thrower.png", 1, 4),
        (TOWERS / "shredder.png", 3, 5),
        (TOWERS / "poison_sprayer.png", 6, 4),
    ]
    for path, col, row in tower_positions:
        cx, cy = cell_center(col, row)
        paste_center(canvas, path, (84, 84), (cx, cy - 36))

    # Main structures use their current runtime presentation sizes and offsets.
    cx, cy = cell_center(0, 2)
    paste_center(canvas, STRUCTURES / "spawn_portal.png", (64, 96), (cx, cy - 44))
    cx, cy = cell_center(7, 5)
    paste_center(canvas, STRUCTURES / "base.png", (176, 176), (cx, cy - 12))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(OUT, format="PNG", optimize=True)
    print(f"{OUT}: {width}x{height} RGB; all 23 final sprites composed at gameplay scale")


if __name__ == "__main__":
    main()
