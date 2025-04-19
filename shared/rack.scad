// Rack mount dimensions
// see https://commons.wikimedia.org/wiki/File:19_inch_vs_10_inch_correct_rack_dimensions.svg

include <common.scad>

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Measurements] */

// widths
rack_10inch_outer_x = round_decimals(10 * inch, 3);
rack_10inch_inner_x = round_decimals(8.75 * inch, 3);
rack_10inch_bolt_dist_x = round_decimals(9.312 * inch, 3);

rack_19inch_outer_x = round_decimals(19 * inch, 3);
rack_19inch_inner_x = round_decimals(17.75 * inch, 3);
rack_19inch_bolt_dist_x = round_decimals(18.312 * inch, 3);

rack_ear_x = round_decimals(0.625 * inch, 3);

// heights
rack_1u_z = round_decimals(1.752 * inch, 3);
rack_ear_hole_dist_z = round_decimals(0.625 * inch, 3);
rack_ear_hole_offset_z = round_decimals(0.25 * inch, 3);

// bolts -- #12-24
rack_bolt_d = round_decimals(0.216 * inch, 3);

// ----------------------------------------------------------------------------
// PARTS

// height of 1U, 2U, ... device
function rack_u_z(u=1) = rack_1u_z * u;

// center non-centered rack ear on center hole
module rack_ear_center(factor=-1) {
    translate(factor * [rack_ear_x/2, rack_1u_z/2]) {
        children();
    }
}
// de-center rack ear that's centered on center hole
module rack_ear_decenter() {
    rack_ear_center(factor=1) {
        children();
    }
}

module rack_bolt_positions(holes=[0, 1, 2], center=false) {
    module positions() {
        for (h = holes) {
            translate([rack_ear_x/2, rack_ear_hole_offset_z + h * rack_ear_hole_dist_z]) {
                children();
            }
        }
    }
    rack_ear_center(factor=center? -1 : 0) {
        positions() {
            children();
        }
    }
}

// without holes, these probably always require customization
module rack_ear_2d(center=false) {
    rack_ear_center(factor=center? -1 : 0) {
        square([rack_ear_x, rack_1u_z]);
    }
}

module rack_dummy_device(rack_width_inches=19, u=1, device_y=200, ear_y=2) {
    module ear() {
        linear_extrude(ear_y) {
            difference() {
                rack_ear_2d();
                rack_bolt_positions(holes=[0, 2]) {
                    circle(d=rack_bolt_d);
                }
            }
        }
    }

    module long_ear() {
        for (iu = [0:1:u-1]) {
            translate([0, rack_1u_z * iu, 0]) {
                ear();
            }
        }
    }

    module device() {
        device_x = rack_width_inches == 10? rack_10inch_inner_x : rack_19inch_inner_x;
        translate([0, 0, -ear_y]) {
            long_ear();
            translate([rack_ear_x, 0, 0]) {
                cube([device_x, rack_u_z(u), device_y]);
                translate([device_x, 0, 0]) {
                    long_ear();
                }
            }
        }
    }

    rotate([90, 0, 0]) {
        mirror([0, 0, 1]) {
            device();
        }
    }
}
