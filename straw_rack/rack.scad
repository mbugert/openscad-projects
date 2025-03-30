include <../shared/common.scad>

$fn = 80;

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Measurements] */

// straw length
straw_l = 180;  // [5:0.1:300]

// straw inside diameter
straw_inner_d = 7;      // [1:0.1:50]

// straw outside diameter
straw_outer_d = 8;      // [1:0.1:50]

// Inside drawer height. Reduce it by (1) the amount of top clearance you want, (2) the thickness of any adhesive tape for attaching the print to the drawer.
drawer_z = 77;      // [1:0.1:300]


// ----------------------------------------------------------------------------
// PARAMETERS

/* [Parameters] */

// visual aid
show_straws_and_drawer = false;

// number of straws
num_straws = 4;     // [1:1:20]

// distance between straws
straw_distance = 1;       // [0:0.1:20]

// by how much the resting shelf for a straw is enclosing the straw
straw_enclose = 0.5;     // [0:0.05:1]

// pin diameter will be `straw_inner_d` minus this value
pin_clearance = 0.07;        // [0:0.01:1]

// length of cylindrical section of the pins to place the straws on
pin_cyl_l = 8;      // [0:0.5:100]

// length of conical section of the pins to place the straws on
pin_cone_l = 10;      // [0:0.5:100]

// extra width for the area around the pin that the tip of the straw will rest against
pin_rest_rim_w = 1;        // [0:0.01:5]

// base z-height (becomes relevant when straws are nearly upright)
base_z = 2;       // [0.1:0.1:20]

// rounding radius (cosmetic effect)
base_rounding_r = 0.8;

// ----------------------------------------------------------------------------
// DERIVED PARAMETERS

module __Customizer_Limit__ () {}

// compute steepest possible x-axis straw rotation that still fits in the drawer
available_z = drawer_z - base_z;
function height(angle) = cos(angle) * straw_l + sin(angle) * straw_outer_d;
heights_by_angle = [ for (angle = [0 : 0.5 : 90]) if (available_z - height(angle) > 0) angle ];
steepest_angle = min(heights_by_angle);

pin_d = straw_inner_d - pin_clearance;
pin_rest_d = straw_outer_d + 2 * pin_rest_rim_w;
pin_negative_r = straw_outer_d/2 + clearance_fit;
enclosing_z = (pin_rest_d/2 + pin_negative_r) * sin(steepest_angle);
pin_distance_rot = (straw_distance + pin_rest_d) / cos(steepest_angle);

// ----------------------------------------------------------------------------
// PARTS

module pin_positive() {
    rotate_extrude() {
        square([pin_d/2, pin_cyl_l]);
        translate([0, pin_cyl_l + pin_cone_l]) {
            rotate([0, 0, -90]) {
                curve_2d("sqrt", pin_cone_l, pin_d/2);
            }
        }
    }
}

// straw to use for difference ops
module straw_negative() {
    linear_extrude(straw_l) {
        round_chamfer(r=base_rounding_r, keep_size=true) {
            circle(r=pin_negative_r);
            translate([-pin_negative_r, -2 * pin_negative_r]) {
                square([2 * (1 - straw_enclose) * pin_negative_r, 4 * pin_negative_r]);
            }
        }
    }
}

module straw() {
    color("purple", 0.4) {
        linear_extrude(straw_l) {
            difference() {
                circle(d=straw_outer_d);
                circle(d=straw_inner_d);
            }
        }
    }
}

module rotate_pin() {
    rotate([0, steepest_angle, 0]) {
        translate([-pin_rest_d/2, 0, 0]) {
            children();
        }
    }
}

module pin_positions() {
    for (s = [0:num_straws-1]) {
        translate([s * pin_distance_rot, 0]) {
            children();
        }
    }
}

module rack() {
    translate([0, 0, base_z]) {
        difference() {
            translate([0, 0, -base_z]) {
                linear_extrude(enclosing_z + base_z) {
                    round_chamfer(base_rounding_r, keep_size=true) {
                        pin_positions() {
                            translate([-pin_rest_d, -pin_rest_d/2]) {
                                square([pin_distance_rot, pin_rest_d]);
                            }
                        }
                    }
                }
            }
            pin_positions() {
                rotate_pin() {
                    straw_negative();
                }
            }
        }
        pin_positions() {
            rotate_pin() {
                pin_positive();

                if (show_straws_and_drawer) {
                    straw();
                }
            }
        }
    }
}

// drawer
if (show_straws_and_drawer) {
    color("lightgray") {
        translate([-max_value/2, pin_rest_d/2, 0]) {
            cube([max_value, 10, drawer_z]);
        }
    }
}

rack();
