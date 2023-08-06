#!/usr/bin/env python3
# Export STL and DXF files.

import argparse
import pathlib
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("text", type=str, help="Text shown on the pedestal")
args = parser.parse_args()

target_path = pathlib.Path("target")
target_path.mkdir(exist_ok=True)

subprocess.run(
    ["openscad", "-o", str(target_path / "pedestal.stl"), "-D", f"text=\"{args.text}\"", "pedestal.scad"]
)
subprocess.run(["openscad", "-o", str(target_path / "statue.stl"), "statue.scad"])
subprocess.run(["openscad", "-o", str(target_path / "statue_2d.dxf"), "statue_2d.scad"])
