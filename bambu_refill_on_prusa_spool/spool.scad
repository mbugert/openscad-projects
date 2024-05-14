include <../shared/common.scad>
include <../shared/screws.scad>
use <../shared/bridging.scad>

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Prusament Spool Dimensions] */
// see also https://blog.prusa3d.com/prusament-spools-reuse-ideas_8875/

// depth of hex holes in flanges
prusa_hex_x = 3.3;
// diameter of hexagons in flanges
prusa_hex_d = 4.1;
// gap between hexagons
prusa_hex_gap = 1.8;

// unused:
// // hub diameter
// prusa_hub_d = 51;
// // x-width of flanges
// prusa_flange_x = 4.5;

/* [Bambulab Spool Dimensions] */
// x-width of Bambulab spool core
bambu_center_x = 60;
// diameter of Bambulab spool core
bambu_center_d = 81.5;

// unused:
// // x-width of Bambulab spool flange
// bambu_flange_x = 3.5;

// ----------------------------------------------------------------------------
// PARAMETERS

/* [Parameters] */

// model detail
$fn = 100;   // [5:5:100]

// target layer height for printing
layer_height = 0.25;     // [0.01:0.01:1]

// Acute angle between print bed and upwards ramp. The smallest angle the printer can handle without supports. Smaller values save filament.
printer_max_overhang_degrees = 40;  // [1:1:90]

// wall thickness of spool core
spool_core_t = 1.2;     // [0.1:0.1:4]

// x-width of thicker section between hex nut and hexagons (improves printability of the area around the hex nut recess)
spool_core_thick_x = 2.4;     // [1:0.1:2]
// width of thick section on yz plane (must be large enough to enclose the hexagons with screw holes)
spool_core_thick_yz = 9;    // [8.5:0.1:10]

// the number of full 360° rotations of the spiral inside the core (purpose: flex reduction)
spool_core_spiral_rotations = 8;  // [0:1:20]
// spiral size
spool_core_spiral_size = 1.5;     // [0.1:0.1:3]
// number of spiral elements (more rotations need more elements)
num_spiral_elements = 2000;     // [100:100:9900]

// screw size
screw_m = "M3";     // ["M3", "M4"]
// ISO 4032 hex nut or DIN 562 square nut
nut_type = "hex";   // ["hex", "square"]
// x-position of the screw (the larger, the closer to the center of the spool)
nut_pos_x = 1.2;    // [1:0.1:5]
// hex nut clearance
nut_clearance = 0.1;   // [0.0:0.01:0.3]

// ----------------------------------------------------------------------------
// DERIVED PARAMETERS

module __Customizer_Limit__ () {}

spool_core_overhang_ramp_x = tan(printer_max_overhang_degrees) * spool_core_thick_yz;

// ----------------------------------------------------------------------------
// PARTS

module mirror_copy_4x() {
    mirror_copy([1, 0, 0]) {
        mirror_copy([0, 1, 0]) {
            children();
        }
    }
}

// recursive hexagon placement utils (similar to the Cartographers tiles)
module next(i=0, r=0) {
    rotate([0, 0, 30 + r * 60]) {
        translate([i * ((prusa_hex_d + prusa_hex_gap/2) * sqrt(3)), 0]) {
            rotate([0, 0, 30 - r * 60])
            children();
        }
    }
}
module hex_next(i=0, r=0) {
    circle($fn=6, r=prusa_hex_d);
    next(i=1, r=r) {
        children();
    }
}

// basic spool core shape
module spool_core_3d() {
    module spool_core_2d() {
        translate([bambu_center_d/2 - spool_core_t, 0]) {
            rotate([0, 0, -90]) {
                square([bambu_center_x/2, spool_core_t]);

                // ramp for stability and supportless printing
                translate([bambu_center_x/2, 0]) {
                    polygon([[0, 0],
                                [0, -spool_core_thick_yz],
                                [-spool_core_thick_x, -spool_core_thick_yz],
                                [-spool_core_thick_x - spool_core_overhang_ramp_x, 0]]);
                }
            }
        }
    }
    rotate_extrude() {
        spool_core_2d();
    }
}

// extruded hexagons that fit in the Prusament spool flanges
module hex_3d() {
    module hex_2d_one_quarter() {
        next(i=3, r=1)
        next(i=2, r=-1)
        hex_next(r=3)
        hex_next(r=2)
        hex_next(r=0)
        hex_next(r=0)
        hex_next(r=-2)
        hex_next(r=0);
    }

    module hex_2d() {
        // intersect with overhang ramp ring
        intersection() {
            mirror_copy_4x() {
                hex_2d_one_quarter();
            }
            difference() {
                circle(d=bambu_center_d);
                circle(d=bambu_center_d - 2*(spool_core_thick_yz + spool_core_t));
            }
        }
    }
    translate([0, 0, -prusa_hex_x]) {
        linear_extrude(prusa_hex_x) {
            hex_2d();
        }
    }
}

// negative for nut and axle, to be removed from spool core shape
module nut_axle_negative() {
    module nut() {
        k = spool_core_overhang_ramp_x + spool_core_thick_x - nut_pos_x;
        if (nut_type == "hex") {
            rotate([0, 0, 30]) {
                iso4032(screw_m, k=k, clearance=nut_clearance, z_clearance=false);
            }
        } else if (nut_type == "square") {
            din562(screw_m, k=k, clearance=nut_clearance, z_clearance=false);
        }
    }
    module axle() {
        axle_2d(screw_m, clearance=clearance_medium);
    }

    translate([0, 0, nut_pos_x]) {
        // regular axle and nut
        axle_len = nut_pos_x + spool_core_thick_x + prusa_hex_x + 2*dif;
        translate([0, 0, dif - axle_len]) {
            linear_extrude(axle_len) {
                axle();
            }
        }
        nut();

        // Prusa-style hole bridging
        rotate([180, 0, 0]) {
            prusa_hole_bridging(layer_height=layer_height) {
                hull() projection() nut();
                axle();
            }
        }
    }
}

// feed the screw through one of the hexagons (times four, with symmetry)
module axle_nut_positions() {
    mirror_copy_4x() {
        next(i=4, r=-1)
        children();
    }
}

// full part
module spool_core() {
    mirror_copy([0, 0, 1]) {
        difference() {
            union() {
                spool_core_3d();
                translate([0, 0, -bambu_center_x/2]) {
                    hex_3d();
                }
            }
            translate([0, 0, -bambu_center_x/2]) {
                axle_nut_positions() {
                    nut_axle_negative();
                }
            }
        }
    }

    // add spiral on the inside to reduce flex
    translate([0, 0, -bambu_center_x/2]) {
        angle = atan(bambu_center_x / (spool_core_spiral_rotations * bambu_center_d * PI));
        for (i = [0:1:num_spiral_elements - 1]) {
            rotate([0, 0, spool_core_spiral_rotations * 360 * i / num_spiral_elements])
            translate([bambu_center_d/2 - spool_core_t, 0, bambu_center_x * i/num_spiral_elements]) {
                rotate([90 + angle, 0, 0]) {
                    cylinder(d=spool_core_spiral_size, h=1, $fn=4, center=true);
                }
            }
        }
    }
}

spool_core();
