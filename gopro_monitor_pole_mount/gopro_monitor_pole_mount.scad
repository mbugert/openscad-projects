include <../shared/common.scad>
use <../shared/external/GoPro_Mount.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Measurements] */

// pole diameter of monitor stand
pole_d = 55;    // [1:0.01:100]

// Camera: lens position relative to camera center. GoPro Hero 3: 15mm.
cam_lens_offset_x = 15;     // [-50:0.1:50]

// ----------------------------------------------------------------------------
// PARAMETERS

/* [Parameters] */

// wall thickness of hat placed on the pole
hat_t = 2.5;    // [1:0.1:5]
// z height of hat placed on the pole (the larger, the sturdier the mount, but make sure the hat does not collide with the monitor when the monitor is pushed all the way up)
hat_z = 15;     // [0:1:100]

// z distance between top of monitor stand and GoPro mounting axle
cam_raise_z = 30;     // [0:1:200]

// radius of flat top of the volcano shape, enough to accomodate the GoPro mounting fingers
fingers_plat_r = 14.3;

// enable/disable cable holder
add_cable_holder = true;
// cable holder z height
holder_z = 8;   // [1:1:20]
// cable holder y position
holder_pos_y = -1;  // [-10:1:10]
// cable holder cutout radius
holder_cutout_r = 10;   // [0:1:20]
// how much space the holder has for cables
holder_gap = 2.2;
// thickness of the cable holder as a multiple of hat_t
holder_t_factor = 0.7;

// ----------------------------------------------------------------------------
// DERIVED PARAMETERS

module __Customizer_Limit__ () {}

pole_r = pole_d / 2;
cable_holder_t = holder_t_factor * hat_t;

// ----------------------------------------------------------------------------
// PARTS

// hat that sits on top of the pole
module hat_2d(r, t) {
    translate([0, hat_z]) {
        square([r + clearance_medium, t]);
    }
    translate([r + clearance_medium, 0]) {
        square([t, t + hat_z]);
    }
}
module hat_3d() {
    rotate_extrude() {
        hat_2d(pole_r, hat_t);
    }
}

module cable_holder_cutout() {
    translate([pole_r + clearance_medium, 0, 0]) {
        rotate([0, 90, 0]) {
            cylinder(r=holder_cutout_r, h=4 * hat_t, center=true);
        }
    }
}

// intersect a scaled up hat with a long, drawn-out shape to produce
// a cable holder shape
module cable_holder() {
    intersection() {
        x_factor = (pole_r + clearance_medium + holder_gap * hat_t) / (pole_r + clearance_medium + hat_t);
        scale([x_factor, 1, 1]) {
            rotate_extrude() {
                hat_2d(pole_r, cable_holder_t);
            }
        }
        translate([pole_r, holder_pos_y, 0]) {
            translate([0, pole_r, 0]) {
                cube([pole_d, pole_d, holder_z], center=true);
            }
            rotate([0, -90, 0]) {
                cylinder(d=holder_z, h=pole_d, center=true);
            }
        }
    }
}

module bottom() {
    if (add_cable_holder) {
        render() {
            difference() {
                hat_3d();
                cable_holder_cutout();
            }
        }
        render() {
            cable_holder();
        }
    } else {
        hat_3d();
    }
}

// 2D volcano shape
module volcano_2d() {
    function volcano_x(i) = fingers_plat_r + (i * (pole_r + hat_t + clearance_medium - fingers_plat_r));
    function volcano_y(i) = max(0, min(cam_raise_z, -log(i + 1e-7) * pole_r));
    points = [for (i = [0:0.01:1]) [volcano_x(i), volcano_y(i)]];
    points_with_origin = concat([[0, 0], [0, cam_raise_z]], points);
    polygon(points_with_origin);
}

module top() {
    translate([0, 0, hat_z + hat_t]) {
        // in `mount3`, the center finger of the GoPro mount is 2.5mm off which
        // needs to be corrected
        x_offset_for_centered_lens = 2.5 + cam_lens_offset_x;

        a = -x_offset_for_centered_lens / cam_raise_z;
        shear_matrix = [[1, 0, a, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [0, 0, 0, 1]];
        multmatrix(shear_matrix) {
            rotate_extrude() {
                volcano_2d();
            }
        }
        translate([-x_offset_for_centered_lens, 0, cam_raise_z]) {
            rotate([0, 90, -90]) {
                translate([-10.5, 0, 0]) {
                    mount3();
                }
            }
        }
    }
}

module top_mount() {
    top();
    bottom();
}

top_mount();
