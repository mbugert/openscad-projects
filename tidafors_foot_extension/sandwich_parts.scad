use <../shared/external/threads.scad>
include <../shared/common.scad>
include <../shared/screws.scad>
include <common.scad>

$fn = 100;


// ----------------------------------------------------------------------------
// PARAMETERS

// For better alignment, we add a rim that surrounds the outside of the wooden
// foot.
rim_t = 1.5;
rim_z = 1.5;
perimeter_t = 3.5 - rim_t;
// inner_edge is the edge length of the square inside the outer perimeter
inner_edge = foot_edge_couch - 2*perimeter_t;

// parameters for the inner reinforcement structure
screw_perimeter_t = 3.5;
cross_t = 4;
circle_t = 4;
circle_d = 80;
closing_r = 4;
cable_hole_d = extension_z / 2;
cable_hole_x = 14;

// By adding a sandwich structure between couch and wooden foot, the wood plug
// that's glued into the wooden foot is far too short to reach the
// corresponding hole in the couch. We deal with this by adding a hole in our
// sandwich structure (for the original wood plug), plus a thread and a
// threaded wood plug replacement to satisfy the same purpose as the original
// wood plug.
plug_thread_d = 10;
plug_thread_z = extension_z - wood_plug_z - 1;
plug_thread_sinkdiam = 1.75 * wood_plug_d;

// We bought replacement screws that are too long :/
m8_new_screw_len = 110;
m8_original_screw_len = 60;


// ----------------------------------------------------------------------------
// PARTS

module shape2d() {
    // perimeter
    difference() {
        offset(r=rim_t) {
            square(foot_edge_couch * [1, 1], center=true);
        }
        square(inner_edge * [1, 1], center=true);
    }
    // screw perimeters
    offset(screw_perimeter_t) {
        hole_position() {
            axle_2d(screw_m8, clearance=screw_clearance_medium);
        }
        wood_plug_position() {
            screw_hole_2d(wood_plug_d);
        }
    }
    // stabilizing cross
    difference() {
        intersection() {
            square([inner_edge, inner_edge], center=true);
            union() {
                rotate([0, 0, 45]) {
                    a = inner_edge * sqrt(2);
                    square([a, cross_t], center=true);
                    square([cross_t, a], center=true);

                }
                square([inner_edge, cross_t], center=true);
                square([cross_t, inner_edge], center=true);
            }
        }
        circle(d=circle_d + cross_t*2);
    }

    // stabilizing circle
    difference() {
        circle(d=circle_d + circle_t*2);
        circle(d=circle_d);
    }
}

module hole_shape2d() {
    hole_position() {
        axle_2d(screw_m8, clearance=screw_clearance_medium);
    }
    wood_plug_position() {
        screw_hole_2d(wood_plug_d, clearance=clearance_fit);
    }
}

module sandwich_base_shape() {
    difference() {
        linear_extrude(extension_z) {
            difference() {
                closing(r=closing_r)
                    shape2d();
                hole_shape2d();
            }
        }

        // cut countersunk thread into the part, for our wood plug extension
        translate([0, 0, extension_z]) {
            wood_plug_position() {
                rotate([180, 0, 0]) {
                    // remove cone to make the hole countersunk (so we can
                    // print without supports)
                    translate([0, 0, -dif]) {
                        cylinder(d1=wood_plug_d + 2*screw_perimeter_t, d2=0, h=wood_plug_d + dif);
                    }
                    // using the same tweaks as in the ScrewHole module
                    // (1.01 * d + 1.25 * 0.4) was not enough for PETG or PLA,
                    // so we increase the amount of clearance to 0.7
                    // (1.75 * 0.4)
                    ScrewThread(plug_thread_d + 1.75 * clearance_loose, plug_thread_z + dif);
                }
            }
        }
    }

    // rim perimeter -- Object orientation in this module is how the final
    // print will be positioned, i.e. the +z is the couch side, and -z is the
    // floor side. Therefore, the rim has to be moved towards the -z side
    // (towards the original wooden couch foot).
    translate([0, 0, -rim_z]) {
        linear_extrude(rim_z) {
            difference() {
                offset(r=rim_t) {
                    square(foot_edge_couch * [1, 1], center=true);
                }
                square((foot_edge_couch + 2 * clearance_loose) * [1, 1], center=true);
            }
        }
    }
}

// Since we're going to print it in transparent PETG, we might as well cover
// stupid ideas like adding RGB to it in the future, in which case we would
// need a way to run cables inside and through the part. So what we do is
// cut holes in the cross beams.
module cable_holes() {
    module cable_hole() {
        module half_hole() {
            offset = max((cable_hole_x - cable_hole_d)/2, 0);
            translate([offset, 0]) {
                cylinder(d=cable_hole_d, h=cross_t + dif, center=true);
            }
        }
        rotate([90, 0, 0]) {
            hull() {
                half_hole();
                mirror([1, 0, 0]) {
                    half_hole();
                }
            }
        }
    }

    orthogonal_hole_r = (inner_edge + circle_d + circle_t * 2) / 4;
    diagonal_hole_r = (inner_edge * sqrt(2) + circle_d + circle_t * 2) / 4;

    for (i=[0, 90, 180, 270]) {
        rotate([0, 0, i]) {
            translate([orthogonal_hole_r, 0, extension_z/2]) {
                cable_hole();
            }
        }
        rotate([0, 0, i + 45]) {
            translate([diagonal_hole_r, 0, extension_z/2]) {
                cable_hole();
            }
        }
    }
}


module sandwich() {
    // rotate into how it will be printed (with the rim on top)
    translate([0, 0, extension_z]) {
        rotate([180, 0, 0]) {
            difference() {
                sandwich_base_shape();
                cable_holes();
            }
        }
    }
}


// ----------------------------------------------------------------------------
// EXTRA PARTS

module wood_plug_extension() {
    translate([0, 0, plug_thread_z]) {
        // without the extra added diameter, it did fit perfectly into another
        // printed part, but was too thin for the receiving hole in the couch
        cylinder(d=wood_plug_d + clearance_medium, h=wood_plug_z);
    }
    ScrewThread(plug_thread_d, plug_thread_z);
}

// The M8 screws we bought are so long that the screw head is 2cm away from
// the wooden foot, not keeping it in place. So we print a sheath to connect
// screw and wooden foot...
module m8_screw_sheath() {
    screw_excess_length = m8_new_screw_len - extension_z - m8_original_screw_len;
    if (screw_excess_length > 0) {
        linear_extrude(height=screw_excess_length) {
            difference() {
                circle(d=0.9*foot_hole_d);
                axle_2d(screw_m8, clearance=screw_clearance_medium);
            }
        }
    }
}
