include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

// capture card dimensions
cc_x = 56.8;
cc_z = 18.3;    // incl. rubber feet to some extent

// pole diameter of monitor stand
pole_d = 55;

// ----------------------------------------------------------------------------
// PARAMETERS

// capture card holder parameters
cc_clamp_t = 2;
cc_clamp_ends_z = 0.3 * cc_z;

// "clamp" or "ring"
pole_mount_type = "ring";
pole_clamp_t = 3;
pole_clamp_opening_degrees = 80;

// optional rings for feeding cables through
add_cable_rings = true;
cable_rings_t = 2;
cable_rings_d = 28;

closing_r = 4;

// extrusion height -- decided by the amount of space between USB and HDMI-In on the AverMedia capture card
mount_height = 14;

// ----------------------------------------------------------------------------
// PARTS

cc_ring_inner_x = cc_x + 2*clearance_medium;
cc_ring_inner_z = cc_z + 2*clearance_medium;

module cc_ring_position() {
    translate([-cc_ring_inner_x / 2, cc_clamp_t]) {
        children();
    }
}

module cc_ring_inner() {
    square([cc_ring_inner_x, cc_ring_inner_z]);
}

module cc_ring_outer() {
    minkowski() {
        cc_ring_inner();
        square(2 * cc_clamp_t, center=true);
    }
}

module pole_ring_position() {
    translate([0, -(pole_d + pole_clamp_t + 1.5 * clearance_fit) / 2]) {
        children();
    }
}

module pole_ring_inner() {
    circle(d=pole_d + 1.5 * clearance_fit);

    if (pole_mount_type == "clamp") {
        rotate([0, 0, -90 - pole_clamp_opening_degrees/2]) {
            circle_section(r=pole_d, deg=pole_clamp_opening_degrees);
        }
    }
}

module pole_ring_outer() {
    circle(d=pole_d + 2 * pole_clamp_t + 1.5 * clearance_fit);
}


module cable_rings_position() {
    for (i = [1, -1]) {
        translate([i * (cc_x/2 + (0.5 * cable_rings_d)/2), 0]) {
            children();
        }
    }
}

module cable_rings_inner() {
    circle(d=cable_rings_d);
}

module cable_rings_outer() {
    circle(d=cable_rings_d + 2*cable_rings_t);
}

module mount_2d() {
    round_chamfer(r=0.4 * min(cc_clamp_t, pole_clamp_t), keep_size=true) {
        difference() {
            closing(closing_r) {
                cc_ring_position()
                    cc_ring_outer();
                pole_ring_position()
                    pole_ring_outer();

                if (add_cable_rings) {
                    cable_rings_position()
                        difference() {
                            cable_rings_outer();
                            cable_rings_inner();
                        }
                }
            }
            cc_ring_position()
                cc_ring_inner();
            pole_ring_position()
                pole_ring_inner();
        }
    }
}

module mount_3d() {
    linear_extrude(mount_height) {
        mount_2d();
    }
}

mount_3d();
