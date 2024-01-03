E = 2.7182818284590452;

// extra space, so difference() operations in 3D are rendered without
// z-fighting in the OpenSCAD preview
dif = 1;
dif_factor = 1.01;

// sometimes a large value is needed to cut certain regions
max_value = 100000;

// Acute angle between horizon and part. The smallest angle the printer
// can handle without supports.
printer_max_overhang_degrees = 55;

// TODO relate clearance to printer nozzle diameter

clearance_fit = 0.1;
clearance_medium = 0.2;
clearance_loose = 0.4;

function clamp(v, min_, max_) = min(max(v, min_), max_);

module cylinder_slice(r, h, a){
    rotate_extrude(angle=a) {
        square([r, h]);
    }
}

module pill(d, l, center=false) {
    translation = center? [0, -(l-d)/2] : [d/2, d/2];
    translate(translation) {
        hull() {
            circle(d=d);
            translate([0, l - d]) {
                circle(d=d);
            }
        }
    }
}

// Two-dimensional U shape. The U shape opens towards +y.
// With u_angle, the U can be opened (<180) or closed (>180) further.
// If center=true, U bend's origin will be positioned at (0, 0, 0).
// If center_rotation=true, the shape is rotated so that the U shape opens
// towards +y even if u_angle != 180.
// Two children objects can be passed, which will be positioned at the center
// of one of the two U's tips. If children_only=true, the U shape is not drawn,
// and only the child positioning is run.
module u_shape(d_inner, t, arms_l, u_angle=180, center=true,
               center_rotation=true, children_only=false) {
    translation = center? [0, 0] : (d_inner/2 + t) * [1, 1];
    rotation = center_rotation? [0, 0, -(u_angle - 180) / 2] : [0, 0, 0];
    translate(translation) {
        rotate(rotation) {
            if (!children_only) {
                rotate([0, 0, 180]) {
                    difference() {
                        circle_section(d_inner/2 + t, u_angle);
                        circle_section(d_inner/2, u_angle);
                    }
                }
            }
            rotate([0, 0, u_angle - 180]) {
                translate([d_inner/2, 0]) {
                    if (!children_only) {
                        square([t, arms_l]);
                    }
                    if ($children == 2) {
                        translate([t/2, arms_l]) {
                            children(0);
                        }
                    }
                }
            }
            translate([-d_inner/2 - t, 0]) {
                if (!children_only) {
                    square([t, arms_l]);
                }
                if ($children == 2) {
                    translate([t/2, arms_l]) {
                        children(1);
                    }
                }
            }
        }
    }
}

module closing(r) {
    offset(-r) {
        offset(r) {
            children();
        }
    }
}

module opening(r) {
    offset(r) {
        offset(-r) {
            children();
        }
    }
}

module circle_section(r, deg) {
    // triangle section covering up to 90°
    module 90_deg_segment(d) {
        points = [[0, 0], [1, 0], [cos(d), sin(d)]];
        polygon(points);
    }
    // combination of triangle sections covering up to 360°
    module 360_deg_segment() {
        for (i = [0:90:360]) {
            if (deg > i) {
                rotate([0, 0, i]) {
                    90_deg_segment(min(deg - i, 90));
                }
            }
        }
    }
    intersection() {
        circle(r);
        scale(2*r) {
            360_deg_segment();
        }
    }
}

// For 2D round chamfers, see https://forum.openscad.org/how-to-make-round-chamfer-at-2D-object-tp19714p19799.html
module round_chamfer(r=0, delta=0, chamfer=false, keep_size = false) {
    if (keep_size) {
        offset(r)
            offset(-r)
                offset(-r)
                    offset(r)
                        children();
    } else {
        offset(r = r, chamfer = chamfer)
            children();
    }
}


// Given child objects and a box-shaped approximation of their hull, apply
// rounding to a certain edge. `radius` is the rounding radius, `which_edge` is
// the edge identifier in [0,11], `object_dims` are the dimensions of the
// box surrounding the to-be-rounded object as [x,y,z].
module round_out_3d(radius, which_edge, object_dims) {
    axis_index = floor(which_edge / 4);

    // the length of the rounding template depends on the axis in which the edge lies
    edge_len = object_dims[axis_index];

    // rotate to place rounding template in the axis in which the edge lies
    rot_to_axis = [[90,0,90],[-90,-90,0],[0,0,0]][axis_index];

    // translations necessary for whichever axis is chosen
    // example: axis 11 lies in the z-axis furthest away from the origin - therefore, the rounding template needs to be translated along the objects x and y axes
    do_tr_ax1 = (which_edge % 4) >= 2? 1 : 0;
    do_tr_ax2 = (which_edge % 4) % 2 == 1? 1 : 0;

    // translations along an axis as far as the object is long in that axis
    tr_x = [object_dims[0],0,0];
    tr_y = [0,object_dims[1],0];
    tr_z = [0,0,object_dims[2]];
    tr_ax1 = [tr_y, tr_x, tr_x][axis_index];
    tr_ax2 = [tr_z, tr_z, tr_y][axis_index];

    // rotation according to which edge is chosen
    rot_to_edge_angle = [0,-90,90,180][do_tr_ax1*2 + do_tr_ax2];
    rot_to_edge = rot_to_edge_angle * [[1,0,0],[0,-1,0],[0,0,1]][axis_index];

    difference() {
        children();

        // move rounding template according to edge selection
        translate(do_tr_ax2 * tr_ax2)
        translate(do_tr_ax1 * tr_ax1)
        rotate(rot_to_edge)
        rotate(rot_to_axis)

        // rounding template
        translate([-dif,-dif,0]) {
            difference() {
                translate([0,0,-dif])
                    cube([radius+dif, radius+dif, edge_len+2*dif]);
                translate([radius+dif,radius+dif,-2*dif])
                    cylinder(r=radius, h=edge_len+4*dif);
            }
        }
    }
}

// Honeycomb structure.
// Parameters: hex inner diameter, wall thickness, how many in x, how many in y
module honeycomb_2d(s, t, x, y, center=false) {
    module hex() {
        difference() {
            circle($fn=6, r=s+t);
            circle($fn=6, r=s);
        }
    }
    module hex_column(y) {
        for (yi=[0:1:y-1]) {
            dx = 0;
            dy = 2*cos(30)*(s+t/2);
            translate(yi*[dx,dy]) {
                hex();
            }
        }
    }
    module hex_grid() {
        for (xi=[0:1:x-1]) {
            dx = xi*3*sin(30)*(s+t/2);
            dy = (xi%2 == 0? 0 : 1)*sin(60)*(s+t/2);
            translate([dx, dy]) {
                hex_column(y);
            }
        }
    }

    if (center) {
        dx = -(x-1)/2*3*sin(30)*(s+t/2);
        dy = -y*cos(30)*(s+t/2);
        translate([dx, dy]) {
            hex_grid();
        }
    } else {
        hex_grid();
    }
}

// Diamond structure.
// t: strut thickness
// s: horizontal inner diameter (measured at the center of the struts, i.e. assuming t=0)
// x: how many in x
// y: how many in y
// opening angle: an opening angle of 45° will produce squares standing on a corner
module diamond_2d(s, t, x, y, opening_angle=printer_max_overhang_degrees, center=false) {
    module piece() {
        hyp = 0.5 * s / cos(opening_angle);
        translate([-s/2, 0]) {
            rotate([0, 0, opening_angle]) {
                translate([0, -t/2]) {
                    square([hyp, t]);
                }
            }
        }
    }
    module diamond() {
        mirror_copy([0, 1, 0]) {
            mirror_copy([1, 0, 0]) {
                piece();
            }
        }
    }
    module diamond_grid() {
        // make a grid of diamonds
        for (xi=[0:1:x-1]) {
            for (yi=[0:1:y-1]) {
                translate([xi * dx, yi * dy]) {
                    diamond();
                }
            }
        }
    }

    dx = s;
    dy = s * tan(opening_angle);

    if (center) {
        translate([(1-x)/2 * dx, (1-y)/2 * dy]) {
            diamond_grid();
        }
    } else {
        translate([dx/2, dy/2]) {
            diamond_grid();
        }
    }
}

// mirror and keep the original
module mirror_copy(v) {
    mirror(v) {
        children();
    }
    children();
}

// Cylinder with dimples in it. Can be differenced with other geometry to
// signify where a model can be grabbed or pinched.
module finger_negative_with_dimples(h, d=25, depth=0.25, dimple_r = 1.5, dimples_per_360=19) {
    // vertical distance of rings depends on dimple angular distance
    ring_z_dist = 0.5 * PI * d / dimples_per_360;
    // number of rings depends on cylinder target height
    num_rings = max(ceil(h / ring_z_dist), 1) + 1;
    difference() {
        cylinder(d=d, h=h);
        for (ring = [0:num_rings-1]) {
            for (xi = [0:dimples_per_360-1]) {
                // two rows with interleaved children
                z_rot_degrees = 360 * (xi + 1) + (ring % 2 == 0? 0 : 180);
                rotate([0, 0, z_rot_degrees / dimples_per_360]) {
                    translate([d/2 + (1 - depth) * dimple_r, 0, ring * ring_z_dist]) {
                        sphere(dimple_r, $fn=30);
                    }
                }
            }
        }
    }
}
