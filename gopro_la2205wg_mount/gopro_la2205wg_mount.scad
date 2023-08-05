include <../shared/common.scad>
use <external/GoPro_Mount.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

screen_top_y = 28.0;
screen_front_max_z = 12.7;
screen_back_max_z = 30;

// ----------------------------------------------------------------------------
// PARAMETERS

thickness = 2.5;
offset_r = thickness / 2.5;
bump_d = thickness * 1.35;

adapter_x = 40;
// add clearance for better fit
adapter_top_y = screen_top_y + 2 * clearance_medium;
adapter_front_z = 0.8 * screen_front_max_z;
adapter_back_z = 0.8 * screen_back_max_z;

// relative positioning of the GoPro mount in y direction, 1.0 is closest to
// the person sitting in front of the screen
mount_pos_y = 0.55;

// ----------------------------------------------------------------------------
// PARTS

module adapter_2d() {
    translate([-thickness, -thickness]) {
        square([thickness, adapter_top_y + 2*thickness]);
        square([adapter_front_z + thickness, thickness]);
        translate([0, adapter_top_y + thickness]) {
            square([adapter_back_z + thickness, thickness]);
        }

        // add bumps at the ends
        translate([adapter_front_z + thickness, thickness/2]) {
            circle(d=bump_d);
        }
        translate([adapter_back_z + thickness, adapter_top_y + 1.5 * thickness]) {
            circle(d=bump_d);
        }
    }
}

module adapter_3d() {
    rotate([0, 90, 0]) {
        translate([0, -adapter_top_y / 2, -adapter_x/2]) {
            linear_extrude(adapter_x) {
                round_chamfer(r=offset_r, keep_size=true)
                    adapter_2d();
            }
        }
    }
}

module positioned_mount3() {
    translate([0, (0.5 - mount_pos_y) * adapter_top_y + (1 - 2*mount_pos_y) * thickness, thickness]) {
        rotate([0, 90, 90])
            translate([-10.5, 0, 0])
                mount3();
    }
}

adapter_3d();
positioned_mount3();
