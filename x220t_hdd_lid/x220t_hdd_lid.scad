// ########## IMPORTS ##########
include <../shared/common.scad>
include <../shared/screws.scad>

variant = "branded"; // "vanilla" or "branded"

// ###### DIMENSIONS #######

$fn = 100;

// basic dimensions of the whole thing
xlen = 7.7;
ylen = 83.2;
zlen = 10.5;
main_dimensions = [xlen,ylen,zlen];

laptop_base_rounding_radius = 2.5;
laptop_base_inner_rounding_radius = 1.5;
small_rounding_radius = 1;  // radius used to smoothen several less important 90° angles
wall_thickness_x = 1.5;
wall_thickness_z = 1.1;

// screw dimensions
screw_grooving_diameter = 3;
screw_head_diameter = 5.5;
screw_head_depth = 2;
screw_head_clearance = 0.5;
screw_seating_wall_thickness = 1;
screw_xpos_from_outer = 5;
// derived dimension for the diameter of the full screw seating -> should be approx. 7.7
screw_seating_full_diameter = screw_head_diameter + 2*(screw_head_clearance+screw_seating_wall_thickness);
hollow_out_ylen = ylen - screw_seating_full_diameter;
screw_seating_ylen = 8.7;
screw_seating_zlen = 3;
screw_depth = zlen; // something high, doesn't matter

// dimensions for the inset near the display pen compartment
pen_holder_inset_ylen = 7.7;
pen_holder_inset_zlen = zlen - 3;
pen_holder_inset_rounding_radius = 2;

// nub dimensions and positions
nub_top_xlen = 2;
nub_top_ylen = 5;
nub_top_zlen = 1;
nub_top_z_overlap = 1;
nub_top_slope = 1;
nubs_top_ypos = [18.7,52];

nub_front_xlen = 1;
nub_front_ylen = 5;
nub_front_zlen = 1.5;
nub_front_holder_xlen = 4;
nub_front_holder_ylen = 1.25;
nub_front_holder_zlen = 7.5;

nub_side_xlen = 4;
nub_side_ylen = 10;
nub_side_zlen = 1;
nub_side_x_overlap = 2;
nub_side_slope = 1;
nub_side_ypos = 52;

// text settings
text = "X220 Tablet";
writing_font_size = 5.5;
writing_depth = 0.5;
writing_ypos = 5;

// #########################

module sloped_cube(xlen, ylen, zlen, slopelen) {
    difference() {
        hull() {
            cube([xlen, ylen, zlen]);
            translate(slopelen * [0,-1,-1])
                cube([xlen+slopelen, ylen+2*slopelen, slopelen]);
        }
        translate(slopelen * [0,-1,-1] + dif * [-1,-1,-1])
            cube([xlen+slopelen, ylen+2*slopelen, slopelen] + dif*[2,2,1]);
    }
}

module sloped_nub(nub_xlen, nub_ylen, nub_zlen, nub_x_overlap, slope) {
    translate([-nub_x_overlap,0,0])
            cube([nub_xlen, nub_ylen, nub_zlen]);
        sloped_cube(nub_xlen-nub_x_overlap, nub_ylen, nub_zlen, slope);
}

module screw_position() {
    translate([xlen, ylen, 0] - [screw_xpos_from_outer,0.5 * screw_seating_full_diameter,0])
        rotate([0,0,0])
            children();
}

module x220t_hdd_lid(branding) {
    // several less important roundings
    round_out_3d(small_rounding_radius, 3, main_dimensions - [0,pen_holder_inset_ylen,0])
    round_out_3d(small_rounding_radius, 8, main_dimensions)
    round_out_3d(small_rounding_radius, 1, main_dimensions)
    round_out_3d(laptop_base_rounding_radius, 6, main_dimensions)
        difference() {  // L shape with screw seating and screw hole
            union() {   // L shape with screw seating
                difference() {  // L shape without pen inset
                    cube(main_dimensions);

                    // hollow out the screw rounding at the corner
                    translate([0,ylen-0.5*screw_seating_ylen,0] - dif*[1,0,1]) {
                        cube([xlen-(wall_thickness_x+laptop_base_rounding_radius), 0.5*screw_seating_ylen, wall_thickness_z] + dif * [1,1,2]);
                    }

                    // hollow out to get the L-shape
                    translate([-dif,-dif,wall_thickness_z]) {
                        hollow_out_difftemplate_dimensions = main_dimensions - [wall_thickness_x,0,wall_thickness_z] + dif * [1,2,1];
                        round_out_3d(laptop_base_inner_rounding_radius, 6, hollow_out_difftemplate_dimensions)
                            cube(hollow_out_difftemplate_dimensions);
                    }

                    // pen holder inset
                    pen_holder_inset_dimensions = [wall_thickness_x, pen_holder_inset_ylen, pen_holder_inset_zlen] + dif * [2, 1, 1];
                    translate(main_dimensions - pen_holder_inset_dimensions + dif*[1,1,1])
                        round_out_3d(pen_holder_inset_rounding_radius,0,pen_holder_inset_dimensions)
                            cube(pen_holder_inset_dimensions);
                }

                // screw seating
                screw_position()
                    union() {
                        cylinder(r=screw_seating_full_diameter/2, h=screw_seating_zlen);
                        translate([0, -0.5*screw_seating_full_diameter, 0])
                            cube([screw_xpos_from_outer, screw_seating_full_diameter, screw_seating_zlen]);
                    }

                // front nub holder
                translate([xlen - nub_front_holder_xlen,0,0])
                    cube([nub_front_holder_xlen, nub_front_holder_ylen, nub_front_holder_zlen]);
            }
            // the screw
            screw_position()
                translate([0,0,-dif])
                    rotate([0,180,0])
                        generic_screw_3d(screw_grooving_diameter, screw_depth+2*dif, screw_head_diameter+2*screw_head_clearance, screw_head_depth+dif);

            if (branding) {
                // the text (engraving-style)
                translate([xlen-writing_depth,writing_ypos,laptop_base_rounding_radius+0.5*(zlen-laptop_base_rounding_radius-writing_font_size)])
                    rotate([90,0,90])
                        linear_extrude(height=writing_depth+dif)
                            text(text, font="Century Gothic:style=Bold", size=writing_font_size);
            }
        }

        // top nubs
        for (ypos = nubs_top_ypos) {
            translate([xlen-wall_thickness_x,ypos+nub_top_ylen,zlen])
                rotate([0,90,180])
                    sloped_nub(nub_top_xlen, nub_top_ylen, nub_top_zlen, nub_top_z_overlap, nub_top_slope);
        }
        translate([xlen-nub_front_holder_xlen,0,nub_front_holder_zlen-nub_top_ylen])
            rotate([90,0,0])
                cube([nub_front_xlen, nub_front_ylen, nub_front_zlen]);

        // side nub
        translate([0,nub_side_ypos,wall_thickness_z]) {
            sloped_nub(nub_side_xlen, nub_side_ylen, nub_side_zlen, nub_side_x_overlap, nub_side_slope);
        }
}

x220t_hdd_lid(variant == "branded");
