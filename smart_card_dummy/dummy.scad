include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

// on what side of the laptop the smart card reader is located
slot_location = "right";    // [right, left]
// by how many mm the card sticks out when pushed all the way in
slot_card_sticking_out_x = 25;      // [0:0.1:49]
// height of slot opening in mm
slot_z = 1.5;   // [0.75:0.05:3]
// radius of round corners of the slot in mm
slot_r = 0.5;   // [0:0.1:1.0]

// ----------------------------------------------------------------------------
// PARAMETERS

// length of ramp from card thickness to slot thickness
ramp_x = 7; // [0:1:20]

// use honeycomb pattern to save a bit of filament
enable_honeycomb = true;

// thickness of solid border around the honeycomb pattern
honeycomb_border_t = 3; // [2:1:5]


// ----------------------------------------------------------------------------
// SPECS

module __block_customizer__ () {}

// slicer layer height for optimal results
layer_height = 0.15;

// ID-1 smart card, see ISO/IEC_7810
// https://en.wikipedia.org/wiki/ISO/IEC_7810
card_x = 85.6;
card_y = 53.98;
card_z = 0.75;
card_r = 3;
card_chip_x = 14;
card_chip_y = 13;
card_chip_pos_x = 8.5;
card_chip_pos_y = card_y - 29.5;


// ----------------------------------------------------------------------------
// PARTS

// x length of the part
dummy_x = card_x - slot_card_sticking_out_x;

// The opening of the slot in the chassis extends above and below the card. We
// want to cover as much of the slot z-height as possible. When printing
// without supports, this means we can only cover the z-height of the card,
// plus the remaining z-height of the slot above the card. Prototype prints
// where the printed part covered the full slot height and was meant to bend in
// place to avoid having to print with supports did NOT fit.
dummy_max_z = card_z + (slot_z - card_z) / 2;

module dummy_outline_2d() {
    left_half_x = card_chip_pos_x + card_chip_x + 2 * card_r + dif;

    // left half with rounding radius to spec
    round_chamfer(r=card_r, keep_size=true) {
        difference() {
            square([left_half_x, card_y]);

            // remove chip area to protect metal contacts
            translate([-dif, card_chip_pos_y]) {
                square([card_chip_pos_x + card_chip_x + dif, card_chip_y]);
            }
        }
    }
    // right half with sharper rounding radius -- make it longer by card_r
    // then translate by -card_r to cover the rounded radius left behind by
    // the left half
    translate([left_half_x - card_r, 0]) {
        round_chamfer(r=card_r/4, keep_size=true) {
            difference() {
                square([dummy_x - left_half_x + card_r, card_y]);

                // create hook for removal
                translate([dummy_x - left_half_x + card_r, card_y/2]) {
                    rotate([slot_location == "right"? 0 : 180, 0, 0]) {
                        polygon([[-1.5, -0.28 * card_y],
                                 [-7, 0.37 * card_y],
                                 [-5, 0.37 * card_y],
                                 [0, -0.23 * card_y]]);
                    }
                }
            }
        }
    }
}

module dummy_skeletonized_2d() {
    module inner() {
        difference() {
            offset(r=-honeycomb_border_t) {
                dummy_outline_2d();
            }
            // In the hardware of the reader there is a mechanism that checks
            // the presence of the card with a kind of brush. The brush gets
            // caught in the honeycomb pattern, so we disable the honeycomb
            // pattern for this area.
            square([dummy_x, card_chip_pos_y]);
        }
    }
    if (enable_honeycomb) {
        intersection() {
            inner();
            rotate([0, 0, 15]) {
                honeycomb_2d(s=4.5, t=2, x=14, y=6);
            }
        }
        difference() {
            dummy_outline_2d();
            inner();
        }
    } else {
        dummy_outline_2d();
    }
}

module dummy_3d() {
    difference() {
        intersection() {
            // base shape
            translate([0, 0, -card_z/2]) {
                linear_extrude(height=dummy_max_z) {
                    dummy_skeletonized_2d();
                }
            }

            // rounded ends, to fit the slot
            translate([0, 0, slot_z/2]) {
                rotate([0, 90, 0]) {
                    linear_extrude(height=dummy_x) {
                        round_chamfer(r=slot_r, keep_size=true) {
                            square([slot_z, card_y]);
                        }
                    }
                }
            }

            // z-height transitioning from card_z to dummy_max_z
            translate([0, 0, -card_z/2]) {
                cube([dummy_x, card_y, card_z]);
                translate([dummy_x - honeycomb_border_t, 0, 0]) {
                    hull() {
                        cube([honeycomb_border_t, card_y, dummy_max_z]);
                        translate([-ramp_x, 0, 0]) {
                            cube([ramp_x, card_y, card_z]);
                        }
                    }
                }
            }
        }

        // text indicating correct insertion
        translate([21, 4, card_z/2 - layer_height]) {
            linear_extrude(height=layer_height + dif) {
                rotate([0, 0, slot_location == "right"? 0 : 180]) {
                    text("This side up", size=5, font="Liberation Sans:style=Bold", halign="center", valign="center");
                }
            }
        }
    }
}

dummy_3d();
