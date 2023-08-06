# GoPro Mount for Pole-Shaped Monitor Stands
A GoPro mount for monitors with pole-shaped stands. The mount is offset to center the lens on the pole, and a little cable holder is included.

![](docs/back.webp)
![](docs/front.webp)
![](docs/preview.webp)

Source for the frame used in pictures 1 and 2: https://www.printables.com/model/202221-gopro-hero-3-improved-top-and-bottom-frame-mounts

## Print Settings
* printer: Prusa Mini+
* filament: Prusament PLA Orange
* print settings: 0.2mm with supports (lots of them 😢)

## Customization
`make.py` creates STLs for mounting a GoPro Hero 3 on:
- an LG Ultrafine 27UP85NP [[1]](https://www.lg.com/uk/monitors/uhd-4k-5k/27up85np-w/)
- a Lenovo Thinkvision P27h-30 [[2]](https://www.lenovo.com/gh/en/monitors/p27h-30)

Beyond that:
* To make this design work for other monitor stands, adjust `pole_d` and `pole_sheath_z` in `gopro_monitor_pole_mount.scad`.
* The mount needs to be tall enough that the camera can peek over the monitor. By default, the GoPro mounting axle is located 3cm above the end of the pole (`pole_offset_z = 30`). For tall or vertically oriented monitors, larger values might be required.
* GoPros other than Hero 3 might require a different `gopro_lens_offset` to be horizontally centered.
