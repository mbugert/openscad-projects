include <../shared/common.scad>
use <../shared/external/threads.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Measurements] */

step_y = 40;
z = 62;
step_z = 15;


// ----------------------------------------------------------------------------
// PARAMETERS

/* [Parameters] */

part = "assembly";  // ["cap", "container", "assembly"]

thread_d = 30;
thread_male_z = 7;
thread_female_z = 5;
wall_t = 2;

// the percentage of the total x-length that should become the cap
cap_x_percent = 0.1;


// ----------------------------------------------------------------------------
// DERIVED PARAMETERS

module __Customizer_Limit__ () {}

// golden ratio
x = 1.618033988 * z;
echo("Golden ratio x length: ", x);

cap_x = cap_x_percent * x;
container_x = (1 - cap_x_percent) * x - clearance_medium;


// ----------------------------------------------------------------------------
// PARTS

module base_shape_2d() {
    difference() {
        square([z, z]);
        square([step_z + clearance_loose, step_y + clearance_loose]);
    }
}

module thread_pos() {
    translate([(z - step_z)/2 + step_z, -z / 2]) {
        children();
    }
}
module thread_pos_inv() {
    translate([- (z - step_z)/2 - step_z, z / 2]) {
        children();
    }
}

module container(in_print_position=false) {
    module hollow_container() {
        difference() {
            linear_extrude(container_x) {
                base_shape_2d();
            }

            translate([0, 0, wall_t]) {
                linear_extrude(container_x - wall_t - thread_female_z) {
                    offset(-wall_t) {
                        base_shape_2d();
                    }
                }
            }
        }
    }

    module part() {
        thread_pos() {
            ScrewHole(thread_d, thread_male_z, [0, 0, container_x], [180, 0, 0], ThreadPitch(thread_d), $fn=10) {
                thread_pos_inv() {
                    mirror([0, 1, 0]) {
                        hollow_container();
                    }
                }
            }
        }
    }

    rotate([0, in_print_position? 180 : 0, 0]) {
        part();
    }
}

module cap(in_print_position=false) {
    module part() {
        translate([0, 0, -cap_x]) {
            linear_extrude(cap_x) {
                base_shape_2d();
            }
        }

        translate([0, z, 0]) {
            thread_pos() {
                ScrewThread(thread_d,
                            thread_male_z,
                            ThreadPitch(thread_d),
                            tip_height=ThreadPitch(thread_d),
                            tip_min_fract=0.75);
            }
        }
    }

    rotate([in_print_position? 0 : 180, 0, 0]) {
        part();
    }
}


module assy() {
    color(alpha=0.7)
    translate([0, 0, container_x]) {
        cap();
    }

    color("purple", alpha=0.7)
    container();
}

if (part == "cap") {
    cap(in_print_position=true);
} else if (part == "container") {
    container(in_print_position=true);
} else if (part == "assembly") {
    assy();
}
