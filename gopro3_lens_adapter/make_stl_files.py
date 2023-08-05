#!/usr/bin/env python3
# Export STLs for common lens sizes.

import itertools
import subprocess

DIAMETER = "lens_d"
PITCH = "lens_thread_pitch"
HEIGHT = "lens_thread_height"

pitches = [0.75]
diameters = [30.5, 35.5, 37, 39, 40.5, 43, 46, 49, 52, 58, 67, 72, 77]
heights = [2.0]

for diameter, pitch, height in itertools.product(diameters, pitches, heights):
    filename = f"gopro3_lens_adapter_{diameter}mm_pitch_{pitch}mm_height_{height}mm.stl"
    subprocess.run(["openscad",
                    "-o",
                    filename,
                    "-D",
                    f"{DIAMETER}={diameter}",
                    "-D",
                    f"{PITCH}={pitch}",
                    "-D",
                    f"{HEIGHT}={height}",
                    "--quiet",
                    "gopro3_lens_adapter.scad"])
