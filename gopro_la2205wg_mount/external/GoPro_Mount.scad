$fa = 2;
$fs = 0.25;
Extra_Mount_Depth = 3;

module nut_hole()
{
	rotate([0, 90, 0]) // (Un)comment to rotate nut hole
	rotate([90, 0, 0])
		for(i = [0:(360 / 3):359])
		{
			rotate([0, 0, i])
				cube([4.6765, 8.1, 5], center = true);
		}
}

module flap(Width)
{
	concave_rounding_r = 3;

	module temporary_base() {
		translate([7.5+Extra_Mount_Depth, -7.5 - concave_rounding_r]) {
			square([concave_rounding_r, 15 + 2*concave_rounding_r]);
		}
	}

	rotate([90, 0, 0]) {
		linear_extrude(Width) {
			difference() {
				offset(-concave_rounding_r)
				offset(concave_rounding_r)
				union() {
					// add a temporary base below, then use offset to create concave corners
					temporary_base();
					circle(d=15);
					translate([0, -7.5]) {
						square([7.5 + Extra_Mount_Depth, 15]);
					}
				}
				circle(d=6);

				// remove the temporary base again after having created the concave corners
				temporary_base();
			}
		}
	}
}

module mount2()
{
	union()
	{

		translate([0, 4, 0])
		flap(3);

		translate([0, 10.5, 0])
		flap(3);
	}
}

module mount3()
{
	union()
	{
		difference()
		{
			translate([0, (-2.5), 0])
				flap(8);

			translate([0, (-8.5), 0])
				nut_hole();
		}

		mount2();
	}
}

translate([0, 0, 10.5])
	rotate([0, 90, 0])
		mount3();
