#!/usr/bin/env python3

import itertools
import sys
sys.path.append("../python")

from render import Preset, StlPreset, render_parallel


POLE_D = "pole_d"
MOUNTING_STYLE = "mounting_style"
ADD_CABLE_HOLDER = "add_cable_holder"


monitors = {
    "lg_ultrafine": {POLE_D: 55},
    "lenovo_thinkvision": {POLE_D: 46},
    "ergotron_lx": {POLE_D: 35}
}
mounting_styles = {
    "hat": {MOUNTING_STYLE: "hat",
            ADD_CABLE_HOLDER: False},
    "hat_with_holder": {MOUNTING_STYLE: "hat",
                        ADD_CABLE_HOLDER: True},
    "ring": {MOUNTING_STYLE: "ring"}
}

presets = []
for (m, m_overrides), (s, s_overrides) in itertools.product(monitors.items(), mounting_styles.items()):
    name = "_".join([m, s])
    preset = StlPreset(src="gopro_monitor_pole_mount.scad",
                       name=name,
                       overrides=m_overrides | s_overrides | {"$fn": 100})
    presets.append(preset)

render_parallel(presets)
