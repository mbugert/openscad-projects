// Wii (RVL-001) friction-fit memory card slot cover

/* [Slots] */
// Distance from the console's outer surface (hinge side) to slot B's near wall
slotB_z0 = 9.55;
// Distance between the two slots' outer walls
slots_span = 23.2;
// Narrow width of a slot opening in the trim
slot_w = 8.3;
// Long side of a slot opening in the trim
slot_len = 36.0;
// Distance from the controller-port-door end to the near end of the slots
slot_x0 = 18.8;

/* [Plug] */
// Card width (along X). Real card ~35.6; less = more slack against x errors
plug_w = 35.9;   // 35.2 loose; 36.1 too tight; 35.7 left ~0.2 play -> 35.9
// Card thickness (along Z).
plug_t = 7.5;    // 7.0 had ~1.0 total play; +0.9 was too tight -> +0.5
// Plug length, measured from the cover's inner face
plug_len = 16;   // 12 only reached ~0.4 past the connector tongue tip (11.3 from bezel)
// Lead-in chamfer at the plug tip
tip_chamfer = 0.5;
// Edge radius on the card's bottom-half side
r_bottom = 2.8;
// Edge radius on the card's lid side
r_lid = 0.5;
// Shrink the connector mouth cross-section by this much on every side
mouth_shrink = 0.2;

/* [Cover outline] */
// Length along the console (64.32 + 0.65 so both end gaps are ~0.35)
cover_len = 64.97;
// Hinge-side edge (0 - 0.35: gap 0.7 like the original door)
cover_z_min = -0.35;
// Far edge (44 - 0.65: flush with the console's flat face)
cover_z_max = 43.35;
// Plate thickness
plate_t = 2.1;
// Radius of the two long outer edges of the visible face
edge_r = 1.0;

/* [Lip] */
// Lip thickness (along Z), flush with the far edge
lip_t = 1.36;   // was 1.56: lip bound over the last ~1 mm of insertion; 1.16 too thin
// Lip height below the plate's inner face
lip_h = 1.9;
// Notch in the lip: start along X, width, depth into the lip from the far edge,
// height from the lip's free end, inner corner radius
notch_x0 = 25.36;
notch_w = 13.6;
notch_depth = 0.75;
notch_h = 1.2;
notch_r = 0.3;

/* [Hidden] */
$fn = 48;
plate_inner_y = -plate_t;
eps = 0.01;

slotB_zc = slotB_z0 + slot_w/2;
slotA_zc = slotB_z0 + slots_span - slot_w/2;
slot_xc = slot_x0 + slot_len/2;

// Card connector mouth: 22.3 wide at the bottom-half side, with 45-degree
// chamfers to 18.0 on the lid side; spans 1.55..6.0 above the bottom face (of 7.0); 13.5 deep.
mouth_depth = 13.5;

// Cross-section of plate + lip in the (Y, Z) plane, extruded along X.
module cover_2d() {
    // plate with rounded outer long edges
    hull() {
        translate([-plate_t, cover_z_min]) {
            square([plate_t - edge_r, cover_z_max - cover_z_min]);
        }
        for (zc = [cover_z_min + edge_r, cover_z_max - edge_r]) {
            translate([-edge_r, zc]) circle(r = edge_r);
        }
    }
    // lip on the far side
    translate([-plate_t - lip_h, cover_z_max - lip_t]) {
        square([lip_h + eps, lip_t]);
    }
}

// Notch cross-section in the (X, Z) plane, rounded inner corners.
module notch_2d() {
    z_in = cover_z_max - notch_depth;
    hull() {
        for (x = [notch_x0 + notch_r, notch_x0 + notch_w - notch_r]) {
            translate([x, z_in + notch_r]) {
                circle(r = notch_r, $fn = 24);
            }
        }
        translate([notch_x0, z_in + notch_r]) {
            square([notch_w, notch_depth]);
        }
    }
}

module cover_base() {
    difference() {
        // (Y, Z) profile extruded along +X
        rotate([90, 0, 90]) {
            linear_extrude(cover_len) {
                cover_2d();
            }
        }
        // notch: (X, Z) profile extruded along -Y from the lip's free end
        translate([0, -plate_t - lip_h - 1, 0]) rotate([-90, 0, 0]) {
            mirror([0, 1, 0]) {
                linear_extrude(notch_h + 1) {
                    notch_2d();
                }
            }
        }
    }
}

// 2D card cross-section in local (u = width, v = thickness) coordinates,
// centred; v<0 is the bottom-half side (big radius), v>0 the lid side.
module card_profile(w, t) {
    hull() {
        for (su = [-1, 1]) {
            translate([su * (w/2 - r_bottom), -t/2 + r_bottom]) {
                circle(r = r_bottom);
            }
            translate([su * (w/2 - r_lid), t/2 - r_lid]) {
                circle(r = r_lid);
            }
        }
    }
}

module mouth_profile(t) {
    // v measured from the bottom face (-t/2)
    v0 = -t/2 + 1.55; v1 = -t/2 + 3.8; v2 = -t/2 + 6.0;
    polygon([[-11.15, v0], [11.15, v0], [11.15, v1], [9.0, v2],
             [-9.0, v2], [-11.15, v1]]);
}

module plug() {
    body_len = plug_len - tip_chamfer;
    difference() {
        union() {
            linear_extrude(body_len) card_profile(plug_w, plug_t);
            // chamfered tip
            hull() {
                translate([0, 0, body_len - eps]) {
                    linear_extrude(eps) {
                        card_profile(plug_w, plug_t);
                    }
                }
                translate([0, 0, plug_len - eps]) {
                    linear_extrude(eps) {
                        card_profile(plug_w - 2*tip_chamfer, plug_t - 2*tip_chamfer);
                    }
                }
            }
        }
        d = min(mouth_depth, plug_len - 2);
        translate([0, 0, plug_len - d]) {
            linear_extrude(d + 1) {
                offset(delta = -mouth_shrink) {
                    mouth_profile(plug_t);
                }
            }
        }
    }
}

module plug_pos(zc) {
    translate([slot_xc, plate_inner_y + eps, zc]) {
        rotate([90, 0, 0]) {
            children();
        }
    }
}

module cover() {
    rotate([-90, 0, 0]) {
        cover_base();
        plug_pos(slotB_zc) {
            plug();
        }
        plug_pos(slotA_zc) {
            plug();
        }
    }
}

cover();
