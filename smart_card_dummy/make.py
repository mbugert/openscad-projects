#!/usr/bin/env python3
# Export STLs for several laptops.

import dataclasses
import pathlib
import subprocess

@dataclasses.dataclass
class Preset:
    name: str
    slot_location: str
    slot_card_sticking_out_x: float
    slot_r: float
    slot_z: float

presets = [Preset("thinkpad-t14s", "right", 25, 0.5, 1.5),
           Preset("thinkpad-x260", "left", 18, 0.0, 1.2)]

target_path = pathlib.Path("target")
target_path.mkdir(exist_ok=True)

for preset in presets:
    filename = f"dummy_{preset.name}_{preset.slot_card_sticking_out_x}mm.stl"
    subprocess.run(["openscad",
                    "-o",
                    target_path / filename,
                    "-D",
                    f"slot_location=\"{preset.slot_location}\"",
                    "-D",
                    f"slot_card_sticking_out_x={preset.slot_card_sticking_out_x}",
                    "-D",
                    f"slot_r={preset.slot_r}",
                    "-D",
                    f"slot_z={preset.slot_z}",
                    "--quiet",
                    "dummy.scad"])
