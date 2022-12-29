// Author: Russell Stout
// Version 1.4
// https://www.thingiverse.com/thing:2875215

// Show OpenSCAD version in the console
echo(version=version());

// ***********************************************
// ###############################################
// ***********************************************

// Feel free to edit below this section

// ***********************************************
// ###############################################
// ***********************************************

// Height of the socket. Consider adding a few extra mm so the socket fits easily when you are using "wallWidthAboveTools"
socketHeight = 90; // Deep sockets

// Size of the text
textSize = 5;
// Gap above and below the text
textPaddingTopAndBottom = 1;
// Height of the extruded text
textHeight = 0.6;
// Extrude or emboss text. Options are "emboss" and "engrave"
textPosition = "emboss";
// textPosition = "engrave";

// Wall width between and above sockets
wallWidthBetweenTools = 2;
// Wall size above sockets. Set to 0 for no wall above
wallWidthAboveTools = 2;
// Wall behind the largest socket to the "floor"
wallWidthBehindTools = 2;
// Extra wall width added to either end of the block
wallWidthExtraOnEnds = 1;

// Enter diameters of the socket cut outs as they appear on the block. Add as many or as few as you'd like; the size of the print will automatically adjust
socketDiameters = [30,25,27,20,15];
// Add the label text for each entry above (there must be an entry for each socket). Text must have have dummy entries to match the diameter array
socketLabels = ["13/16","5/8","1/2","3/8","1/4"];
// OPTIONAL: If this variable is enabled, the heights of each individual socket can be customized. Also, defining the height of each socket is not necessary; any socket height not defined here will default to the height specified above
socketHeightsCustom = [90,90,80,60,42];
// socketHeightsCustom = [35, 40, 45];

// Extra clearance is required to make to socket slip in nicely. The amount of tolerance required varies on the size of socket. Base clearance applied to each hole
socketClearanceOffset = 0.4;
// Percent of diameter extra clearance (e.g. 0.01 = 1%)
socketClearanceGain = 0.01;

// ***********************************************
// ###############################################
// ***********************************************

// You should not need to edit below this section

// ***********************************************
// ###############################################
// ***********************************************

// Size of the text area
textAreaThickness = textSize + (textPaddingTopAndBottom * 2);

// Recursive function
// calculate the maximum socket size in this row
function largestSocketSize(array, index = 0) = (index < len(array) - 1) 
    ? max(array[index], largestSocketSize(array, index + 1)) 
    : array[index];

// Recursive sum to calculate accumulative offset
function sumAccumulativeOffset(array, index, gap) = index == 0 
    ? array[index] 
    : array[index] + sumAccumulativeOffset(array, index - 1, gap) + gap;

// Overall size of the model
largestSocketDiameter = largestSocketSize(socketDiameters);
xSize = sumAccumulativeOffset(socketDiameters, len(socketDiameters)-1, wallWidthBetweenTools) + wallWidthBetweenTools + (wallWidthExtraOnEnds * 3);
ySize = socketHeight + textAreaThickness + wallWidthAboveTools;
zSize = (largestSocketDiameter / 2) + wallWidthBehindTools; // Length of the block

// Calculate where to start to center sockets on the block
socketsPerRow = len(socketDiameters);
yStart = wallWidthBetweenTools; 
xStart = (xSize + wallWidthBetweenTools - sumAccumulativeOffset(socketDiameters, socketsPerRow - 1, wallWidthBetweenTools)) / 2;

module solidBlock() {
    cube ([xSize, ySize, zSize]);
}

module textLabels(textHeightNew = textHeight) {
    for (yIndex = [0:socketsPerRow - 1]) {
        diameter = socketDiameters[yIndex];
        xPos = sumAccumulativeOffset(socketDiameters, yIndex, wallWidthBetweenTools) - (0.5 * diameter) + xStart;
        translate ([xPos, 0, 0]) color ([0, 1, 1]) linear_extrude (height = textHeightNew) text (socketLabels[yIndex], size = textSize, valign = "baseline", halign = "center", font = "Liberation Sans");
    }
}

module socketHoles() {
    for (yIndex = [0:socketsPerRow - 1]) {
        socketClearance = (socketDiameters[yIndex] * socketClearanceGain) + socketClearanceOffset;
        diameter = socketDiameters[yIndex] + socketClearance;
        xPos = sumAccumulativeOffset(socketDiameters, yIndex, wallWidthBetweenTools) - (0.5 * diameter) + xStart;
        height = socketHeightsCustom[yIndex] ? socketHeightsCustom[yIndex] : socketHeight;
        translate ([xPos, 0, 0]) rotate([270, 0, 0]) cylinder (h = height, d = diameter, center = false);
    }
}

difference () {

    union () {
        // **************************
        // Draw the block that will have the sockets cut from
        // **************************
        solidBlock();

        // **************************
        // Add EMBOSSED text to the block
        // **************************
        if( textPosition == "emboss" ) {
            translate([0, textPaddingTopAndBottom, zSize]) {
                textLabels();
            }
        }
    }

    // **************************
    // Remove ENGRAVED text from the block
    // **************************
    if( textPosition == "engrave" ) {
        translate([0, textPaddingTopAndBottom, (zSize - textHeight)]) {
            // Add some extra height to extrude text past block top surface
            textLabels(textHeight + 0.1);
        } 
    }

    // **************************
    // Cut out the sockets
    // **************************
    translate([0,textAreaThickness,zSize]) {
        // Loop through all the specified sockets
        socketHoles();
    }
}
