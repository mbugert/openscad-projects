// extra space, so difference() operations in 3D are rendered without
// z-fighting in the OpenSCAD preview
dif = 1;

// sometimes a large value is needed to cut certain regions
max_value = 100000;

// Acute angle between horizon and part. The smallest angle the printer
// can handle without supports.
printer_max_overhang_degrees = 55;

clearance_fit = 0.1;
clearance_medium = 0.2;
clearance_loose = 0.4;

module screw_hole_2d(d, clearance=0) {
    hole_d = d + 2*clearance;
    circle(d = hole_d);
}

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
