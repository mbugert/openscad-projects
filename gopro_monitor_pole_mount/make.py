#!/usr/bin/env python3
# Export STLs for common monitor sizes.

import itertools
import pathlib
import subprocess

POLE_D = "pole_d"
POLE_SHEATH_Z = "pole_sheath_z"
ADD_CABLE_HOOK = "add_cable_hook"

monitors = {
    "lg_ultrafine": {POLE_D: 55,
                     POLE_SHEATH_Z: 15},
    "lenovo_thinkvision": {POLE_D: 46,
                           POLE_SHEATH_Z: 26}
}
cable_hooks = [True, False]

target_path = pathlib.Path("target")
target_path.mkdir(exist_ok=True)

for monitor, add_cable_hook in itertools.product(monitors, cable_hooks):
    filename = f"gopro_monitor_pole_mount_{monitor}{'_with_hook' if add_cable_hook else ''}.stl"

    overrides = []
    for key, value in monitors[monitor].items():
        overrides += ["-D", f"{key}={value}"]
    subprocess.run(["openscad",
                    "-o",
                    target_path / filename,
                    *overrides,
                    "--quiet",
                    "gopro_monitor_pole_mount.scad"])
