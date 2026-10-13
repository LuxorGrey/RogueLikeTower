"""Export a generated high-resolution sprite on the source canvas and alpha mask."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def export_like_source(source_path: Path, generated_path: Path, output_path: Path) -> None:
    with Image.open(source_path) as source_image, Image.open(generated_path) as generated_image:
        source = source_image.convert("RGBA")
        generated = generated_image.convert("RGBA")
        fitted = generated.resize(source.size, Image.Resampling.LANCZOS)
        fitted.putalpha(source.getchannel("A"))

        output_path.parent.mkdir(parents=True, exist_ok=True)
        fitted.save(output_path, format="PNG", optimize=True)

    with Image.open(output_path) as exported:
        if exported.size != source.size or exported.mode != "RGBA":
            raise RuntimeError("Export did not preserve the source canvas and RGBA mode.")
        if exported.getchannel("A").tobytes() != source.getchannel("A").tobytes():
            raise RuntimeError("Export alpha mask differs from the source alpha mask.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--generated", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    export_like_source(args.source, args.generated, args.output)
    with Image.open(args.output) as result:
        print(f"{args.output}: {result.width}x{result.height} {result.mode}; source alpha preserved")


if __name__ == "__main__":
    main()
