include <common.scad>

// Prusa-style hole bridging, for printing downfacing screw holes without
// supports, see https://www.youtube.com/watch?v=W8FbHTcB05w.
// Needs two children:
//   1. 2D outer shape, for example the shape of the screw head
//   2. 2D inner shape, for example the shape of the screw axle
// Shapes can be non-circular (see the example below).
module prusa_hole_bridging(layer_height=0.2) {
    assert($children == 2, "prusa_hole_bridging needs exactly two children");

    module first_bridge_2d() {
        intersection() {
            minkowski() {
                children(1);
                square([min_value, max_value], center=true);
            }
            children(0);
        }
    }
    module second_bridge_2d() {
        intersection() {
            minkowski() {
                children(1);
                square([max_value, min_value], center=true);
            }
            first_bridge_2d() {
                children(0);
                children(1);
            }
        }
    }

    linear_extrude(layer_height) {
        first_bridge_2d() {
            children(0);
            children(1);
        }
    }
    linear_extrude(2 * layer_height) {
        second_bridge_2d() {
            children(0);
            children(1);
        }
    }
}

// example using triangle-shaped screw parts for demonstration
cube_l = 20;
screw_l = 10;
screw_head_d = 14;
screw_axle_d = 5;

difference() {
    %cube(cube_l);
    translate([cube_l/2, cube_l/2, -1]) {
        // this be our screw
        cylinder(d=screw_head_d, $fn=3, h=screw_l);
        rotate([0, 0, 13]) {
            cylinder(d=screw_axle_d, h=cube_l + 2, $fn=3);
        }
        
        // the bridging section
        translate([0, 0, screw_l]) {
            prusa_hole_bridging() {
                circle(d=screw_head_d, $fn=3);
                rotate([0, 0, 13]) {
                    circle(d=screw_axle_d, $fn=3);
                }
            }
        }
    }
}
