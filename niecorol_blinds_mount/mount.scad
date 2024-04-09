include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Measurements] */

// x-thickness of Nie-Co-Rol top hook
ncr_hook_x = 7;

// y-height of half-circle hole inside Nie-Co-Rol top hook (give or take)
ncr_hook_inner_y = 4;

// z-height of half-circle hole inside Nie-Co-Rol top hook (give or take)
ncr_hook_inner_z = 3;

// z-thickness of the top section of the Nie-Co-Rol hook
ncr_hook_top_z = 2;

// y-thickness of the blob at the end of the hook
ncr_hook_blob_y = 6;

// T-shape that fits the roller blinds' aluminium extrusion ("t_...")
t_z = 8.5;
t_thin_x = 1.8;
t_thick_x = 3;
t_thick_z = 3.2;
t_arm_z = 3.2;
// 4.5 if the thick section is towards the bottom, otherwise 3.3
t_arm_x = 4.5;

// ----------------------------------------------------------------------------
// PARAMETERS

/* [Parameters] */

t_opening_r = 0.2;
t_closing_r = 0.4;
// y-thickness the blinds section will be extruded to
t_y = 20;   // [1:1:50]

// space reserved for the blinds in their aluminium extrusion
t_blinds_allowance = 0.6;     // [0:0.1:2]

// thickness of NCR loop ("l_...")
l_thickness = 2;
// x-gap for the NCR hook in the loop, in addition to ncr_hook_x
l_gap_x = 1;
// z gap for the NCR hook in the loop, in addition to ncr_hook_top_z and what we account for ncr_hook_blob_y
l_gap_z = 1;
// x-thickness of stem connecting NCR loop to the blinds hook (should be beefy)
l_stem_x = 2.4;
// stem z length
l_stem_z = 10;
// position of stem along the loop
l_stem_pos_x = 1.0;   // [0:0.01:1]
l_stem_closing_r = 3;

// will be multiplied with ncr_hook_inner_y to determine the extrusion thickness of the loop
l_y_factor = 0.8;   // [0:0.1:1]

// chamfer for the part that connects T and loop
connector_chamfer_r = 0.4;


// ----------------------------------------------------------------------------
// DERIVED PARAMETERS

module __Customizer_Limit__ () {}

_t_thin_x = t_thin_x - t_blinds_allowance;
_t_thick_x = t_thick_x - t_blinds_allowance;
_t_arm_z = t_arm_z - t_blinds_allowance;
_t_arm_x = t_arm_x - t_blinds_allowance/2;
_t_arm_pos_z = t_z/2 - t_blinds_allowance;

// ----------------------------------------------------------------------------
// PARTS

// hook to feed into the blinds aluminium extrusion
module blinds_t_hook_2d() {
    // origin is at the tip of the T
    translate([-_t_arm_x, -_t_arm_pos_z]) {
        closing(t_closing_r) {
            opening(t_opening_r) {
                square([_t_thin_x, t_z]);
                square([_t_thick_x, t_thick_z]);
                translate([0, _t_arm_pos_z - _t_arm_z/2]) {
                    square([_t_arm_x, _t_arm_z]);
                }
            }
        }
    }
}

// loop to put the NCR into
module ncr_loop_2d() {
    inner_x = ncr_hook_x + l_gap_x;
    inner_z = max(ncr_hook_top_z, ncr_hook_blob_y) + l_gap_z;
    outer_x = inner_x + 2 * l_thickness;

    module loop_pos() {
        translate([l_thickness - l_stem_pos_x * (outer_x - l_stem_x), -(inner_z+l_thickness)]) {
            children();
        }
    }

    module loop_with_stem() {
        difference() {
            // mesh stem with loop
            closing(l_stem_closing_r) {
                loop_pos() {
                    offset(l_thickness) {
                        square([inner_x, inner_z]);
                    }
                }
                // stem (make it longer so that it's fully connected to the loop)
                translate([0, -l_thickness]) {
                    square([l_stem_x, l_stem_z + l_thickness]);
                }
            }

            // create the hole of the loop
            loop_pos() {
                opening(l_gap_x/2) {
                    square([inner_x, inner_z]);
                }
            }
        }
    }

    // origin is the top left corner of the stem
    translate([0, -l_stem_z]) {
        loop_with_stem();
    }
}

module hook_and_loop_2d() {
    blinds_t_hook_2d();
    translate([0, -_t_arm_z/2]) {
        ncr_loop_2d();
    }

    // connecting shape
    translate([0, -_t_arm_z/2]) {
        round_chamfer(connector_chamfer_r, keep_size=true) {
            translate([0, -l_stem_z/2]) {
                square([l_stem_x, l_stem_z/2]);
            }
            translate([-_t_arm_x/2, 0]) {
                square([_t_arm_x/2, _t_arm_z]);
            }
            polygon([[0, 0], [l_stem_x, 0], [0, _t_arm_z]]);
        }
    }
}


module mount() {
    linear_extrude(t_y) {
        blinds_t_hook_2d();
    }
    linear_extrude(ncr_hook_inner_y * l_y_factor) {
        hook_and_loop_2d();
    }
}

mount();
