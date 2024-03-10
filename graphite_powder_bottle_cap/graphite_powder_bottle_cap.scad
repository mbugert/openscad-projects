include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

// outer diameter of the bottle tip
tip_d = 4.6;    // [1:0.1:10]

// z-height of the tip
tip_z = 4.0;    // [1:0.1:10]

// ----------------------------------------------------------------------------
// PARAMETERS

// extra z-height of cap, in addition to the tip z-height
cap_extra_z = 5.0;     // [1:0.1:10]

// wall thickness
t = 1.4;               // [1:0.1:10]

// reduce cap radius by this much at the top
r_reduced_top = 0.2;        // [0.0:0.1:2]

// ----------------------------------------------------------------------------
// PARTS

// We are making a hollow cylinder-shaped cap.
cap_z = tip_z + cap_extra_z;
rotate([180, 0, 0]) {
    difference() {
        cylinder(d1=tip_d + 2*t, d2=tip_d + 2 * (t - r_reduced_top), h=cap_z + t);
        cylinder(d1=tip_d - 2*clearance_medium, d2=tip_d + 2 * (- r_reduced_top - clearance_medium), h=cap_z);
    }
}
