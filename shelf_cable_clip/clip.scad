include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

// shelf thickness
shelf_t = 18.35;         // [0.1:0.1:100]

// ----------------------------------------------------------------------------
// PARAMETERS

// hole diameter for cables
cable_d = 11;           // [1:0.1:50]

// at what angle the arms pinch the shelf
pinch_angle = 10;       // [0:1:20]

// length of clip arms
arm_length = 20;        // [5:1:40]

// clip height
height = 10;            // [3:1:20]

// radius for rounding sharp corners
rounding_r = 0.6;       // [0.0:0.1:2.0]

// part thicknesses
arm_t = max(min(cable_d / 4, 5), 2.25);
ring_t = max(min(cable_d / 3, 5), 2.5);

// ----------------------------------------------------------------------------
// PARTS

module clip_2d_half() {
    rotate([0, 0, -pinch_angle]) {
        r = cable_d / 2 + clearance_medium;
        union() {
            difference() {
                circle_section(r + ring_t, 90 + pinch_angle);
                circle_section(r, 90 + pinch_angle);
            }
            translate([r, -r]) {
                square([ring_t, r]);
            }
        }

        translate([r, -r]) {
            // section between ring and clip arms
            x = shelf_t / 2 + clearance_medium - r;
            square([x + arm_t, ring_t]);

            // clip arm
            translate([x, -arm_length]) {
                square([arm_t, arm_length + arm_t]);
            }
        }
    }
}

module clip_2d() {
    round_chamfer(r=rounding_r, keep_size=true) {
        clip_2d_half();
        mirror([1, 0, 0]) {
            clip_2d_half();
        }
    }
}

module clip() {
    linear_extrude(height=height) {
        clip_2d();
    }
}

clip();
