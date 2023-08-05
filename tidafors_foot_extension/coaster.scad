include <../shared/common.scad>
include <common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// PARAMETERS

coaster_wall = 6;
coaster_inner_r = 2;
coaster_cup_z = 25;
coaster_r = 2;
coaster_cutout_d = 0.5 * foot_edge_floor;
coaster_cutout2_d = 0.9 * foot_edge_floor;
clearance = 0.2;

if (extension_z <= wood_plug_z) {
    echo("extension_z must be larger than wood_plug_z, otherwise assembly won't work.");
}

// ----------------------------------------------------------------------------
// PARTS

module coaster() {
    module base_shape() {
        translate([0, 0, -extension_z]) {
            linear_extrude(height = coaster_cup_z + extension_z) {
                difference() {
                    minkowski() {
                        circle(r=coaster_wall);
                        square(size = [foot_edge_floor, foot_edge_floor], center=true);
                    }
                    circle(d = coaster_cutout_d);
                }
            }
        }
    }

    // scale down a foot, dilate with sphere, then subtract from base shape
    // to create a cutout with inner radius 
    difference() {
        base_shape();
        minkowski() {
            sphere(r = coaster_inner_r);
            translate([0,0,coaster_inner_r])
                resize([foot_edge_couch - 2 * coaster_inner_r + 2 * clearance, 0, 0], auto=[true, true, false]) {
                    foot();
                }
        }

        // add cylindrical cutouts to save filament
        translate([0,0,coaster_cutout2_d / 2]) {
            rotate([0, 90, 0]) {
                for(rot = [0, 90]) {
                    rotate([rot, 0, 0]) {
                        cylinder(d=coaster_cutout2_d, h=foot_edge_floor + 2*(coaster_wall + dif), center=true);
                    }
                }
            }
        }
    }
}

coaster();
