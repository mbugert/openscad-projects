// ----------------------------------------------------------------------------
// MEASUREMENTS

// Tidafors feet are shaped like a frustum
foot_edge_floor = 121.4;
foot_edge_couch = 130;
foot_z = 80;

// the feet have a hole (which we don't make use of so far)
foot_hole_z = 30;
foot_hole_d = 15;
module hole_position() {
    translate([foot_edge_couch, foot_edge_couch] / 2 - [40, 40]) {
        children();
    }
}

wood_plug_z = 10.7;
wood_plug_d = 8;
module wood_plug_position() {
    translate([foot_edge_couch, foot_edge_couch] / -2 + [40, 40]) {
        children();
    }
}

// ----------------------------------------------------------------------------
// PARAMETERS

// millimeters extra to raise the couch
extension_z = 30;


// ----------------------------------------------------------------------------
// PARTS

module foot(with_hole=false) {
    difference() {
        linear_extrude(height = foot_z, scale=foot_edge_couch / foot_edge_floor) {
            square(size = [foot_edge_floor, foot_edge_floor], center=true);
        }
        if (with_hole) {
            translate([0, 0, -dif]) {
                linear_extrude(height = foot_hole_z + dif) {
                    hole_position() {
                        circle(d=foot_hole_d);
                    }
                }
            }
        }
    }
}

//foot();
