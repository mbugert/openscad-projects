// Simple generic 3D shape of a screw, for cutting screw holes into objects.
module generic_screw_3d(grooving_diameter, screw_depth, head_diameter, head_depth) {
    translate([0,0,-head_depth]) {
        cylinder(r=head_diameter/2, h=head_depth);
        translate([0,0,-screw_depth])
            cylinder(r=grooving_diameter/2, h=screw_depth+dif);
    }
}

screw_fn = 20;
screw_m3 = "M3";
screw_m4 = "M4";
screw_m5 = "M5";
screw_m6 = "M6";
screw_m8 = "M8";
screw_m10 = "M10";
screw_head_pan = "pan";
screw_head_cylinder = "cyl";
screw_clearance_none = "clearance_none";
screw_clearance_fine = "clearance_fine";
screw_clearance_medium = "clearance_medium";
screw_clearance_coarse = "clearance_coarse";
screw_drive_hex = "hex";
screw_drive_cross = "cross";

module _screw_drive(m, drive) {
	dif=1;
	if (drive == screw_drive_hex) {
		// [s, s_z] -> drive diameter, drive depth (guesswork)
		params = m==screw_m3? [2.5, 2.5/2] : [];
		s = params[0];
		s_z = params[1];
		translate([0,0,-s_z])
			cylinder(d=s, h=s_z+dif, $fn=6);
	} else if (drive == screw_drive_cross) {
		// parameters are guesswork
		params = m==screw_m3? [3.5, 1, 2.5/2] : [];
		cross_arm_length = params[0];
		cross_arm_width = params[1];
		cross_arm_depth = params[2];

		translate([0,0,-cross_arm_depth])
			linear_extrude(height=cross_arm_depth+dif) {
				rotate([0,0,90])
					square([cross_arm_length, cross_arm_width], center=true);
				square([cross_arm_length, cross_arm_width], center=true);
			}
	} else {
		echo(str("Screw drive ", drive, " not supported."));
	}
}

module _screw_head_with_drive(m, bh, clearance, head, drive) {
	if (head==screw_head_cylinder) {
		// [dk, k] -> [screw head diameter, screw head z]
		params = m==screw_m3? [5.5, 3] : [];
		head_d = params[0];
		head_z = params[1];

		if (clearance == screw_clearance_none) {
			difference() {
				cylinder(d=head_d, h=head_z, $fn=screw_fn);
				translate([0,0,head_z])
					_screw_drive(m, drive);
			}
		} else {
			// do not add screw drive to screw shapes used for cutting holes - also, set the screw head height (bh)
			cylinder(d=head_d, h=bh, $fn=screw_fn);
		}
	} else if (head==screw_head_pan) {
		// [dk, k] -> [screw head diameter, screw head z]
		params = m==screw_m3? [5.5, 2] : [];
		head_d = params[0];
		head_z = params[1];

		difference() {
			resize([head_d, head_d, head_z])
				// half-sphere
				intersection() {
					sphere(r=head_d/2, $fn=screw_fn);
					translate([0,0,head_d/4])
						cube([head_d, head_d, head_d/2], center=true);
				}
			// do not add screw drive to screw shapes used for cutting holes
			if (clearance == screw_clearance_none)
				translate([0,0,head_z])
					_screw_drive(m, drive);
		}
	} else {
		echo(str("Screw head ", head, " not supported."));
	}
}

// source: https://international.optimas.com/technical-resources/tapping-sizes/
// [d, clearance fine, clearance medium, clearance coarse]
function axle_params(m) = m==screw_m3? [3, 0.2, 0.4, 0.6] : m==screw_m6? [6, 0.4, 0.6, 1.0] : m==screw_m8? [8, 0.4, 1.0, 2.0] : [];
function axle_params_d(m) = axle_params(m)[0];
function axle_clearance(m, clearance=screw_clearance_none) = (clearance == screw_clearance_fine? axle_params(m)[1] : clearance == screw_clearance_medium? axle_params(m)[2] : clearance == screw_clearance_coarse? axle_params(m)[3] : 0);

// m: M3, M6, etc.
// b: length
// bh: head length - only relevant if screw clearance is not screw_clearance_none
// clearance: if clearance==screw_clearance_none, a regular screw will be created; otherwise axle and screw head will be correspondingly thicker (for creating holes), also the screw drive will be missing to boost rendering speed
// head: head shape
// drive: screw drive
module screw(m, b=20, bh=5, clearance=screw_clearance_none, head=screw_head_pan, drive=screw_drive_cross) {
	axle(m, b=b, clearance=clearance)
		_screw_head_with_drive(m, bh, clearance, head, drive);
}

module axle(m, b=20, clearance=screw_clearance_none) {
	axle_params_m = axle_params(m);
	d = axle_params_d(m);
	clr = axle_clearance(m, clearance);

	// no clearance - regular axis
	if (clr == 0) {
		translate([0,0,-b])
			cylinder(d=d, h=b, $fn=screw_fn);
		children();
	} else {
		minkowski() {
			union() {
				translate([0,0,-b])
					cylinder(d=d, h=b, $fn=screw_fn);
				children();
			}
			sphere(r=clr/2);
		}
	}
}

module axle_2d(m, clearance=screw_clearance_none) {
	axle_params_m = axle_params(m);
	d = axle_params_d(m);
	clr = axle_clearance(m, clearance);

	// no clearance - regular axis
	if (clr == 0) {
		circle(d=d, $fn=screw_fn);
	} else {
		offset(r=clr/2) {
			circle(d=d, $fn=screw_fn);
		}
	}
}

// thickness, edge length
function square_nut_params(m) = m==screw_m3? [1.8, 5.5] : m==screw_m4? [2.2, 7] : m==screw_m5? [2.7, 8] : m==screw_m6? [3.2, 10] : m==screw_m8? [4, 13] : m==screw_m10? [5, 17] : [];
function square_nut_params_t(m) = square_nut_params(m)[0];
function square_nut_params_a(m) = square_nut_params(m)[1];

module square_nut(m, clearance=screw_clearance_none) {
	nut_params = square_nut_params(m);
	t = nut_params[0];
	a = nut_params[1];

	dif=1;
	difference() {
		translate([0,0,t/2])
			cube([a,a,t], center=true);
		translate([0,0,t+dif])
			axle(m, b=t+2*dif);
	}
}

// Creates a chute for a square nut. Screw would be positioned on the y-axis, the chute points towards +x.
// m: self-explanatory
// chute_len: length of chute (measured from rotational origin of the square nut)
// clearance_vertical: vertical clearance of the chute (with the nut lying flat on its largest surface area)
// clearance_horizontal: horizontal clearance of the chute (with the nut lying flat on its largest surface area)
module square_nut_chute(m, chute_len, clearance_vertical=0, clearance_horizontal=0) {
    xy = square_nut_params_a(m) + clearance_horizontal;
    z = square_nut_params_t(m) + clearance_vertical;

	cube([xy, xy, z], center=true);
	translate([chute_len/2,0,0])
		cube([chute_len,xy,z], center=true);
}

module regulating_screw() {
	// regulating screw is frustum-shaped in the original, don't see a reason for this, we'll do a cylinder shape
	regulating_screw_r = 5;
	regulating_screw_z = 10;
    cylinder(r=regulating_screw_r, h=regulating_screw_z);
}
function regulating_screw_z() = 10;

// set to true to see examples
_show_screw_examples = false;
if (_show_screw_examples) {
	screw(screw_m3, b=20);

	translate([8,0,0])
		square_nut(screw_m3);
}
