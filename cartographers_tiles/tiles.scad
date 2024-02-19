include <../shared/common.scad>

$fn = 100;

// ----------------------------------------------------------------------------
// MEASUREMENTS

// mm edge length of a square (default: 9.4)
edge_length = 9.4;    // [0.1:0.1:50]

// ----------------------------------------------------------------------------
// PARAMETERS

// tile set
tile_set = "cartographers";      // ["cartographers", "cartographers_heroes"]

// z-height of tiles
z_height = 4.0;     // [0.2:0.1:10.0]

// outline thickness (up to tiles being solid)
outline_t = 1.5;   // [0.1:0.1:25]

// width of bridges for joining disconnected sections
bridge_t = 2.5;     // [0.0:0.1:10]

// rounding radius for joining squares that touch diagonally
closing_r = 2.5;    // [0.0:0.1:10]

// ----------------------------------------------------------------------------
// PARTS

// positions children one square over towards +x
module next(n=1) {
    translate([n * edge_length, 0]) {
        children();
    }
}

// places a square, and positions children one square towards +x
module square_next() {
    if ($children <= 1) {
        square(edge_length, center=true);
        next() {
            children();
        }
    } else if ($children == 2) {
        children(0);
        next() {
            children(1);
        }
    }
}

// 90° rotation around z-axis
module rot(n=1) {
    rotate([0, 0, n*90]) {
        children();
    }
}

// thin bridge to join disconnected sections
module bridge(n=1) {
    square([n * edge_length, bridge_t], center=true);
}

// removes scaled down first child from itself, optionally from a second child too
module hollow_out(closing_r=0) {
    difference() {
        closing(closing_r) {
            children(0);

            // any extra geometry (bridges)
            if ($children == 2) {
                children(1);
            }
        }
        offset(-outline_t) {
            children(0);
        }
    }
}

module timber_grove_a() {
    hollow_out() {
        for (i = [0, 1]) {
            rot(i)
            square_next()
            square_next();
        }
    }
    next(3) children();
}

module timber_grove_b() {
    hollow_out(closing_r/2) {
        square_next()
        next()
        rot()
        square_next()
        rot()
        square_next()
        next()
        square_next();

        translate([edge_length, edge_length/2]) {
            bridge();
        }
    }
    next(4) children();
}

module frontier_dwelling() {
    hollow_out() {
        next()
        rot()
        square_next()
        square_next() {
            for (i = [1, -1]) {
                rot(i)
                square_next()
                square_next();
            }
        }
    }
    next(4) children();
}

module woodland_crossroads() {
    hollow_out() {
        next()
        rot()
        next()
        for (i = [1, 2, 3, 4]) {
            rot(i)
            square_next()
            square_next();
        }
    }
    next(4) children();
}

module mangrove_swamp() {
    hollow_out() {
        rot()
        square_next()
        rot(-1)
        square_next()
        square_next()
        rot(-1)
        square_next()
        square_next();
    }
    next(4) children();
}

module pasture_a() {
    hollow_out(closing_r/2) {
        square_next()
        next()
        square_next();

        translate([edge_length, 0]) {
            bridge();
        }
    }
    next(4) children();
}

module pasture_b() {
    hollow_out() {
        square_next()
        rot()
        square_next()
        rot(3)
        square_next()
        square_next();
    }
    next(4) children();
}

module coastal_encampment() {
    hollow_out() {
        rot()
        square_next()
        rot(3)
        square_next()
        square_next()
        square_next();
    }
    next(4) children();
}

module wildwood_garden() {
    hollow_out(closing_r) {
        rot()
        square_next()
        rot(3)
        next()
        square_next()
        square_next();
    }
    next(2) children();
}

module settlement_a() {
    hollow_out() {
        rot()
        square_next()
        square_next();
    }
    next(2) children();
}

module settlement_b() {
    hollow_out() {
        square_next()
        rot()
        square_next()
        rot(3)
        square_next()
        rot()
        square_next()
        square_next();
    }
    next(4) children();
}

module kethras_gates() {
    hollow_out() {
        square_next();
    }
    next(2) children();
}

module lagoon_a() {
    hollow_out(closing_r) {
        square_next()
        rot()
        next()
        square_next();
    }
    next(3) children();
}

module lagoon_b() {
    hollow_out() {
        next()
        rot()
        square_next() {
            for (i = [1, 3]) {
                rot(i)
                square_next()
                square_next();
            }
        }
    }
    next(4) children();
}

module hillside_terrace() {
    hollow_out() {
        square_next()
        rot()
        square_next()
        rot()
        square_next()
        square_next();
    }
    next(3) children();
}

module dragon_inferno() {
    hollow_out() {
        rot()
        square_next()
        rot(-1)
        square_next()
        square_next()
        rot()
        square_next()
        square_next();
    }
    next(4) children();
}

module gorgon_gaze() {
    hollow_out(closing_r) {
        square_next()
        next()
        rot()
        square_next()
        rot()
        next()
        square_next();
    }
    next(4) children();
}

module treetop_village() {
    hollow_out() {
        square_next()
        square_next()
        rot()
        square_next()
        rot(-1)
        square_next()
        square_next();
    }
    next(5) children();
}
module farmland_a() {
    settlement_a() children();
}
module farmland_b() {
    woodland_crossroads() children();
}
module forgotten_forest_a() {
    lagoon_a() children();
}
module forgotten_forest_b() {
    pasture_b() children();
}
module orchard() {
    coastal_encampment() children();
}
module hamlet_a() {
    timber_grove_a() children();
}
module hamlet_b() {
    hollow_out() {
        square_next()
        rot()
        square_next()
        rot()
        square_next()
        rot(-1)
        square_next()
        square_next();
    }
    next(3) children();
}
module rift_lands() {
    kethras_gates() children();
}
module homestead() {
    lagoon_b() children();
}
module hinterland_stream() {
    hollow_out() {
        rot()
        square_next()
        square_next()
        rot(-1)
        square_next()
        square_next()
        square_next();
    }
    next(4) children();
}
module great_river_a() {
    hollow_out() {
        rot()
        square_next()
        square_next()
        square_next();
    }
    next(2) children();
}
module great_river_b() {
    settlement_b() children();
}
module marshlands() {
    frontier_dwelling() children();
}
module fishing_village() {
    hollow_out() {
        square_next()
        square_next()
        square_next()
        square_next();
    }
    next(5) children();
}
module bugbear_assault() {
    timber_grove_b() children();
}
module goblin_attack() {
    hollow_out(closing_r) {
        rot()
        square_next()
        rot(-1)
        next()
        rot()
        square_next()
        rot(-1)
        next()
        square_next();
    }
    next(4) children();
}
module gnoll_raid() {
    mangrove_swamp() children();
}

linear_extrude(z_height) {
    if (tile_set == "cartographers") {
        hinterland_stream()
        next(-2)
        rift_lands()
        great_river_b()
        marshlands()
        next(1)
        rot()
        fishing_village();

        rot()
        next(4)
        rot(-1)
        farmland_b()
        great_river_a()
        hamlet_b()
        next(2)
        orchard();

        rot()
        next(8)
        rot(-1)
        treetop_village()
        farmland_a()
        forgotten_forest_b()
        rot(-1)
        next(-1)
        goblin_attack()
        next(-1)
        rot(1)
        next(-2)
        forgotten_forest_a();

        rot()
        next(11)
        rot(-1)
        hamlet_a()
        homestead()
        bugbear_assault()
        gnoll_raid();
    } else if (tile_set == "cartographers_heroes") {
        dragon_inferno()
        settlement_b()
        frontier_dwelling()
        woodland_crossroads();

        rot()
        next(3)
        rot(-1)
        lagoon_a()
        lagoon_b()
        rot()
        next()
        rot(-1)
        pasture_a()
        kethras_gates()
        rot(-1)
        settlement_a();

        rot()
        next(6)
        rot(-1)
        pasture_b()
        mangrove_swamp()
        timber_grove_a()
        hillside_terrace();

        rot()
        next(9)
        rot(-1)
        timber_grove_b()
        gorgon_gaze()
        coastal_encampment()
        wildwood_garden();
    }
}