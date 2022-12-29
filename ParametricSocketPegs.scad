// https://www.thingiverse.com/thing:892317

/* [Hidden] */
$fa = 2;
$fs = 1;

/* [Original Parameters]
//Drive size
drive_size = 3; // [2:1/4,3:3/8,4:1/2]

//The center to center spacing of recepticles
spacing = 30;
//how many rows of sockets?
rows = 3;
//how many columns of sockets?
cols = 2;
//adjust this up if the sockets fit too tight
clearance = 0.3;
//list the socket labels.  Note: right now the customizer only accepts numbers.  sorry :(
txt = ["10","8","7","6","5","4"];
 
//Add a tab with text label below sockets (empty for no tab).
label_text = "Metric Hex Bits";

//END PARAMETERS//
/* [Hidden] */

clearance = 0.3;
nib_text_size_multiplier = 4;

/* [Metric Half Inch Drive Hex] */
drive_size = 4;
spacing = 30;
rows = 3;
cols = 1;
txt = ["17", "14", "12"];
label_text = "";

/* [Metric Three Eigths Drive Hex]
drive_size = 3;
spacing = 30;
rows = 3;
cols = 2;
txt = ["10","8","7","6","5","4"];
label_text = "Metric Hex Bits";
/*


/* [SAE Three Eigths Drive Hex]
drive_size = 3;
spacing = 30;
rows = 3;
cols = 2;
txt = ["3/8","5/16","1/4","7/32","3/16","5/32"];
label_text = "SAE Hex Bits";
nib_text_size_multiplier = 3;
*/

nib_size = drive_size/8*25.4-clearance;
nib_height = 1.2*nib_size;

basethickness = 3;
letter_depth = 0.6;

label_size = 2*4*drive_size/3;

difference() {
  if (label_text != ""){ 
    translate([0,-label_size,0])
    rRect([spacing*(rows),spacing*(cols)+label_size,basethickness],3);
  } else {
    rRect([spacing*(rows),spacing*(cols),basethickness],3);
  }
  translate([spacing*(rows)/2,-4*drive_size/3,basethickness-letter_depth/2])
  linear_extrude(letter_depth+0.1)
  text(label_text,size=4*drive_size/3,font= "Arial:style=Black",valign="center",
            halign="center");
}

for (r = [0.5:1:rows]) {
  for (c = [0.5:1:cols]) {
    difference() {
      translate([r*spacing,c*spacing,basethickness+nib_height/2])
        rRect([nib_size,nib_size,nib_height],drive_size,center = true);      
    }
    union() {
      translate([r*spacing,c*spacing,basethickness+nib_height])
        linear_extrude(letter_depth)
          text( str(txt[round((cols-1-(c-0.5))*rows+ (r-0.5))]),size=nib_text_size_multiplier*drive_size/3,font= "Arial:style=Black",valign="center",
            halign="center");
      }
  }
}


// rectangle with radiused cornerrs
// size - [x,y,z]
// r - radius
// center=false - center the object ar origin? (similar to cube)
module rRect(size, r, center = false)
{

  x = size[0];
  y = size[1];
  z = size[2];
  t = center?[-x/2,-y/2,-z/2]:[0,0,0];
  
  translate(t)
  linear_extrude(height=z)
        hull() {
            translate([r, r, 0])
                circle(r=r);
            translate([x-r, (r), 0])
                circle(r=r);
            translate([ r, y-r, 0])
                circle(r=r);
            translate([x-r, y-r, 0])
                circle(r=r);
        };
}


/*
linear_extrude(height=20)
text(str(7));
*/
