//
// 2dfillet 
// GPLv2
// (c) 2014 TakeItAndRun
r_fillet=1;
// number of facets of the fillet
fn_fillet=16;
// number of segments of the sphere(circle) used to expand shapes
fn_mink=16;
// thichness of shell created around shapes
dr=.005;
// When doing a minkowski() with an object of zero dimension no expanded shape / shell is contstracted at all. Therefore set the radius of the minkowski_shpere(circle) to a very small number.
r_mink_sphere_min=0.00001;

fillet_display(1){circle(2,$fn=32);square([1,10],true);}

module fillet_display(r_fillet=r_fillet,fn_fillet=fn_fillet){
	fillet(r_fillet,fn_fillet){children(0);children(1);}
	translate([0,0,0.01])color("red")render()children(0);
	translate([0,0,0.01])color("green")render()children(1);
}

// fillet between two child shapes
module fillet(r_fillet=r_fillet,fn_fillet=fn_fillet){
	for(a=[0:fn_fillet-1]){
		hull(){
			strip(r_fillet,a/fn_fillet){children(0);children(1);}
			strip(r_fillet,(a+1)/fn_fillet){children(0);children(1);}
		}
	}
}

// intersecton of shells a fraction of angle along the fillet
module strip(r=r_fillet,a=0){
	inter_shell(r*(1-cos(a*90)),r*(1-sin(a*90))){children(0);children(1);}
}

// intersection of shells around the two child shapes
module inter_shell(r1=r_fillet,r2=0){
	intersection(){
	shell()expand(r=r1)children(0);
	shell()expand(r=r2)children(1);
	}
}

// create a shell around the child shape
module shell(r=dr){
	difference(){
		expand(r=r)children();
		children();
	}
}

// expand a child shape in all directions by r
module expand(r=1){
	minkowski(){
		children();
		mink_sphere_2d(r);
	}
}

// area(in 2d) to expand/grow a shape by r into all directions
// (set the number of faces of this sphere (fn_mink) very small to save computation time)
module mink_sphere_2d(r=1,fn_mink=fn_mink){
	circle((r==0)?r_mink_sphere_min:r,$fn=fn_mink);
}