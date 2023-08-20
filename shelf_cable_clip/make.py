#!/usr/bin/env python3
# Export STLs for several shelf and cable sizes.

import dataclasses
import itertools
import pathlib
import subprocess
from typing import Optional

SHELF_T = "shelf_t"
ARM_LENGTH = "arm_length"
CABLE_D = "cable_d"

@dataclasses.dataclass
class Preset:
    name: Optional[str]
    shelf_t: float
    arm_length: float

presets = [Preset("kallax-inner", 16.2, 20),
           Preset("kallax-outer", 37.2, 20),
           Preset("besta-shelf,outer", 18.35, 15.75),
           Preset("besta-top", 30.7, 15.75),
           Preset("besta-center", 37.7, 15.75),
           Preset("lack", 50.25, 20),
           Preset("generic", 18.35, 20)]

diameters = [5, 11]

target_path = pathlib.Path("target")
target_path.mkdir(exist_ok=True)

for preset, diameter in itertools.product(presets, diameters):
    filename = f"clip_{preset.name}_{preset.shelf_t}mm_cable_{diameter}mm.stl"
    subprocess.run(["openscad",
                    "-o",
                    target_path / filename,
                    "-D",
                    f"{SHELF_T}={preset.shelf_t}",
                    "-D",
                    f"{ARM_LENGTH}={preset.arm_length}",
                    "-D",
                    f"{CABLE_D}={diameter}",
                    "--quiet",
                    "clip.scad"])
