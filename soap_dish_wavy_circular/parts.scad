include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// PARAMETERS

// tray diameter (millimeters)
tray_d = 80;

// thickness and target distance between beams -- this determines the number
// of beams (the beam distance will increase/decrease a bit to make things fit)
tray_beam_t = 3;
tray_beam_target_dist = 5;

// tray_surface.dat resolution
tray_surface_resolution = 100;
// z-amplitude of wavy surface
tray_surface_waves_z = tray_d / 10;
// extra z-height for all beams to ensure minimum height for robustness (the
// actual tray_surface_waves_z is reduced by this value)
tray_surface_base_z = 2;

// tray ring thickness on xy-plane
tray_ring_t = 3;
// tray ring thickness on z axis
tray_ring_z = 2.5;
// tray ring waviness from completely flat (0.0) to beam-level waviness (1.0)
tray_ring_waviness = 0.75;
// rounding (optional)
tray_minkowski_sphere_r = 0.3;

// full base z-height, incl. rim and floor
base_z = 12;
// base floor thickness
base_floor_t = 1.5;
// base wall thickness
base_wall_t = 1.5;
// height of the rim the tray is placed on
base_rim_z = tray_surface_base_z;
// width of the rim the tray is placed on
base_rim_width = tray_beam_t;
// rounding (optional)
base_minkowski_r = 0.3;
base_outer_r = tray_d/2 + clearance_medium + base_wall_t;

// parameters for the experimental ring-mounted base
base_ring_t = 20;
base_ring_inside_d = 72;
base_ringmount_inner_r = base_ring_inside_d/2;
base_ringmount_reinforcement_t = 0.5;
base_ringmount_reinforcement_width_angle = 2;
base_ringmount_reinforcement_frequency_angle = 20;

// ----------------------------------------------------------------------------
// PARTS

// It looks better with minkowski, but enabling it will break compilation
// because of this issue: https://github.com/openscad/openscad/issues/4039
// We keep the model feature for the future.
module tray(use_minkowski = false) {
    tray_d_wout_minkowski = use_minkowski? tray_d - 2*tray_minkowski_sphere_r : tray_d;

    module tray_wave_surface() {
        // cos * cos surface
        intersection() {
            scale([1, 1, 0.5 * tray_surface_resolution] / tray_surface_resolution) {
                surface(file="tray_surface.dat", center=true);
            }
            translate([0, 0, 0.5]) {
                cube(1, center=true);
            }
        }
    }

    // the same surface, but scaled to make it more soap tray-ish
    module tray_wave_surface_cylindrical() {
        // extra z-height which is applied to all beams (to ensure minimum
        // thickness)
        cylinder(d=tray_d_wout_minkowski, h=tray_surface_base_z);

        // reduce actual wave surface z-height by the base height, and shift
        // upwards to compensate by the extra base z-height
        translate([0, 0, tray_surface_base_z]) {
            scale([tray_d_wout_minkowski, tray_d_wout_minkowski, tray_surface_waves_z - tray_surface_base_z]) {
                intersection() {
                    scale([1.5, 2, 2]) {
                        tray_wave_surface();
                    }
                    cylinder(d=1, h=1);
                }
            }
        }
    }

    module tray_beams() {
        tray_num_beams = round((tray_d - tray_beam_t) / (tray_beam_t+tray_beam_target_dist));

        // cut beams from the wave surface
        intersection() {
            tray_wave_surface_cylindrical();
            // translate by tray_beam_t to make sure there are no half-width beams at either end
            translate([-(tray_d_wout_minkowski - tray_beam_t) / 2, 0, 0]) {
                for(i=[0:tray_num_beams]) {
                    translate([(i/tray_num_beams) * (tray_d_wout_minkowski - tray_beam_t), 0, tray_surface_waves_z/2]) {
                        cube([tray_beam_t, tray_d_wout_minkowski, tray_surface_waves_z], center=true);
                    }
                }
            }
        }
    }

    module tray_ring() {
        // add a wavy ring
        difference() {
            scale([1, 1, tray_ring_waviness]) {
                tray_wave_surface_cylindrical();
            }
            // need to scale little larger to not leave ugly extra geometry
            // behind after difference()
            translate([0 ,0, -tray_ring_z]) {
                scale([dif_factor, dif_factor, tray_ring_waviness]) {
                    tray_wave_surface_cylindrical();
                }
            }
            // remove center of wave surface
            translate([0, 0, -dif]) {
                cylinder(d=tray_d_wout_minkowski - 2*tray_ring_t, h=tray_surface_waves_z + 2*dif);
            }
        }
    }

    module apply_minkowski() {
        translate([0, 0, tray_minkowski_sphere_r]) {
            minkowski() {
                children();
                sphere(r=tray_minkowski_sphere_r, $fn=10);
            }
        }
    }

    if (use_minkowski) {
        apply_minkowski() {
            tray_beams();
        }
        apply_minkowski() {
            tray_ring();
        }
    } else {
        tray_beams();
        tray_ring();
    }
}

module base_tray_rim_2d() {
    // rim on which the tray sits (it's a triangle shape)
    base_tray_rest_y = base_rim_width * tan(printer_max_overhang_degrees);
    polygon(points=[[0, 0], [-base_rim_width, 0], [0, -base_tray_rest_y]]);
}


module base_standalone_2d() {
    // floor
    base_outer_r = tray_d/2 + clearance_medium + base_wall_t;
    square([base_outer_r, base_floor_t]);

    translate([base_outer_r - base_wall_t, 0]) {
        // side wall
        square([base_wall_t, base_z]);
        translate([0, base_z - base_rim_z]) {
            base_tray_rim_2d();
        }
    }
}

module extrude_base() {
    rotate_extrude() {
        opening(base_minkowski_r) {
            closing(base_minkowski_r) {
                children();
            }
        }
    }
}

module base_standalone() {
    extrude_base() {
        base_standalone_2d();
    }
}


module base_ringmount_filled_2d() {
    difference() {
        // start with irregular pentagon
        polygon(points=[
            [0, -base_z],
            [base_ringmount_inner_r, -base_z],
            [base_outer_r, -base_rim_z],
            [base_outer_r, 0],
            [0, 0]]);

        // remove the ring from it, and anything that's straight below (if
        // the base is put on top of the ring, we can't leave any material
        // below the ring, otherwise the base won't fit (or it will fit
        // once, and can never be removed again))
        ring_pos_x = base_ringmount_inner_r + base_ring_t/2 - clearance_loose;
        ring_pos_y = -base_rim_z - base_ring_t/2 + clearance_medium;
        translate([ring_pos_x, ring_pos_y]) {
            circle(d=base_ring_t);

            translate([0, -max_value/2]) {
                square([base_ring_t, max_value], center=true);
            }
        }
    }
}

module base_ringmount_outline_2d() {
    // obtain outline by removing the original shape from a version traced
    // with offset
    difference() {
        base_ringmount_filled_2d();
        offset(-base_wall_t) {
            base_ringmount_filled_2d();
        }

        // remove outline on sides where we don't need it
        // TODO is there a better way to do this?
        translate([0, -base_z + base_wall_t]) {
            square([base_wall_t, base_z - base_wall_t]);
        }
        translate([0, -base_wall_t]) {
            square([base_outer_r - base_wall_t, base_wall_t]);
        }
    }
}

module base_ringmount_2d() {
    base_ringmount_outline_2d();

    // add rim for the tray -- need to intersect because the bottom tip of the
    // rim triangle could be sticking out otherwise
    intersection() {
        translate([base_outer_r - base_wall_t, -base_rim_z]) {
            base_tray_rim_2d();
        }
        base_ringmount_filled_2d();
    }
}

module base_ringmount() {
    extrude_base() {
        base_ringmount_2d();
    }

    // The concave shape makes the part susceptible to collapsing. Improve
    // rigidity by adding reinforcement beams along the z-axis on the
    // inside of the part.
    module reinforcement_beam() {
        intersection() {
            // exclude floor and tray rim from reinforcement
            translate([base_ringmount_inner_r - clearance_loose - base_wall_t - base_ringmount_reinforcement_t, -base_z]) {
                square([base_outer_r, base_z - base_rim_z]);
            }

            // extend outline shape a little towards the inside
            minkowski() {
                base_ringmount_outline_2d();
                intersection() {
                    circle(r=base_ringmount_reinforcement_t);
                    translate([-base_ringmount_reinforcement_t, 0]) {
                        square(base_ringmount_reinforcement_t);
                    }
                }
            }
        }
    }

    intersection() {
        translate([0, 0, -base_z]) {
            for (i=[0:base_ringmount_reinforcement_frequency_angle:360]) {
                rotate([0, 0, i])
                cylinder_slice(r=base_outer_r, h=base_z, a=base_ringmount_reinforcement_width_angle);
            }
        }
        extrude_base() {
            reinforcement_beam();
        }
    }
}
