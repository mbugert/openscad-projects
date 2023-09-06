include <../shared/common.scad>
include <../shared/screws.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

// ------------------------------------
// PRE-DRILLED HOLES
drilled_hole_dist_x = 151;
drilled_hole_dist_y = 47;

// distance of top left drilled hole to the upper edge of the mirror below it
drilled_hole_top_row_y_dist_mirror = 162.5;

// large drilled hole where the cables are coming out
center_hole_d = 35;
center_hole_offset_x = 54 + center_hole_d / 2;
center_hole_offset_y = -1.25;

// ------------------------------------
// METAL HOLDER ("mh") THE LAMP SHIPPED WITH

mh_top_hole_dist_x = 60;

// 4.5mm are the medium fit clearance hole for M4, so it was probably intended
// to hang the lamp with M4 screws
mh_hole_d = 4.5;

// y distance from top row of holes to top edge of metal holder:
// - half the hole (because that's how we measured it)
// - plus 15mm from the top of the hole to the top edge of the wall-facing metal
// - plus 10mm y distance for the angled part bent away from the wall
mh_top_hole_to_top_mh_edge_dist_y = mh_hole_d / 2 + 15 + 10;

mh_bottom_hole_dist_x = 54;
mh_bottom_hole_d = 5.7;
mh_bottom_hole_z = 4.8;

// y distance between top row of holes to pins
mh_top_hole_pin_dist_y = 73;

// y length including the outward bent top and bottom parts in the z direction
mh_y = 205;

// countersunk area around screws
mh_countersunk_d1 = 6.5;
mh_countersunk_d2 = 16.5;
mh_countersunk_z = 4.5;

// thickness of metal holder
mh_metal_t = 0.9;


// ----------------------------------------------------------------------------
// PARAMETERS

// final observable distance between lamp and the mirror already mounted below
lamp_mirror_dist_y = 12;

// mm perimeter around holes for stability
drilled_hole_perimeter = 2.5;
center_hole_perimeter = 4;

// we are going to use M4, so 4mm for medium fit clearance hole
mh_screw_d = 4;
mh_hole_perimeter = 3.5;

truss_d = 2.5;
closing_r = 2.5;

// thickness (M4 hex nut is 3.2 thick)
t = 4.5;

screw_m = "M4";
screw_l = 10;

// ----------------------------------------------------------------------------
// PARTS

module drilled_hole_top_left_position() {
    translate([-drilled_hole_dist_x / 2, 0]) {
        children();
    }
}

module drilled_hole_top_right_position() {
    translate([drilled_hole_dist_x / 2, 0]) {
        children();
    }
}

module drilled_hole_bottom_right_position() {
    translate([drilled_hole_dist_x / 2, -drilled_hole_dist_y]) {
        children();
    }
}

module drilled_hole_bottom_left_position() {
    translate([-drilled_hole_dist_x / 2, -drilled_hole_dist_y]) {
        children();
    }
}

module drilled_hole_positions() {
    drilled_hole_top_left_position() {
        children();
    }
    drilled_hole_top_right_position() {
        children();
    }
    drilled_hole_bottom_right_position() {
        children();
    }
    drilled_hole_bottom_left_position() {
        children();
    }
}

module mh_hole_top_left_position() {
    // origin is in center between the two top screws
    translate([-mh_top_hole_dist_x / 2, 0]) {
        children();
    }
}

module mh_hole_top_right_position() {
    translate([mh_top_hole_dist_x / 2, 0]) {
        children();
    }
}

module mh_hole_bottom_left_position() {
    translate([-mh_bottom_hole_dist_x / 2, -mh_top_hole_pin_dist_y]) {
        children();
    }
}

module mh_hole_bottom_right_position() {
    translate([mh_bottom_hole_dist_x / 2, -mh_top_hole_pin_dist_y]) {
        children();
    }
}

module mh_hole_positions() {
    mh_hole_top_left_position() {
        children();
    }
    mh_hole_top_right_position() {
        children();
    }
    mh_hole_bottom_left_position() {
        children();
    }
    mh_hole_bottom_right_position() {
        children();
    }
}

module center_hole_position() {
    translate([-drilled_hole_dist_x / 2 + center_hole_offset_x, center_hole_offset_y]) {
        children();
    }
}

// position of the lamp metal relative to the position of the printed adapter
module mh_position() {
    y_offset = -drilled_hole_top_row_y_dist_mirror + lamp_mirror_dist_y + mh_y - mh_top_hole_to_top_mh_edge_dist_y;
    translate([0, y_offset]) {
        children();
    }
}

module trusses() {
    module truss_helper() {
        circle(truss_d);
    }

    // left side
    hull() {
        drilled_hole_top_left_position() {
            truss_helper();
        }
        drilled_hole_bottom_left_position() {
            truss_helper();
        }
    }
    hull() {
        drilled_hole_bottom_left_position() {
            truss_helper();
        }
        mh_position() {
            mh_hole_top_left_position() {
                truss_helper();
            }
        }
    }
    hull() {
        drilled_hole_top_left_position() {
            truss_helper();
        }
        mh_position() {
            mh_hole_bottom_left_position() {
                truss_helper();
            }
        }
    }
    hull() {
        drilled_hole_bottom_left_position() {
            truss_helper();
        }
        mh_position() {
            mh_hole_bottom_left_position() {
                truss_helper();
            }
        }
    }
    hull() {
        drilled_hole_top_left_position() {
            truss_helper();
        }
        mh_position() {
            mh_hole_top_left_position() {
                truss_helper();
            }
        }
    }
    hull() {
        mh_position() {
            mh_hole_top_left_position() {
                truss_helper();
            }
        }
        mh_position() {
            mh_hole_bottom_left_position() {
                truss_helper();
            }
        }
    }

    // center
    hull() {
        mh_position() {
            mh_hole_top_left_position() {
                truss_helper();
            }
        }
        mh_position() {
            mh_hole_top_right_position() {
                truss_helper();
            }
        }
    }
    hull() {
        mh_position() {
            mh_hole_top_left_position() {
                truss_helper();
            }
        }
        mh_position() {
            mh_hole_bottom_right_position() {
                truss_helper();
            }
        }
    }
    hull() {
        mh_position() {
            mh_hole_bottom_left_position() {
                truss_helper();
            }
        }
        mh_position() {
            mh_hole_bottom_right_position() {
                truss_helper();
            }
        }
    }
    hull() {
        mh_position() {
            mh_hole_bottom_left_position() {
                truss_helper();
            }
        }
        mh_position() {
            mh_hole_top_right_position() {
                truss_helper();
            }
        }
    }

    // right side
    hull() {
        drilled_hole_top_right_position() {
            truss_helper();
        }
        drilled_hole_bottom_right_position() {
            truss_helper();
        }
    }
    hull() {
        drilled_hole_bottom_right_position() {
            truss_helper();
        }
        mh_position() {
            mh_hole_top_right_position() {
                truss_helper();
            }
        }
    }
    hull() {
        drilled_hole_top_right_position() {
            truss_helper();
        }
        mh_position() {
            mh_hole_bottom_right_position() {
                truss_helper();
            }
        }
    }
    hull() {
        drilled_hole_bottom_right_position() {
            truss_helper();
        }
        mh_position() {
            mh_hole_bottom_right_position() {
                truss_helper();
            }
        }
    }
    hull() {
        drilled_hole_top_right_position() {
            truss_helper();
        }
        mh_position() {
            mh_hole_top_right_position() {
                truss_helper();
            }
        }
    }
    hull() {
        mh_position() {
            mh_hole_top_right_position() {
                truss_helper();
            }
        }
        mh_position() {
            mh_hole_bottom_right_position() {
                truss_helper();
            }
        }
    }
}

module base_shape() {
    closing(closing_r) {
        center_hole_position() {
            offset(center_hole_perimeter) {
                circle(d=center_hole_d);
            }
        }
        // hole and pin positions for the lamp metal piece
        mh_position() {
            mh_hole_positions() {
                offset(mh_hole_perimeter) {
                    axle_2d(screw_m);
                }
            }
        }
        // template for drilled holes in wall
        drilled_hole_positions() {
            offset(drilled_hole_perimeter) {
                axle_2d(screw_m);
            }
        }
        // connections between mounting points for stability
        trusses();
    }
}

module adapter_2d() {
    difference() {
        base_shape();
        drilled_hole_positions() {
            axle_2d(screw_m, clearance=clearance_medium);
        }
        center_hole_position() {
            circle(d=center_hole_d);
        }
    }
}

module assembly() {
    module raised() {
        mh_position() {
            linear_extrude(height=mh_bottom_hole_z + t) {
                offset(mh_hole_perimeter) {
                    axle_2d(screw_m);
                }
            }
        }
    }

    difference() {
        union() {
            linear_extrude(height=t) {
                adapter_2d();
            }

            // raise area around bottom holes
            mh_hole_bottom_left_position() {
                raised();
            }
            mh_hole_bottom_right_position() {
                raised();
            }
        }

        // countersunk holes
        translate([0, 0, t - din7997_head_z(screw_m)]) {
            drilled_hole_positions() {
                din7997(screw_m, 10, clearance=clearance_medium);
            }
        }

        // hex nut holes
        mh_position() {
            mh_hole_positions() {
                iso4032(screw_m, clearance=clearance_medium);

                linear_extrude(height=mh_bottom_hole_z + t + dif) {
                    axle_2d(screw_m, clearance=2*clearance_medium);
                }
            }
        }
    }
}

module cone_washer() {
    washer_z = screw_l - mh_metal_t - t;
    cylinder_section_z = washer_z - mh_countersunk_z;
    difference() {
        union() {
            cylinder(d1=mh_countersunk_d1, d2=mh_countersunk_d2, h=mh_countersunk_z);
            if (cylinder_section_z > 0) {
                translate([0, 0, mh_countersunk_z]) {
                    cylinder(d=mh_countersunk_d2, h=cylinder_section_z);
                }
            }
        }
        translate([0, 0, screw_l - mh_metal_t - t]) {
            din912(screw_m, l=screw_l, clearance=clearance_medium);
        }
    }
}
