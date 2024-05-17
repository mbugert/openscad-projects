// Two-part ball joint mechanism (head and socket).

include <../shared/common.scad>

module ball_head(ball_d, rod_d, rod_l) {
    sphere(d=ball_d);
    cylinder(d=rod_d, h=rod_l + ball_d/2);
    // cone for added robustness
    cylinder(d1=ball_d, d2=rod_d, h=ball_d/2);

    // position children at the tip of the rod
    translate([0, 0, rod_l + ball_d/2]) {
        children();
    }
}

// socket shape that is meant to be subtracted from other shapes
module ball_socket(ball_d, rod_d, rod_l, opening_angle=90, clearance=clearance_medium) {
    cone_d2 = 2 * rod_l * sin(opening_angle/2);
    cone_h = rod_l * cos(opening_angle/2);
    minkowski() {
        cylinder(d1=0, d2=cone_d2, h=cone_h);
        sphere(r=rod_d/2 + clearance, $fn=12);
    }
    sphere(d=ball_d + 2 * clearance);

    // cone for added robustness
    rotate_extrude() {
        intersection() {
            hull() {
                offset(r=clearance) {
                    rotate([0, 0, -opening_angle/2]) {
                        polygon([[0, 0], [ball_d/2, 0], [rod_d/2, ball_d/2], [0, ball_d/2]]);
                    }
                }
                square([min_value, rod_l]);
            }
            // restrict to 2D content in +x quadrant, to make rotate_extrude
            // work for clearance>0
            translate([0, -max_value/2]) {
                square(max_value);
            }
        }
    }
}

// Test object for dialling in socket tolerances.
module __ball_joint_socket_test_object(ball_d, rod_d, rod_l, opening_angle=90, clearance=clearance_medium) {
    // cube-shaped overall, with this edge length
    object_x = ball_d * 1.25;
    object_y = ball_d * 2.5;
    object_z = ball_d * 2;
    round_r = ball_d / 5;
    text_depth = 0.4;

    module label() {
        linear_extrude(height=text_depth+dif) {
            text(str(clearance), size=7, halign="center", valign="center");
        }
    }

    module whole() {
        difference() {
            translate([0, 0, -object_z/2]) {
                linear_extrude(object_z) {
                    translate([round_r, round_r]) {
                        offset(r=round_r) {
                            square([object_x, object_y] - 2*[round_r, round_r]);
                        }
                    }
                }
            }

            translate([ball_d/2, object_y/2, 0]) {
                rotate([0, -90, 0]) {
                    ball_socket(ball_d=ball_d,
                                rod_d=rod_d,
                                rod_l=rod_l,
                                opening_angle=opening_angle,
                                clearance=clearance);
                }
            }
        }
    }

    module half() {
        alignment_pin_r = ball_d/5;
        alignment_pin_z = object_z/8;

        difference() {
            intersection() {
                whole();
                cube([object_x, object_y, object_z/2]);
            }
            // alignment cavity
            translate([0.7 * object_x, 0.15*object_y, -dif]) {
                cylinder(r=alignment_pin_r + clearance_medium, h=alignment_pin_z + dif);
            }

            // labels with the clearance chosen
            translate([object_x/2, object_y/2, object_z/2 - text_depth]) {
                rotate([0, 0, 90]) {
                    label();
                }
            }
            translate([object_x - text_depth, object_y/2, object_z/4]) {
                rotate([90, 0, 90]) {
                    label();
                }
            }
        }
        // alignment pin
        translate([0.7 * object_x, 0.85*object_y, -alignment_pin_z]) {
            cylinder(r=alignment_pin_r, h=alignment_pin_z);
        }
    }

    translate([0, 0, object_z/2]) {
        rotate([0, 180, 0]) {
            half();
        }
    }
}

__ball_joint_socket_test_object(
    ball_d=10.2,
    rod_d=4.75,
    rod_l=2*4.75,
    opening_angle=75,
    clearance=0.1
);
