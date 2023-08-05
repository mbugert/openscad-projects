include <../shared/common.scad>
use <../shared/external/threads.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

// diameter of rubbered lens housing
gopro_lens_outer_d = 22.8;
// z-height of rubbered lens housing
gopro_lens_outer_z = 8;
// less z-height is usable when the GoPro is inside a frame mount (thickness
// 1.5mm)
gopro_lens_outer_z_usable = gopro_lens_outer_z - 1.5;

lens_d = 37;

// most likely pitch according to online forums, alternative is 0.5
// post-print comment: 0.75 is correct
lens_thread_pitch = 0.75;
lens_thread_height = 2;

// ----------------------------------------------------------------------------
// PARAMETERS

gopro_lens_wall = 1.5;
lens_wall = 1.5;
rounding_r = 2;

// ----------------------------------------------------------------------------
// PARTS

module shape_2d() {
    gopro_outer_r = gopro_lens_outer_d / 2 + gopro_lens_wall;
    lens_outer_r = lens_d / 2 + lens_wall;

    // distance between GoPro lens and macro lens (lens_to_lens_z) should be
    // minimal, but depends on the maximum overhang angle our printer is
    // capable of
    r_to_r = lens_outer_r - gopro_outer_r;
    lens_to_lens_z = r_to_r * tan(90 - printer_max_overhang_degrees);
    // if our printer can handle overhangs very well, lens_to_lens_z can
    // become so small that the lenses collide; the smallest value possible
    // is gopro_lens_outer_z_usable
    effective_lens_to_lens_z = max(gopro_lens_outer_z_usable, lens_to_lens_z);
   
    module outer_shape() {
        // the transitional section is created by a hull op from one lens
        // radius to another
        hull() {
            square([gopro_lens_outer_z_usable, gopro_outer_r]);
            translate([effective_lens_to_lens_z, 0]) {
                square([lens_thread_height, lens_outer_r]);
            }
        }
    }

    module inner_shape() {
        gopro_inner_r = gopro_lens_outer_d / 2 + clearance_medium;
        lens_inner_r = lens_d / 2;

        square([gopro_lens_outer_z_usable, gopro_inner_r]);
        translate([gopro_lens_outer_z_usable, 0]) {
            // the transitional section (if it exists) is created by a hull op
            // from one lens radius to another
            hull() {
                square([1, gopro_inner_r]);
                translate([effective_lens_to_lens_z - gopro_lens_outer_z_usable, 0]) {
                    square([lens_thread_height, lens_inner_r]);
                }
            }
        }
    }

    rotate([0, 180, -90]) {
        translate([-effective_lens_to_lens_z - lens_thread_height, 0]) {
            offset(-rounding_r) {
                offset(rounding_r) {
                    difference() {
                        outer_shape();
                        inner_shape();
                    }
                }
            }
        }
    }
}


ScrewHole(outer_diam=lens_d,
          height=lens_thread_height,
          rotation=[180,0,0],
          pitch=lens_thread_pitch) {
    rotate_extrude(angle=360) {
        shape_2d();
    }
}
