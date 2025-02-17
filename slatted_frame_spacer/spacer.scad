include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Measurements] */

// slatted frame z-height
frame_z = 47;   // [10:80]
// gap between frames along x axis (left <-> right)
gap_x = 20;     // [1:0.05:80]
// gap between frames along y axis (head <-> toe)
gap_y = 21.5;   // [1:0.05:80]


// ----------------------------------------------------------------------------
// PARAMETERS

/* [Parameters] */

// length of wings extending along the x axis
wing_x = 18;    // [5:40]
// length of the wing extending along the y axis
wing_y = 25;    // [5:80]
// radius for cutout at inside right angles
cutout_r = 4;   // [0:0.1:10]
// outward shifting distance of the right angle cutout position
cutout_shift = 3;   // [0:0.1:10]
// outer rounding radius
round_outer_r = 2;  // [0:0.1:5]


// ----------------------------------------------------------------------------
// DERIVED PARAMETERS

module __Customizer_Limit__ () {}


// ----------------------------------------------------------------------------
// PARTS

module shape_2d() {
    difference() {
        round_chamfer(r=round_outer_r, keep_size=true) {
            mirror_copy([1, 0, 0]) {
                square([gap_x/2 + wing_x, gap_y]);
                square([gap_x/2, gap_y + wing_y]);
            }
        }
        mirror_copy([1, 0, 0]) {
            translate([gap_x/2, gap_y] + cutout_shift * [1, 1]) {
                circle(r=cutout_r);
            }
        }
    }
}

module shape_3d() {
    linear_extrude(frame_z) {
        shape_2d();
    }
}

shape_3d();
