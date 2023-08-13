import itertools
import math
import pathlib
import subprocess


RESOLUTION = 100


def make_tray_surface(resolution: int):
    # in multiples of Pi
    phase_x = 0.75
    phase_y = 0.5
    periods_x = 2.0
    periods_y = 2.0

    surface = [[] for _ in range(resolution)]
    for row, col in itertools.product(range(resolution), range(resolution)):
        rad_x = (phase_x + row / float(resolution)) * math.pi * 2 * periods_x
        rad_y = (phase_y + col / float(resolution)) * math.pi * 2 * periods_y
        value = math.cos(rad_x) * math.cos(rad_y)
        # scale into [0, 1] interval
        value = (value + 1) / 2
        surface[row].append(value)

    output_rows = []
    for row in surface:
        output_rows.append(" ".join([f"{v:.4f}" for v in row]))
    output_str = f"# {resolution}x{resolution} grid\n" + "\n".join(output_rows)

    with open("tray_surface.dat", "w") as f:
        f.write(output_str)


make_tray_surface(RESOLUTION)
target_path = pathlib.Path("target")
target_path.mkdir(exist_ok=True)

diameters = [60, 80, 100]
print("Creating STLs (stay patient, it will take a while)...")
for diameter in diameters:
    for filename in ("base_ringmount", "base_standalone", "tray"):
        subprocess.run(["openscad",
                        "-o",
                        target_path / f"{diameter}mm_{filename}.stl",
                        "-D",
                        f"tray_surface_resolution={RESOLUTION}",
                        "-D",
                        f"tray_d={diameter}",
                        "--quiet",
                        f"{filename}.scad"])
