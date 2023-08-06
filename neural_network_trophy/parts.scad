// ########## IMPORTS ##########
use <../shared/external/text_on.scad>
include <../shared/common.scad>

// ######## DIMENSIONS ########
$fn = 100;

// round pedestal dimensions
base_lower_rad = 50;
base_rad = 47;
base_lower_height = 5;
base_height = 10;

// dimensions for the fancy wave
base_wave_height = 21;
base_wave_horizontal_scale = 2.5;
base_wave_vertical_scale = 0.85;

// writing settings
writing_font_size = 11.5;
writing_depth = base_lower_rad - base_rad;
writing_slant_inward = 0.65*(base_lower_rad - base_rad);

// MLP settings and dimensions
neurons_in_layers = [3, 2, 2];
layer_dist = 32;
neuron_dist = 32;
neuron_r = 10;
acrylic_thickness = 3;
edge_width = 2.5;

module mlp_2d() {
    // neurons
    for(i=[0:len(neurons_in_layers)-1]) {
        translate([-i*layer_dist,(-neurons_in_layers[i]/2 + 0.5) * neuron_dist]) {
            for(n=[0:1:neurons_in_layers[i]-1]) {
                translate([0,n*neuron_dist]) {
                    circle(r=neuron_r);
                }
            }
        }
    }

    // layer connections
    for(i=[0:len(neurons_in_layers)-2]) {
        translate([-i*layer_dist,0,0]) {
            neurons_in_current = neurons_in_layers[i];
            neurons_in_next = neurons_in_layers[i+1];

            for(i=[0:neurons_in_current-1]) {
                translate([0,(i-(neurons_in_current-1)/2)*neuron_dist]) {
                    for(j=[0:neurons_in_next-1]) {
                        h_dist = layer_dist;
                        v_dist = neuron_dist * (i - j + 0.5*(neurons_in_next - neurons_in_current));

                        edge_length = sqrt(h_dist * h_dist + v_dist * v_dist);
                        rotation = atan2(h_dist, v_dist);

                        rotate([0, 0, 180-rotation]) {
                            translate([0, edge_length/2])
                            square([edge_width*2, edge_length], center=true);
                        }
                    }
                }
            }
        }
    }
}

module mlp_3d(thickness) {
    rotate([0,0,0]) {
        linear_extrude(thickness) {
            mlp_2d();
        }
    }
}

module pedestal(text) {
    translate([0,0,-base_wave_vertical_scale * base_wave_height]) {
        intersection() {
            // cylinder intersected with wave
            cylinder(h=base_wave_height, r=base_rad);
            scale([base_wave_horizontal_scale,base_wave_horizontal_scale, base_wave_vertical_scale]) {
                surface_shape();
            }
        }

        translate([0,0,-base_height]) {
            // main pedestal cylinder - clearance_medium is necessary to close a small gap between this and the wave thingy above
            cylinder(h=base_height+clearance_medium, r=base_rad);
            translate([0,0,-base_lower_height])
                // lowest pedestal cylinder
                cylinder(h=base_lower_height, r=base_lower_rad);
            // writing
            color([1.0,0,0]) {
                text_on_cylinder_r1 = base_rad+1+0.5*writing_depth;
                translate([0,0,-0.5*writing_font_size])
                text_on_cylinder(t=text,r1=text_on_cylinder_r1, r2=text_on_cylinder_r1-writing_slant_inward, h=writing_font_size, extrusion_height=writing_depth, font="Century Gothic:style=Bold", size=writing_font_size);
            }
        }
    }
}

module surface_shape() {
    // wave - 11 seems to be roughly the height of the resulting wave
    translate([0,0,11]) intersection() {
        surface(file = "surface.dat", center=true, convexity = 5);
        translate([1,2,0]) rotate(65, [0,0,1])
            surface(file = "surface.dat", center=true, convexity = 5);
    }
}

module pedestal_with_cutout(text) {
    difference() {
        translate([0,0,12]) {
            pedestal(text);
        }
        // push the mlp into the pedestal, for stability
        translate([0,0,-10]) {
            rotate([0, 90, -135])
            translate([-neuron_r, 0, -acrylic_thickness/2])
                // add tolerance for the cavity so that they two parts fit nicely
                mlp_3d(acrylic_thickness + clearance_medium);
        }
    }
}
