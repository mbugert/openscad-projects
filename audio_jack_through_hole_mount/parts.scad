use <external/quickthread.scad>

// ----- measurements ------
jack_z = 19;
jack_d = 10.4;	// full diameter when seen from front
jack_ring_z = 3;
jack_ring_additional_r = 0.4;
jack_pinch_prot_r1 = 4;
jack_pinch_prot_r2 = 4.5;
jack_pinch_prot_z = 15;

// dashboard plastic thickness
dashboard_plastic_t = 3;


// ----- settings ------
$fn = 20;
$fn_thread = 20;

nozzle_d = 0.4;

// wiggle room between mount shoe and jack
shoe_to_jack_tolerance_r = 0.15;
thread_to_thread_tolerance_r = 0.1;

// thickness of mount shoe with thread and plate base wall thickness - at the thickest part I assume
mount_wall_t = 2.5;

nut_z = 6;

mount_shoe_plate_base_z = 6;
mount_shoe_plate_base_d = 27;

thread_d = jack_d + 2*shoe_to_jack_tolerance_r + 2*mount_wall_t;
thread_pitch = 3;
thread_angle = 40;

module mount_shoe_plate_base(z, r2=0.66*mount_wall_t+thread_d/2) {
	intersection() {
		cylinder(r1=mount_shoe_plate_base_d/2, r2=r2, h=z);

		linear_extrude(height=z, scale=0.85) {
			inset = 6;
			square([mount_shoe_plate_base_d,mount_shoe_plate_base_d-inset], center=true);
		}
	}
}

module mount_shoe() {
	z = jack_z;
	thread_z = dashboard_plastic_t + nut_z;
	mount_shoe_plate_base_z = jack_z - thread_z;

	module mount_wall_thread() {
		// thread
		render(convexity=5)
			difference() {
			    isoThread(d=thread_d,
			    	h=thread_z,
			    	pitch=thread_pitch,
			    	angle=thread_angle,
			    	internal=false,
			    	$fn=$fn_thread);
		}

		// round out the transition from the thread to the fixed nut
		fillet_h = 2;
		fillet_r = 2;
		fillet_z = 2;
		difference() {
			cylinder(r=thread_d/2, h=fillet_z);
			translate([0,0,fillet_z])
			rotate_extrude() {
				translate([thread_d/2,0,0])
					circle(fillet_z);
			}
		}
	}
	difference() {
		union() {
			translate([0,0,mount_shoe_plate_base_z]) {
				mount_wall_thread();
				rotate([180,0,0])
					mount_shoe_plate_base(z=mount_shoe_plate_base_z, r2=jack_d/2+mount_wall_t);
			}
		}

		// remove jack from inside (with wiggle room)
		minkowski() {
			jack();
			sphere(r=shoe_to_jack_tolerance_r+nozzle_d/2);
		}
	}
}

module mount_nut(tolerance_r) {
	dif = 1;
	difference() {
		mount_shoe_plate_base(z=nut_z);
	    translate([0,0,-dif])
	    	render(convexity=5)
		    	isoThread(d=thread_d+tolerance_r*2,
		    		h=mount_shoe_plate_base_z + 2*dif,
		    		pitch=thread_pitch,
		    		angle=thread_angle,
		    		internal=true,
		    		$fn=$fn_thread);
	}
}

module jack() {
	cylinder(d=jack_d, h=jack_z);
	translate([0,0,-jack_ring_z]) {
		cylinder(d=jack_d + 2*jack_ring_additional_r, h=jack_ring_z);

		translate([0,0,-jack_pinch_prot_z]) {
			cylinder(r1=jack_pinch_prot_r1, r2=jack_pinch_prot_r2, h=jack_pinch_prot_z);
		}
	}
}

module mount_nuts() {
	tolerances = [0.4, 0.5, 0.6];
	for (i = [0,1,2]) {
		translate([0,i*mount_shoe_plate_base_d,0]) {
			mount_nut(tolerances[i]);
		}
	}
}
