include <../shared/common.scad>
use <../shared/external/GoPro_Mount.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Measurements] */

// pole diameter of monitor stand
pole_d = 55;    // [1:0.01:100]

// horizontal lens offset from the camera center; used to horizontally align
// the lens above the pole
// GoPro Hero 3: lens is 15mm off to the right
gopro_lens_offset = 15;     // [-50:0.1:50]

// ----------------------------------------------------------------------------
// PARAMETERS

/* [Parameters] */

// wall thickness
thickness = 2.5;    // [1:0.1:5]

// z distance between top of monitor stand and GoPro mounting axle
pole_offset_z = 30;     // [0:1:200]
// z height of sheath around pole (the larger, the sturdier the mount, but make sure the sheath does not collide with the monitor when the monitor is pushed all the way up)
pole_sheath_z = 15;     // [0:1:100]

// radius of flat top of the volcano shape, enough to accomodate the GoPro mount
volcano_crater_r = 14.3;

// enable/disable cable holder
add_cable_holder = true;
// cable holder z height
holder_z = 8;   // [1:1:20]
// cable holder y position
holder_pos_y = -1;  // [-10:1:10]
// cable holder cutout radius
holder_cutout_r = 10;   // [0:1:20]

// ----------------------------------------------------------------------------
// PARTS

pole_r = pole_d / 2;

module sheath_2d(r, t) {
    translate([0, pole_sheath_z]) {
        square([r + clearance_medium, t]);
    }
    translate([r + clearance_medium, 0]) {
        square([t, t + pole_sheath_z]);
    }
}

module cable_holder_cutout() {
    translate([pole_r + clearance_medium, 0, 0]) {
        rotate([0, 90, 0]) {
            cylinder(r=holder_cutout_r, h=4*thickness, center=true);
        }
    }
}

// intersect a scaled up pole sheath with a long, drawn-out shape to produce
// a cable holder shape
module cable_holder_holder() {
    holder_thickness = 0.7 * thickness;
    intersection() {
        x_factor = (pole_r + clearance_medium + 2.2*thickness) / (pole_r + clearance_medium + thickness);
        scale([x_factor, 1, 1]) {
            rotate_extrude() {
                sheath_2d(pole_r, holder_thickness);
            }
        }
        translate([pole_r, holder_pos_y, 0]) {
            translate([0, pole_r, 0]) {
                cube([pole_r * 2, 2 * pole_r, holder_z], center=true);
            }
            rotate([0, -90, 0]) {
                cylinder(d=holder_z, h=2*pole_r, center=true);
            }
        }
    }
}

module bottom() {
    if (add_cable_holder) {
        render() {
            difference() {
                rotate_extrude() {
                    sheath_2d(pole_r, thickness);
                }
                cable_holder_cutout();
            }
        }
        render() {
            cable_holder_holder();
        }
    } else {
        rotate_extrude() {
            sheath_2d(pole_r, thickness);
        }
    }
}

// 2D volcano shape
module volcano_2d() {
    function volcano_x(i) = volcano_crater_r + (i * (pole_r + thickness + clearance_medium - volcano_crater_r));
    function volcano_y(i) = max(0, min(pole_offset_z, -log(i + 1e-7) * pole_r));
    points = [for (i = [0:0.01:1]) [volcano_x(i), volcano_y(i)]];
    points_with_origin = concat([[0, 0], [0, pole_offset_z]], points);
    polygon(points_with_origin);
}

module top() {
    translate([0, 0, pole_sheath_z + thickness]) {
        // in `mount3`, the center wing of the GoPro mount is 2.5mm off which
        // needs to be corrected
        x_offset_for_centered_lens = 2.5 + gopro_lens_offset;

        a = -x_offset_for_centered_lens / pole_offset_z;
        shear_matrix = [[1, 0, a, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [0, 0, 0, 1]];
        multmatrix(shear_matrix) {
            rotate_extrude() {
                volcano_2d();
            }
        }
        translate([-x_offset_for_centered_lens, 0, pole_offset_z]) {
            rotate([0, 90, -90])
                translate([-10.5, 0, 0])
                    mount3();
        }
    }
}

top();
bottom();
