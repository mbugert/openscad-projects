include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Locking Pin Measurements] */
d_inner = 3.5;
d_stem = 2.5;
d_outer = 5.5;
z_inner = 1;
z_stem = 1.4;
z_outer = 1.4;

/* [Metal Part Measurements] */
slot_y = 9.5;
slot_d_small = 2.5;
slot_d_large = 3.5;
slot_angle_yaw = 22.5;

rivet_z = 1.5;
rivet_d = 5;


// ----------------------------------------------------------------------------
// PARAMETERS

/* [Parameters] */

part = "key";   // ["pin", "key"]

// z-height of section that blocks the destapling mechanism
slot_key_z = 4;
// z-height of rim that stops slot key from being pushed in too far
slot_key_rim_z = 1.5;
// rim radius of rim that stops slot key from being pushed in too far
slot_key_rim_r = 1;

// rounding radius
slot_closing_r = 0.5;

// x-thickness of finger grip
grip_x = 5;
// y-length of finger grip
grip_y = 20;
// depth of cutout for thumb
thumb_cutout_x = 2;
// diameter of cutout for thumb
thumb_d = 45;

// diameter of cutout for index finger
index_d = 40;
// depth of cutout for index finger
index_cutout_z = 1.5;

// grip/slot key alignment on y axis
grip_to_slot_key_y = 8.8;


// ----------------------------------------------------------------------------
// DERIVED PARAMETERS

module __Customizer_Limit__ () {}


// ----------------------------------------------------------------------------
// PARTS

module locking_pin_print_oriented() {
    module locking_pin() {
        rotate_extrude() {
            square([d_outer/2, z_outer]);
            translate([0, z_outer]) {
                square([d_stem/2, z_stem]);
                translate([0, z_stem]) {
                    square([d_inner/2, z_inner]);
                }
            }
        }
    }

    translate([0, 0, d_outer/2]) {
        rotate([0, 90, 0]) {
            locking_pin();
        }
    }
}

module locking_key_print_oriented() {

    module slot_shape() {
        round_chamfer(r=slot_closing_r, keep_size=true) {
            translate([0, slot_y/2]) {
                pill(d=slot_d_small, l=slot_y, center=true);
            }
            translate([slot_d_small/2 - slot_d_large/2, slot_d_large/2]) {
                circle(d=slot_d_large);
            }
        }
    }

    module grip() {
        rotate([90, 0, 270]) {
            translate([0, grip_y/2, -grip_x]) {
                difference() {
                    linear_extrude(grip_x) {
                        round_chamfer(slot_closing_r, keep_size=true) {
                            difference() {
                                union() {
                                    circle(d=grip_y);
                                    translate([0, -grip_y/4]) {
                                        square([grip_y, grip_y/2], center=true);
                                    }
                                }
                                // cutout for the rivet area
                                translate([-grip_y/2, -grip_y/2]) {
                                    square([1.2 * rivet_d, rivet_z]);
                                }
                            }
                        }
                    }
                    // thumb cutout
                    translate([0, 0, thumb_d/2 + grip_x - thumb_cutout_x]) {
                        sphere(d=thumb_d);
                    }
                    // index finger cutout
                    translate([0, 0, index_cutout_z - index_d/2]) {
                        rotate([0, 90, 0]) {
                            cylinder(h=max_value, d=index_d, center=true);
                        }
                    }
                }
            }
        }
    }

    module key() {
        grip();
        translate([0, -grip_to_slot_key_y, 0]) {
            rotate([0, 0, -slot_angle_yaw]) {
                translate([0, 0, -slot_key_z]) {
                    linear_extrude(slot_key_z) {
                        slot_shape();
                    }
                }
                linear_extrude(slot_key_rim_z) {
                    minkowski() {
                        slot_shape();
                        circle(r=slot_key_rim_r);
                    }
                }
            }
        }
    }

    rotate([0, 0, 180]) {
        translate([0, 0, grip_y/2]) {
            rotate([90, 0, 0]) {
                key();
            }
        }
    }
}

if (part == "pin") {
    locking_pin_print_oriented();
} else if (part == "key") {
    locking_key_print_oriented();
}
