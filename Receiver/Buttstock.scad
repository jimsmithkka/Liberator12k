use <../Meta/Manifold.scad>;
use <../Meta/Units.scad>;
use <../Meta/Debug.scad>;
use <../Meta/Resolution.scad>;
use <../Meta/RenderIf.scad>;

use <../Shapes/Chamfer.scad>;

use <../Vitamins/Nuts And Bolts.scad>;
use <../Vitamins/Nuts and Bolts/BoltSpec.scad>;

use <Receiver.scad>;

/* [What to Render] */

// Assembly is not for printing.
_RENDER = "StockAssembly"; // ["StockAssembly", "Stock", "Buttpad"]
_SHOW_BUTTPAD_BOLT = true;
_SHOW_STOCK = true;
_SHOW_BUTTPAD_PLATE = true;
_SHOW_BUTTPAD = true;

/* [Assembly Transparency] */
_ALPHA_STOCK = 1;
_ALPHA_BUTTPAD_PLATE = 1;
_ALPHA_BUTTPAD = 1;

_DEBUG_ASSEMBLY = false;



BUTTPAD_BOLT = "1/4\"-20"; // ["M6", "1/4\"-20"]
BUTTPAD_BOLT_CLEARANCE = 0.015;

$fs = UnitsFs()*0.25;

function ButtpadBolt() = BoltSpec(BUTTPAD_BOLT);
assert(ButtpadBolt(), "ButtpadBolt() is undefined. Unknown BUTTPAD_BOLT?");

function StockLength() = 6;
function ButtpadSleeveLength() = 1;
function ButtpadLength() = 2;
function ButtpadWall() = 0.1875;
function ButtpadX() = -(ReceiverLength()+ReceiverBackLength()+StockLength()+1.5);

module ButtpadBolt(debug=false, cutter=false, teardrop=true, clearance=0.01, teardropAngle=0) {
  clear = cutter ? clearance : 0;

  color("Silver") RenderIf(!cutter) DebugHalf(enabled=debug)
  translate([ButtpadX()-1.5, 0, -0.25])
  rotate([0,-90,0])
  NutAndBolt(bolt=ButtpadBolt(),
             boltLength=3,
             head="flat", capHeightExtra=(cutter?ButtpadLength():0),
             nut="heatset", nutHeightExtra=(cutter?1:0), capOrientation=true,
             clearance=clear);
}

module Stock(length=StockLength(), doRender=true, debug=false, alpha=1) {
  color("Chocolate", alpha=alpha)
  RenderIf(doRender)
  difference() {
    translate([-(ReceiverLength()+ReceiverBackLength()),0,0])
    union() {
    
      ReceiverSegment(length=length,
                    chamferFront=false, chamferBack=false);
      
      translate([-length,0,0])
      hull() {
        ReceiverSegment(length=1-0.25,
                        chamferFront=false, chamferBack=false);
        
        translate([-1,0,0])
        scale([1,1.1,1.1])
        mirror([1,0,0])
        ReceiverSegment(length=ManifoldGap(),
                        chamferFront=false, chamferBack=false);
        
        translate([-1,-0.5,-(ReceiverOR()+1.5)])
        cube([ManifoldGap(),1,ReceiverOR()+1.5]);
        
      }
    }
    
    // Slot
    translate([-(ReceiverLength()+ReceiverBackLength()),0,0])
    translate([-length,-0.75/2, -2])
    cube([length, 0.75, 2]);
    
    // Center Hole
    translate([-(ReceiverLength()+ReceiverBackLength()),0,0])
    rotate([0,-90,0])
    cylinder(r=0.75, h=length, $fn=80);
      
    // Alignment tab
    translate([-StockLength(),0,0])
    translate([-length-0.25,-(0.5+0.02)/2,-ReceiverOR()-0.25-0.01])
    ChamferedCube([0.5+0.02,0.5+0.02,ReceiverOD()+0.02], r=1/16,
                  teardropXYZ=[false,true,true],
                  teardropTopXYZ=[false,true,true],
                  teardropFlip=[false,true,true]);
    
    ReceiverRods(nutType="none", headType="none", cutter=true);
    
    ButtpadBolt(cutter=true);
  }
}

module Buttpad(doRender=true, debug=false, alpha=1) {
  receiverRadius=ReceiverOR();
  outsideRadius = receiverRadius+ButtpadWall();
  chamferRadius = 1/16;
  length = 4;
  base = 0.375;
  baseRadius = 9/16;
  spacerDepth=1.5;
  baseHeight = ButtpadLength();
  ribDepth=0.1875;

  color("Tan", alpha) RenderIf(doRender) DebugHalf(enabled=debug)
  difference() {

    translate([ButtpadX(),0,0])
    union() {
      
      // Stock and extension hull
      hull() {

        // Foot of the stock
        translate([-baseHeight,0,-0.5])
        rotate([0,90,0])
        for (L = [0,1]) translate([(length*L)-(outsideRadius/2),0,0])
        ChamferedCylinder(r1=baseRadius, r2=chamferRadius,
                           h=base,
                           $fn=Resolution(20,50));
        scale([1,1.1,1.1])
        mirror([1,0,0])
        ReceiverSegment(length=0.5,
                        chamferFront=false, chamferBack=false);
        
        translate([0,-0.5,-(ReceiverOR()+1.5)])
        cube([0.5,1,ReceiverOR()+1.5]);
        
      }
      
      // Alignment tab
      translate([0.25,-0.5/2,-ReceiverOR()-0.25])
      ChamferedCube([0.5,0.5,ReceiverOD()], r=1/16,
                  teardropFlip=[false,true,true]);
    }

    // Gripping Ridges
    translate([ButtpadX(),0,-0.5])
    translate([-baseHeight,0,0])
    rotate([0,90,0])
    for (M = [0,1]) mirror([0,M,0])
    for (X = [0:baseRadius:length-(baseRadius/2)])
    translate([X-(baseRadius/2),
               baseRadius+(baseRadius/5),
               -ManifoldGap()])
    cylinder(r1=baseRadius/2, r2=0, h=base);
    
    ButtpadBolt(cutter=true);
    
    translate([ButtpadX()+0.5,0,0])
    ReceiverRodIterator()
    cylinder(r=NutHexRadius(ReceiverRod(), 0.02), h=0.375, $fn=20);
  }
}


module Buttpad_print() {
  rotate([0,-90,0]) translate([StockLength()+ReceiverLength()+ButtpadLength()+0.5,0,0])
  Buttpad();
}

module StockAssembly() {
  if (_SHOW_BUTTPAD_BOLT)
  ButtpadBolt();
  
  if (_SHOW_STOCK)
  Stock(alpha=_ALPHA_STOCK);
  
  if (_SHOW_BUTTPAD)
  Buttpad(alpha=_ALPHA_BUTTPAD);
}

if (_RENDER == "StockAssembly") {
  ReceiverAssembly();
  StockAssembly();
}

scale(25.4) {

  if (_RENDER == "Stock")
  Stock_print();
  
  if (_RENDER == "Buttpad")
  Buttpad_print();
}
