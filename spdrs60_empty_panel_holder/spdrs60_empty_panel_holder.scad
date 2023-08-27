include <../shared/common.scad>

$fn=100;

// basic lengths and thicknesses
x = 53.5;
y = 33.5;
z = 18;
tx = 4;
ty = 2;

// screw dimensions
screw_head_r = 2.5;
screw_head_z = 2;
screw_head_tolerance = 0.25;
screw_head_inset_z = 3.5;
screw_r = 1.5;
screw_inset_xy = 1;
screw_housing_thick = 1.5;

// dimensions for the cutouts holding the clips of the panel in place
panel_clip_holder_inner_x = 8;
panel_clip_holder_inner_r = 1.5;
panel_clip_holder_outer_x = 2.25; // "tx - panel_clip_holder_outer_x" is the wall thickness on the sides at that point
panel_clip_holder_outer_bump_x = 0.75; // how far the bump for the panel clips protrudes towards the inside
panel_clip_holder_bump_z = 9; // 9mm from the top and 9mm from the bottom
panel_clip_holder_y = 5;

// dimensions for the cutouts for the panel cover clips (those slim clips wrapping around a panel in all four corners)
panel_cover_clips_cutout_x_from_outer = 9.75;
panel_cover_clips_cutout_x = 5.5;
panel_cover_clips_cutout_z = 1;

// honeycomb fill dimensions
comb_x = 7;
comb_y = 4;
comb_thick = 1.25;
comb_size = (x-2*tx)/comb_x - comb_thick;
comb_lowest_z = 5;
comb_highest_z = 0.75*z;

module outer_shell() {
    translate([0,0,z/2])
        cube([x,y,z], center=true);
}

module shell_cutout() {
    dims = [x,y,z] - [2*tx, 2*ty, 0] + [0,0,2*dif];
    translate([0,0,dims[2]/2 - dif])
        cube(dims, center=true);
}

module honey() {
    // remove an ellipsoid from the honeycomb to save some material
    difference() {
        linear_extrude(height=comb_highest_z) {
            honeycomb_2d(comb_size, comb_thick, comb_x, comb_y, center=true);
        }
        translate([0,0,comb_highest_z])
            resize([x,y,2*(comb_highest_z-comb_lowest_z)])
                sphere(1);
    }
}

module screw_pos() {
    in = screw_inset_xy + screw_r;
    positions = [0.5*[x,y]+[-in,-in], 0.5*[-x,y]+[in,-in], 0.5*[-x,-y]+[in,in], 0.5*[x,-y]+[-in,in]];
    rotations = [0, 90, 180, 270];
    for (i=[0:3]) {
        translate(positions[i])
            rotate(rotations[i])
                children();
    }
}

module screw_holes() {
    r = screw_head_r + screw_head_tolerance;
    h = screw_head_inset_z+dif;
    screw_pos() {
        dims = [2*r,2*r,h] + [dif,dif,dif];
        translate([-r,-r,z-screw_head_inset_z]) {
            round_out_3d(r, 8, dims)
                cube(dims);
            }
        
        // screw hole
        translate([0,0,-dif]) {
            cylinder(r=screw_r + clearance_fit, h=z+2*dif);
        }
    }
}

module screw_housings() {
    screw_pos() {
        cylinder(r=screw_head_r + screw_head_tolerance + screw_housing_thick, h=z);
    }
}

module screws() {
    screw_pos() {
        color("salmon", 0.8)
            translate([0,0,z-screw_head_inset_z+screw_head_z])
                screw(2*screw_r, z, 2*screw_head_r, screw_head_z);
    } 
}

module panel_clip_holes() {
    module panel_clip_cutout() {
        inner = panel_clip_holder_inner_x;
        outer = panel_clip_holder_outer_x;
        bump_z = panel_clip_holder_bump_z;
        bump_x = panel_clip_holder_outer_bump_x;
        
        translate([0,panel_clip_holder_y/2,0])
            rotate([90,0,0])
                linear_extrude(height=panel_clip_holder_y)
                    difference() {
                        translate([-inner,-dif])
                            square([inner+outer, z+2*dif]);
                        polygon([[outer, z], [outer, bump_z], [outer-bump_x, bump_z]]);
                    }
    }
    
    translate([x/2-tx,0,0])
        panel_clip_cutout();
    translate([-x/2+tx,0,0])
        rotate([0,0,180])
            panel_clip_cutout();
}

module panel_cover_clips_cutouts() {   
    module panel_cover_clips_cutout() {
        translate([0,0,0.5*(dif-panel_cover_clips_cutout_z)+z])
            cube([panel_cover_clips_cutout_x, y+2*dif, panel_cover_clips_cutout_z+dif], center=true);
    }
    
    x_from_outer = panel_cover_clips_cutout_x_from_outer;
    translate([x/2-x_from_outer,0,0])
        panel_cover_clips_cutout();
    translate([-(x/2-x_from_outer),0,0])
        panel_cover_clips_cutout();
}

module spdrs60_empty_panel_holder() {
    difference() {
        union() {
            difference() {
                outer_shell();
                shell_cutout();
            }
            intersection() {
                outer_shell();
                screw_housings();
            }   
            intersection() {
                outer_shell();
                honey();
            }
        }        
        screw_holes();
        panel_clip_holes();
        panel_cover_clips_cutouts();
    }
//    screws();
}

spdrs60_empty_panel_holder();
