// Snap-fit jigsaw mechanism for joining parts that can be printed vertically without supports.

include <common.scad>

bf_joiner_wall = 0.8;
bf_joiner_hollow_round_r = 0.5;

// dimensions for noses that keep the joiner in place on z-axis
bf_nose_y = 0.5;
bf_nose_x = 3;
bf_nose_z = 1.4;

// Produces the shape for the joiner if type == "joiner", the shape for the
// socket that can be printed standing up without supports if type == "socket".
module butterfly_base_2d(bf_y, bf_center_x, bf_center_y, bf_z, type="joiner") {
    module half() {
        square([bf_center_x, bf_center_y], center=true);

        // x overlap between centerpiece and triangle tip
        overlap_x = tan(printer_max_overhang_degrees) * bf_center_y / 2;
        // x length of entire triangle
        triangle_x = tan(printer_max_overhang_degrees) * bf_y / 2;

        translate([overlap_x - bf_center_x / 2, 0]) {
            polygon([[0, 0], [-triangle_x, bf_y/2], [-triangle_x, -bf_y/2]]);

            // to permit printing of the socket without supports, the socket
            // shape is fanned in / fanned out taking overhang degrees into
            // account
            if (type == "socket") {
                translate([-triangle_x, 0]) {
                    polygon([[0, bf_y/2], [0, -bf_y/2], [-triangle_x, 0]]);
                }
            }
        }
    }

    closing(r=0.5) {
        mirror_copy([1, 0, 0]) {
            half();
        }
    }
}

module butterfly_socket(bf_y, bf_center_x, bf_center_y, bf_z, printable_without_supports=true) {
    module nose() {
        // quarter ellipse shape
        intersection() {
            translate([bf_nose_x/2, 0, 0]) {
                resize([bf_nose_x, bf_nose_y*2, bf_nose_z*2]) {
                    sphere(1, $fn=24);
                }
            }
            cube([bf_nose_x, bf_nose_y, bf_nose_z]);
        }
    }

    difference() {
        linear_extrude(bf_z + dif) {
            offset(r=clearance_medium) {
                base_type = printable_without_supports? "socket" : "joiner";
                butterfly_base_2d(bf_y, bf_center_x, bf_center_y, bf_z, type=base_type);
            }
        }

        mirror_copy([1, 0, 0]) {
            mirror_copy([0, 1, 0]) {
                translate([bf_center_x/4 - bf_nose_x/2, -bf_center_y/2 - clearance_medium, bf_z - bf_nose_z]) {
                    nose();
                }
            }
        }
    }
}

module butterfly_joiner(bf_y, bf_center_x, bf_center_y, bf_z) {
    difference() {
        // if the socket is printed standing up, the joiner needs extra
        // clearance to fit into the socket
        linear_extrude(bf_z - bf_nose_z - clearance_medium) {
            offset(clearance_fit) {
                opening(2*bf_joiner_hollow_round_r) {
                    butterfly_base_2d(bf_y, bf_center_x, bf_center_y, bf_z);
                }
            }
        }

        translate([0, 0, bf_joiner_wall + bf_joiner_hollow_round_r]) {
            minkowski() {
                sphere(r=bf_joiner_hollow_round_r, $fn=12);
                linear_extrude(bf_z - bf_joiner_wall - bf_joiner_hollow_round_r) {
                    offset(r=-bf_joiner_wall - bf_joiner_hollow_round_r) {
                        butterfly_base_2d(bf_y, bf_center_x, bf_center_y, bf_z);
                    }
                }
            }
        }
    }
}
