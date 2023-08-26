// This file defines simplified shapes of screws, nuts, and bolts. The idea is
// to use these with the difference operation to cut screw holes into objects.

include <common.scad>;


// ----------------------------------------------------------------------------
// MEASUREMENTS

// DIN 912 allen bolt
// d, d_k, k, s -- diameter, head outside diameter, head height, head inside diameter
_din912_specs = [
	["M1.4", 1.4, 2.6, 1.4, 1.3],
	["M1.6", 1.6, 3,   1.6, 1.5],
	["M2",   2,   3.8, 2,   1.5],
	["M2.5", 2.5, 4.5, 2.5, 2],
	["M3",   3,   5.5, 3,   2.5],
	["M4",   4,   7,   4,   3],
	["M5",   5,   8.5, 5,   4],
	["M6",   6,   10,  6,   5],
	["M8",   8,   13,  8,   6],
	["M10",  10,  16,  10,  8],
	["M12",  12,  18,  12,  10],
	["M14",  14,  21,  14,  12],
	["M16",  16,  24,  16,  14],
	["M18",  18,  27,  18,  14],
	["M20",  20,  30,  20,  17],
	["M22",  22,  33,  22,  17],
	["M24",  24,  36,  24,  19],
	["M27",  27,  40,  27,  19],
	["M30",  30,  45,  30,  22],
	["M33",  33,  50,  33,  24],
	["M36",  36,  54,  36,  27],
	["M39",  39,  58,  39,  27],
	["M42",  42,  63,  42,  32],
	["M45",  45,  68,  45,  36],
	["M52",  52,  78,  52,  36],
	["M56",  56,  84,  56,  41],
	["M64",  64,  96,  64,  46],
	["M72",  72,  108, 72,  55]
];

// DIN 7997 countersunk screw, pozidriv
// d, k_max, d1 -- diameter, maximum head height, head diameter
// countersunk angle is 90°
_din7997_specs = [
	["M3",   3.0, 1.65, 5.6],
	["M3.5", 3.5, 1.93, 6.5],
	["M4",   4.0, 2.2,  7.5],
	["M4.5", 4.5, 2.35, 8.3],
	["M5",   5.0, 2.5,  9.2],
	["M6",   6.0, 3,    11],
];

// ISO 7045 pan head screw, pozidriv
// d, max_a, d_k, k, v -- diameter, max length without thread, head diameter, head height, head height vertical section
_iso7045_specs = [
	["M2", 2, 0.8, 4, 1.6, 1.1],
	["M2.5", 2.5, 0.9, 5, 2, 1.3],
	["M3", 3, 1, 6, 2.4, 1.6],
	["M3.5", 3.5, 1.2, 7, 2.7, 1.9],
	["M4", 4, 1.4, 8, 3.1, 2],
	["M5", 5, 1.6, 10, 3.8, 2.5],
	["M6", 6, 2, 12, 4.6, 3],
	["M8", 8, 2.5, 16, 6, 3.7]
];

// ISO 4032 hex nut
// d, m, s -- inside diameter, thickness, outside diameter
_iso4032_specs = [
	["M1",   1,   0.8,  2.5],
	["M1.2", 1.2, 1,    3],
	["M1.4", 1.4, 1.2,  3],
	["M1.6", 1.6, 1.3,  3.2],
	["M1.7", 1.7, 1.4,  3.5],
	["M2",   2,   1.6,  4],
	["M2.3", 2.3, 1.8,  4.5],
	["M2.5", 2.5, 2,    5],
	["M2.6", 2.6, 2,    5],
	["M3",   3,   2.4,  5.5],
	["M3.5", 3.5, 2.8,  6],
	["M4",   4,   3.2,  7],
	["M5",   5,   4.7,  8],
	["M6",   6,   5.2,  10],
	["M7",   7,   5.5,  11],
	["M8",   8,   6.8,  13],
	["M10",  10,  8.4,  16],
	["M12",  12,  10.8, 18],
	["M14",  14,  12.8, 21],
	["M16",  16,  14.8, 24],
	["M18",  18,  15.8, 27],
	["M20",  20,  18,   30],
	["M22",  22,  19.4, 34],
	["M24",  24,  21.5, 36],
	["M26",  26,  22,   41],
	["M27",  27,  23.8, 41],
	["M30",  30,  25.6, 46],
	["M33",  33,  28.7, 50],
	["M36",  36,  31,   55],
	["M39",  39,  33.4, 60],
	["M42",  42,  34,   65],
	["M45",  45,  36,   70],
	["M48",  48,  38,   75],
	["M52",  52,  42,   80],
	["M56",  56,  45,   85],
	["M60",  60,  48,   90],
	["M64",  64,  51,   95],
	["M68",  68,  54,   100],
	["M72",  72,  58,   105],
	["M76",  76,  61,   110],
	["M80",  80,  64,   115],
	["M85",  85,  68,   120],
	["M90",  90,  72,   130],
	["M95",  95,  75,   135],
	["M100", 100, 80,   145],
	["M105", 105, 82,   150],
	["M110", 110, 88,   155],
	["M120", 120, 95,   175],
];

// DIN 562 square nut
// d, s, e_min, m -- inside diameter, outside diameter, outside diagonal diameter, thickness
_din562_specs = [
	["M1.6", 1.6, 3.2, 4,    1],
	["M2",   2,   4,   5,    1.2],
	["M2.5", 2.5, 5,   6.3,  1.6],
	["M3",   3,   5.5, 7,    1.8],
	["M4",   4,   7,   8.9,  2.2],
	["M5",   5,   8,   10.2, 2.7],
	["M6",   6,   10,  12.7, 3.2],
	["M8",   8,   13,  16.5, 4],
	["M10",  10,  17,  21.5, 5],
];

function _select_spec(m, specs) = [for (spec = specs) if (spec[0] == m) spec][0];


// ----------------------------------------------------------------------------
// PARAMETERS

screw_fn = 20;

// ----------------------------------------------------------------------------
// PARTS

module _apply_clearance(clearance) {
	minkowski() {
		children();
		if (clearance > 0) {
			sphere(r=clearance);
		}
	}
}

module axle(m, l, clearance, specs) {
	spec = _select_spec(m=m, specs=specs);
	d = spec[1];

	_apply_clearance(clearance=clearance) {
		translate([0,0,-l]) {
			cylinder(d=d, h=l, $fn=screw_fn);
		}
		children();
	}
}

module axle_2d(m, clearance=0.0) {
	spec = _select_spec(m=m, specs=_din912_specs);
	d = spec[1];
	offset(r=clearance) {
		circle(d=d, $fn=screw_fn);
	}
}

module _din912_head(m, k, clearance) {
	spec = _select_spec(m=m, specs=_din912_specs);
	d = spec[1];
	d_k = spec[2];
	_k = (clearance > 0 && k != undef)? k : spec[3];
	s = spec[4];

	difference() {
		cylinder(d=d_k, h=_k, $fn=screw_fn);
		if (clearance <= 0) {
			translate([0, 0, dif]) {
				// TODO potentially incorrect
				cylinder(d=s, h=_k+dif, $fn=6);
			}
		}
	}
}

// DIN 912 allen bolt
module din912(m, l=10, k=undef, clearance=0.0) {
	axle(m, l=l, clearance=clearance, specs=_din912_specs) {
		_din912_head(m, k=k, clearance=clearance);
	}
}

module _din7997_head(m, k, clearance) {
	spec = _select_spec(m=m, specs=_din7997_specs);
	d = spec[1];
	k_max = spec[2];
	d_k = spec[3];
	_k = (clearance > 0 && k != undef)? k : spec[4];

	head_z = min(k_max, ((d_k - d)/2) / tan(45));
	difference() {
		union() {
			// if clearance is given, add a cylinder-shaped head
			if (clearance > 0 && k != undef) {
				translate([0, 0, head_z]) {
					cylinder(d=d_k, h=k - head_z, $fn=screw_fn);
				}
			}
			// cone
			cylinder(d1=d, d2=d_k, h=head_z, $fn=screw_fn);
		}
		if (clearance <= 0) {
			// TODO add pozidriv shape
		}
	}
}

// DIN 7997 countersunk screw, pozidriv
module din7997(m, l=10, k=undef, clearance=0.0) {
	axle(m, l=l, clearance=clearance, specs=_din7997_specs) {
		_din7997_head(m, k=k, clearance=clearance);
	}
}

module _iso7045_head(m, k, clearance) {
	spec = _select_spec(m=m, specs=_iso7045_specs);
	d = spec[1];
	d_k = spec[3];
	_k = (clearance > 0 && k != undef)? k : spec[4];
	v = spec[5];

	difference() {
		// if clearance is given, create a cylinder-shaped head
		if (clearance > 0 && k != undef) {
			cylinder(d=d_k, h=k);
		} else {
			// half-sphere
			translate([0, 0, v]) {
				resize([d_k, d_k, _k - v]) {
					intersection() {
						sphere(d=d_k, $fn=screw_fn);
						translate([0,0,d_k/4]) {
							cube([d_k, d_k, d_k/2], center=true);
						}
					}
				}
			}
			cylinder(d=d_k, h=v, $fn=screw_fn);
		}
		if (clearance <= 0) {
			//// TODO add pozidriv shape
			//cross_arm_length = ...
			//cross_arm_width = ...
			//cross_arm_depth = ...
			//translate([0,0,-cross_arm_depth]) {
			//	linear_extrude(height=cross_arm_depth+dif) {
			//		rotate([0,0,90]) {
			//			square([cross_arm_length, cross_arm_width], center=true);
			//		}
			//		square([cross_arm_length, cross_arm_width], center=true);
			//	}
			//}
		}
	}
}

// ISO 7045 pan head screw, pozidriv
module iso7045(m, l=10, k=undef, clearance=0.0) {
	axle(m, l=l, clearance=clearance, specs=_iso7045_specs) {
		_iso7045_head(m, k=k, clearance=clearance);
	}
}

// ISO 4032 hex nut
module iso4032(m, k=undef, clearance=0.0) {
	spec = _select_spec(m=m, specs=_iso4032_specs);
	d = spec[1];
	_k = (clearance > 0 && k != undef)? k : spec[2];
	s = spec[3];

	_apply_clearance(clearance=clearance) {
		linear_extrude(height=_k) {
			difference() {
				rotate([0, 0, 30]) {
					r = s / sqrt(3);
					circle(r=r, $fn=6);
				}
				if (clearance <= 0) {
					circle(d=d, $fn=screw_fn);
				}
			}
		}
	}
}

// DIN 562 square nut
module din562(m, k=undef, clearance=0.0) {
	spec = _select_spec(m=m, specs=_din562_specs);
	d = spec[1];
	s = spec[2];
	_k = (clearance > 0 && k != undef)? k : spec[4];

	_apply_clearance(clearance=clearance) {
		linear_extrude(height=_k) {
			difference() {
				square([d, d], center=true);
				if (clearance <= 0) {
					circle(d=m, $fn=screw_fn);
				}
			}
		}
	}
}

// Creates a chute for a square nut. Screw would be positioned on the y-axis, the chute points towards +x.
// m: self-explanatory
// chute_len: length of chute (measured from rotational origin of the square nut)
// clearance_vertical: vertical clearance of the chute (with the nut lying flat on its largest surface area)
// clearance_horizontal: horizontal clearance of the chute (with the nut lying flat on its largest surface area)
module din562_chute(m, k, clearance_vertical=0.0, clearance_horizontal=0.0) {
	spec = _select_spec(m=m, specs=_din562_specs);
	s = spec[2];
	m = spec[4];

	xy = s + clearance_horizontal;
    z = m + clearance_vertical;

	cube([xy, xy, z], center=true);
	translate([k/2, 0, 0]) {
		cube([k, xy, z], center=true);
	}
}


// Generic, non-standardized screw.
module generic_screw_3d(d, l, head_d, head_z) {
    translate([0, 0, -head_z]) {
        cylinder(r=head_d/2, h=head_z);
        translate([0, 0, -l])
            cylinder(r=d/2, h=l+dif);
    }
}
