include <common.scad>

// ----------------------------------------------------------------------------
// MEASUREMENTS

/* [Measurements] */

skadis_hole_x = 5;
skadis_hole_y = 15;
skadis_hole_fillet = 1;
skadis_hole_dist_x = 20;
skadis_hole_dist_y = 20;
skadis_board_t = 5;
skadis_board_padding = 20;
skadis_board_corner_r = 8;

// ----------------------------------------------------------------------------
// PARTS

// 2D shape of through-hole (ignoring the filleted edge)
module skadis_hole_2d() {
    pill(d=skadis_hole_x,
         l=skadis_hole_y,
         center=true);
}

// 3D shape of through-hole including filleted edge
module skadis_hole_3d($fn=18) {
    hole_outer_x = skadis_hole_x + 2 * skadis_hole_fillet;
    hole_outer_y = skadis_hole_y + 2 * skadis_hole_fillet;

    module half() {
        difference() {
            translate([0, 0, -dif]) {
                linear_extrude(skadis_board_t / 2 + 2 * dif) {
                    pill(d=hole_outer_x,
                         l=hole_outer_y,
                         center=true);
                }
            }
            // slightly complicated fillet
            translate([0, 0, -skadis_hole_fillet]) {
                minkowski() {
                    sphere(r=skadis_hole_fillet);
                    linear_extrude(skadis_board_t/2) {
                        difference() {
                            pill(d=hole_outer_x + dif,
                                 l=hole_outer_y + dif,
                                 center=true);
                            pill(d=hole_outer_x,
                                 l=hole_outer_y,
                                 center=true);
                        }
                    }
                }
            }
        }
    }
    mirror_copy([0, 0, 1]) {
        half();
    }
}

module skadis_hole_positions(cols, rows) {
    for (iy = [0:1:rows - 1]) {
        for (ix = [0:1:cols - 1]) {
            if ((ix + iy) % 2 == 0) {
                translate([ix * skadis_hole_dist_x,
                           iy * skadis_hole_dist_y]) {
                    children();
                }
            }
        }
    }
}

function skadis_board_size(cols, rows) = [(cols - 1) * skadis_hole_dist_x + 2 * skadis_board_padding,
                                          (rows - 1) * skadis_hole_dist_y + 2 * skadis_board_padding];

module skadis_board_position() {
    translate(-skadis_board_padding * [1, 1]) {
        children();
    }
}

module skadis_board_2d(cols, rows) {
    size = skadis_board_size(cols, rows);
    round_chamfer(r=skadis_board_corner_r, keep_size=true) {
        skadis_board_position() {
            square(size);
        }
    }
}

module skadis_board_3d(cols, rows) {
    translate([0, 0, -skadis_board_t/2]) {
        linear_extrude(skadis_board_t) {
            skadis_board_2d(cols, rows);
        }
    }
}

module skadis_board_2d_with_holes(cols, rows) {
    difference() {
        skadis_board_2d(cols, rows);
        skadis_hole_positions(cols, rows) {
            skadis_hole_2d();
        }
    }
}

module skadis_board_3d_with_holes(cols, rows) {
    difference() {
        skadis_board_3d(cols, rows);
        skadis_hole_positions(cols, rows) {
            skadis_hole_3d();
        }
    }
}

skadis_board_3d_with_holes(4, 10);
