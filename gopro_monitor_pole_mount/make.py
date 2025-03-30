#!/usr/bin/env python3

import itertools
import sys
sys.path.append("../python")

from render import Preset, StlPreset, render_parallel


POLE_D = "pole_d"
POLE_SHEATH_Z = "pole_sheath_z"
ADD_CABLE_HOLDER = "add_cable_holder"


monitors = {
    "lg_ultrafine": {POLE_D: 55,
                     POLE_SHEATH_Z: 15},
    "lenovo_thinkvision": {POLE_D: 46,
                           POLE_SHEATH_Z: 26}
}
cable_holder = {
    "with_hook": {ADD_CABLE_HOLDER: True},
    "": {ADD_CABLE_HOLDER: False}
}

presets = []
for (m, m_overrides), (c, c_overrides) in itertools.product(monitors.items(), cable_holder.items()):
    name = m + ("_with_holder" if c else "")
    preset = StlPreset(src="gopro_monitor_pole_mount.scad",
                       name=name,
                       overrides=m_overrides | c_overrides | {"$fn": 100})
    presets.append(preset)

render_parallel(presets)
