// Press-fit mechanism for joining two parts printed in orthogonal directions
// without supports. This join mechanism only restricts lateral movement in one
// direction. The part with cavities requires a wall in the other lateral
// direction to stay in place.

include <../shared/common.scad>

$fn=30;

// t: minimum parts thickness
// depth: how deep the hook reaches out
module slide_joint_hook_2d(t=2, depth=4) {
    module basic_shape() {
        hull() {
            translate([depth - t/2, -t/2]) {
                circle(d=t);
            }
            translate([depth - t, 0]) {
                square([t, min_value]);
            }
        }
        y = sin(printer_max_overhang_degrees) * depth;
        polygon([[0, 0], [depth, 0], [0, y]]);
    }

    module helper_square() {
        a = max_value * depth;
        translate([-a, -a/2]) {
            square(a);
        }
    }
    render() {
        difference() {
            closing(r=t/2) {
                basic_shape();
                helper_square();
            }
            helper_square();
        }
    }
}

slide_joint_hook_2d();
