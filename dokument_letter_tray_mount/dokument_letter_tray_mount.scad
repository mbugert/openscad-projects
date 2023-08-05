include <../shared/common.scad>
use <external/2dfillet.scad>

// measurements from Ikea DOKUMENT
bar_r = 5;
between_crossbars_y = 98;

// object settings
$fn=100;
$fillet_fn=24;

tube_y = between_crossbars_y;
tube_t = 3.5;                       // tube thickness of base
tube_tol_r = 0.4;                   // add some air on the inside of the tube
tube_tol_z = 1.2;                   // additional tube height to ensure that the screw seatings are flush with the table
tube_inner_r = bar_r+tube_tol_r;
tube_outer_r = tube_inner_r+tube_t;

// screw positions
screw_inner_offset_x = 30;          // some offset so it's easier to screw in because of the rails
screw_outer_offset_x = 15;
screw_outer_offset_y = 0.35*tube_y; // screws on the outside are positioned on the y axis by some offset from the center

// screw (hole) dimensions - currently for M3.5
screw_grooving_diameter = 4;
screw_head_r = 3.5;
screw_head_depth = 3;

screw_depth = 10;                   // something high, doesn't matter
screw_seating_clearance = 0.5;      // some air between screw and seating
screw_seating_t = 2;                // screw seating wall thickness
screw_seating_r = screw_head_r + screw_seating_clearance + screw_seating_t;

fillet_r = 6;
fillet_base_y = 4*screw_seating_r;


module halftube() {
    out_r = tube_outer_r;
    in_r = tube_inner_r;

    rotate([-90,0,0])
        linear_extrude(height=tube_y)
            translate([0,-(in_r+tube_tol_z)])
                difference() {
                    // outer
                    union() {
                        intersection() {
                            circle(r=out_r);
                            translate(out_r*[-1,-1])
                                square(out_r*[2,1]);
                        }
                        translate([-out_r,0])
                            square([2*out_r, in_r+tube_tol_z]);
                    }
                    // inner
                    circle(r=in_r);
                    translate([-in_r,0])
                        square([2*in_r, out_r+tube_tol_z+dif]);
                }
}

module screw(grooving_diameter, screw_depth, head_diameter, head_depth) {
    translate([0,0,-head_depth]) {
        cylinder(r=head_diameter/2, h=head_depth);
        translate([0,0,-screw_depth])
            cylinder(r=grooving_diameter/2, h=screw_depth+dif);
    }
}

module screw_seatings() {
    module screw_seating(seating_offset_x=0) {       
        dummy = 1;
        translate([-(seating_offset_x+screw_seating_r),0])
            fillet_display(fillet_r, fn_fillet=$fillet_fn) {
                // bridge towards the screw seating
                translate([0,-screw_seating_r])
                    square([seating_offset_x+screw_seating_r, 2*screw_seating_r]);
                
                // fillet base (so that the filletting touches the half tube nicely)
                translate([-dummy, -fillet_base_y/2])
                    square([dummy, fillet_base_y]);
            }
        // screw seating itself
        circle(screw_seating_r);
    }
      
    linear_extrude(height=tube_inner_r) {
        screw_positions_outer() {
            screw_seating(seating_offset_x=screw_outer_offset_x);
        }
        screw_positions_inner() {
            rotate([0,0,180])
                screw_seating(seating_offset_x=screw_inner_offset_x);
        }
    }
}

module screw_holes() {
    module screw_hole() {
        translate([0,0,tube_inner_r+dif])
            screw(screw_grooving_diameter, screw_depth+2*dif, 2*screw_head_r+2*screw_seating_clearance, screw_head_depth+dif);
    }
    
    screw_positions_outer() {
        screw_hole();
    }
    screw_positions_inner() {
        screw_hole();
    }
}

module screw_positions_outer() {
    screw_ys = [-screw_outer_offset_y, screw_outer_offset_y];
    screw_x = tube_outer_r + screw_seating_r + screw_outer_offset_x;
    
    for(i = [0:1:1]) {
        translate([screw_x, screw_ys[i] + tube_y/2, 0])
            children();
    }
}

module screw_positions_inner() {
    screw_x = tube_outer_r + screw_seating_r + screw_inner_offset_x;
    translate([-screw_x, tube_y/2, 0])
        children();
}

module mount() {
    difference() {
        union() {
            halftube();
            screw_seatings();
        }
        screw_holes();
    }
}

mount();
