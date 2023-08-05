include <../shared/common.scad>

$fn = 50;

// looks like a 5mm, but is more 5.1
hook_hole_d = 5.1;
hook_wall = 2;

pin_base_thickness = 1.2;
pin_base_x = 2 * hook_hole_d;
pin_d = hook_hole_d - 2*clearance_fit;
pin_z = 1.5 * hook_wall + pin_d / 2;

// pin section
union() {
    translate([0, 0, pin_z - pin_d / 2])
        sphere(d = pin_d);

    cylinder(h=pin_z - pin_d / 2, d = pin_d);
}

// base section
translate([0, 0, -pin_base_thickness])
    linear_extrude(height=pin_base_thickness)
        hull() {
            translate([-pin_d / 2, 0])
                circle(d=pin_d);
            translate([+pin_d / 2, 0])
                circle(d=pin_d);
        }
