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

module cylinder_slice(r, h, a){
    rotate_extrude(angle=a) {
        square([r, h]);
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
