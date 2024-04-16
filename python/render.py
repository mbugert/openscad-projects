# Python wrapper around 'openscad' for rendering STL/PNG files from SCAD files.

import abc
import concurrent.futures
import dataclasses
import functools
import itertools
import pathlib
import subprocess
from typing import Optional, Any, Union


@dataclasses.dataclass
class Preset(abc.ABC):
    src: Union[str, pathlib.Path]
    name: str = "preset"
    overrides: Optional[dict[str, Any]] = None
    target_dir: pathlib.Path = pathlib.Path("target")

    def render(self) -> list[str]:
        filename = self._get_target_filename()
        print(f"Exporting {filename}...")
        self.target_dir.mkdir(exist_ok=True)

        overrides = []
        if self.overrides is not None:
            for key, value in self.overrides.items():
                overrides.append("-D")
                if type(value) is str or type(value) is bool:
                    overrides.append(f'{key}="{value}"')
                else:
                    overrides.append(f"{key}={value}")

        command = ["openscad",
                   "-o",
                   str(self.target_dir / filename),
                   *overrides,
                   *self.extra_render_args(),
                   "--quiet",
                   str(self.src)]
        subprocess.run(command)

    @abc.abstractmethod
    def _get_target_filename(self) -> str:
        raise NotImplementedError

    def extra_render_args(self) -> list[str]:
        return []


@dataclasses.dataclass
class StlPreset(Preset):

    def _get_target_filename(self) -> str:
        return f"{self.name}.stl"


@dataclasses.dataclass
class PngPreset(Preset):
    camera_translate: tuple[float, float, float] = (0, 0, 0)
    camera_rotate: tuple[float, float, float] = (55, 0, 25)
    camera_distance: float = 140
    camera_projection: str = "p"

    height: int = 600
    width: int = 600

    def _get_target_filename(self) -> str:
        return f"{self.name}.png"

    def extra_render_args(self) -> list[str]:
        cam_floats = [*self.camera_translate, *self.camera_rotate, self.camera_distance]
        camera_settings = ",".join([str(f) for f in cam_floats])
        return ["--camera",
                camera_settings,
                "--imgsize",
                f"{self.width},{self.height}"]


def render_parallel(presets: list[Preset]) -> None:
    with concurrent.futures.ThreadPoolExecutor() as executor:
        _ = [executor.submit(Preset.render, preset) for preset in presets]
