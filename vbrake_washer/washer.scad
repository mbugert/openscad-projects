include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

d_outer = 12;
d_inner = 6.1;
z = 4.8;

// deepest point of the subtracted sphere, measured at the inner diameter
sphere_inner_z_offset = 1.5;


// ----------------------------------------------------------------------------
// PARAMETERS

sphere_r = d_outer;


// ----------------------------------------------------------------------------
// PARTS

module washer() {
    render() {
        difference() {
            linear_extrude(z) {
                difference() {
                    circle(d=d_outer);
                    circle(d=d_inner);
                }
            }
            translate([0, 0, z + sphere_r - sphere_inner_z_offset]) {
                sphere(r=sphere_r);
            }
        }
    }
}

washer();
