//$t=0.70;
//$t=0.75;
//$t=0.665;
//$t=0;
include <../../../../../Meta/Animation.scad>;
use <../../../../../Meta/Clearance.scad>;
use <../../../../../Meta/Debug.scad>;
use <../../../../../Meta/Manifold.scad>;
use <../../../../../Meta/Resolution.scad>;
use <../../../../../Meta/Units.scad>;
use <../../../../../Vitamins/Pipe.scad>;
use <../../../../../Vitamins/Rod.scad>;
use <../../../../../Vitamins/Nuts And Bolts.scad>;
use <../../../../../Vitamins/Double Shaft Collar.scad>;
use <../../../../../Components/Printable Shaft Collar.scad>;
use <../../../../../Components/Set Screw.scad>;
use <../../../../../Components/Semicircle.scad>;
use <../../../../../Components/Teardrop.scad>;
use <../../../../../Lower/Receiver Lugs.scad>;
use <../../../../../Lower/Lower.scad>;
use <../../../Reference.scad>;
use <../../../Frame.scad>;
use <../../Forend Slotted.scad>;
use <../../Forend.scad>;

DEFAULT_BARREL = Spec_TubingZeroPointSevenFive();
DEFAULT_BARREL = Spec_TubingOnePointOneTwoFive();
DEFAULT_LOCK_ROD  = Spec_RodOneQuarterInch();
DEFAULT_LATCH_BOLT = Spec_BoltM4();
DEFAULT_EXTRACTOR_GUIDE_ROD  = Spec_RodOneEighthInch();

function LatchWidth() = 0.75;
function LatchHeight() = 0.25;
function LatchSpringLength() = 0.875;
function LatchSpringOD() = 0.25;

function PivotLatchTravel() = 0.375;
function ForendPivotedLatchWall() = 0.25;

function BarrelLatchCollarLength() = 1;

function LatchSlotWidth() = 0.5;
function PivotLatchX() = ForendX()
                       + BarrelLatchCollarLength()
                       - PivotLatchTravel();

function PivotLatchZ(barrel=DEFAULT_BARREL) = -PipeOuterRadius(pipe=barrel)
                                                  - 0.25;

function LatchBoltZ(barrel=DEFAULT_BARREL) = PivotLatchZ(barrel);

function LatchBoltX() = PivotLatchX()
                      + PivotLatchTravel()
                      + (LatchSlotWidth()/2);

function LatchSpringX() = LatchBoltX()+PivotLatchTravel()+0.25;

function LatchLength() = LatchSpringX()-PivotLatchX()
                       + LatchSpringLength()
                       + ForendPivotedLatchWall();
                       
function ForendPivotedLatchLength() = (PivotLatchX()-ForendX())
                                    + LatchLength()
                                    + PivotLatchTravel();

function ForendPivotedX() = ForendPivotedLatchLength();

function BarrelPivotCollarLength() = 1;
function BarrelPivotCollarWall() = 0.3125;

function PivotAngle() = 30;
function PivotOffset() = 5.375;
function PivotRadius() = 0.375;
function BarrelPivotInterface() = 0.25;
function BarrelPivotX() = BreechFrontX()+PivotOffset();
function BarrelPivotZ() = -PipeOuterRadius(DEFAULT_BARREL);

function PivotedForendFrameLength() = 5.9;
function PivotedForendLength() = PivotedForendFrameLength()
                               - ForendPivotedLatchLength()
                               - 0.4;
                               
function ExtractorTravel()            = 0.5;

function ExtractorPusherPivotRadius() = 0.25;
function ExtractorPusherWall()        = 0.125;

function ExtractorJointRadius()       = 0.125;
function ExtractorJointWall()         = 0.1625;
function ExtractorJointSlop()         = 0.375;

function ExtractorPusherX() = ForendX()
                            + ForendPivotedX()
                            + PivotedForendLength()
                            - (ExtractorPusherPivotRadius()*2);

function ExtractorPusherZ() = ReceiverCenter();

function ExtractorSpringLength() = LatchSpringLength();
function ExtractorSpringOD() = LatchSpringOD();

module LatchSlot(barrel=DEFAULT_BARREL,
                 slotWidth=LatchSlotWidth(),
                 slotExtraLength=0,
                 clearance=0.005) {
  hull()
  for (X = [-slotExtraLength,PivotLatchTravel()])
  translate([LatchBoltX()+X,
             0,
             LatchBoltZ()+ManifoldGap()])
  mirror([0,0,1])
  linear_extrude(h=ReceiverCenter()+ManifoldGap(2))
  rotate(180)
  Teardrop(r=(slotWidth/2)+clearance, truncated=true);
  
  // Full-length slot
  translate([ForendX()-ManifoldGap(),
              -(slotWidth/2)-clearance,
              -ReceiverCenter()+0.125])
  mirror([0,0,1])
  cube([ForendPivotedLatchLength()+ManifoldGap(2),
        slotWidth+(clearance*2),
        1]);
};

module LatchBolt(boltSpec=DEFAULT_LATCH_BOLT,
                 length=UnitsMetric(25),
                 cutter=false) {
  
    translate([LatchBoltX(), 0, LatchBoltZ()+ManifoldGap()])
    rotate([180,0,0])
    NutAndBolt(bolt=boltSpec,
               boltLength = length, capHeightExtra=(cutter?1:0),
               nutBackset=UnitsMetric(1), nutHeightExtra=UnitsMetric(1.5),
               clearance = cutter);
}


module BarrelPivotInnerRace(pivotRadius=PivotRadius(),
                            clearance=0) {
      translate([BarrelPivotX(), 0, BarrelPivotZ()])
      rotate([90,0,0])
      cylinder(r=pivotRadius+clearance,
               h=3,
               center=true,
               $fn=Resolution(20,100));
}

module BarrelPivotOuterRace(barrelPipe=DEFAULT_BARREL,
                            clearance=0) {

      // TODO: Math this out so we don't pivot through the frame rods automagically.
      extra=1.0;
      
      translate([BarrelPivotX(), 0, BarrelPivotZ()])
      rotate([90,0,0])
      cylinder(r=PipeOuterRadius(barrelPipe,undef)+extra+clearance,
               h=3,
               center=true,
               $fn=Resolution(20,100));
}

module BarrelPivotCollarBolts(barrelPipe=DEFAULT_BARREL,
                              pivotRadius = PivotRadius(),
                              length=UnitsMetric(10),
                              angles=[0],
                              teardropAngle=90, cap=true,
                              clearance=0.005, cutter=false) {
  translate([BarrelPivotX() - pivotRadius - UnitsMetric(6),0,0])
  for (r = angles)
  rotate([180,0,0]) // Rotate to bottom
  rotate([r,0,0])   // Lean angle
  rotate([0,-90,0]) // Stand up on-end
  SetScrew(radius=PipeOuterRadius(barrelPipe),
            cap=cap, capHeightExtra=(cutter ? ReceiverCenter() : 0),
            length=length,
            teardrop=cutter, teardropAngle=teardropAngle,
            cutter=cutter);
}

module BarrelPivotCollar(barrelPipe=DEFAULT_BARREL,
                         pivotRadius = PivotRadius(),
                         height=BarrelPivotCollarLength(),
                         cutter=false, clearance=0.008, extend=0,
                         alpha=1) {
  clear = cutter ? clearance : 0;
  clear2 = clear*2;

  color("Yellow", alpha)
  render()
  difference() {
    intersection() {
      
      // Shaft collar
      translate([BarrelPivotX() - pivotRadius + BarrelPivotInterface(),0,0])
      rotate([0,-90,0])
      rotate(-90)
      PrintableShaftCollar(pipeSpec=barrelPipe, pipeClearance=PipeClearanceSnug(),
                           height=height+extend+clear2,
                           length=UnitsMetric(10),
                           setScrewLength=UnitsMetric(8),
                           screwOffsetZ=BarrelPivotInterface()+UnitsMetric(6),
                           teardropAngle=90,
                           wall=BarrelPivotCollarWall(), cutter=cutter);
      
      if (extend == 0)
      BarrelPivotOuterRace(barrelPipe=barrelPipe, cutter=true);
    }
    
    BarrelPivotInnerRace();
  }
}

module Pivot(factor=1,
             angle=PivotAngle(),
             pivotX=BarrelPivotX(),
             pivotZ=BarrelPivotZ()) {

  translate([pivotX,0,pivotZ])
  rotate([0,angle*factor,0])
  translate([-pivotX,0,-pivotZ])
  children();
}

module ForendPivotHull(steps=Resolution(PivotAngle()/4, PivotAngle()/2)) {
  pivotStep = 1/steps;
  
  render()
  union()
  for (i = [0:steps])
  hull() {
    if (i > 0)
    Pivot(factor=pivotStep*(i-1))
    children();
    
    Pivot(factor=pivotStep*i)
    children();
  }
}

module ForendPivoted(barrelPipe=DEFAULT_BARREL,
                     length=PivotedForendLength(),
                     wall=WallTee(),
                     $fn=40, alpha=1) {

  color("Orange", alpha)
  render()
  difference() {
    union() {
      translate([ForendPivotedX(),0,0])
      Forend(barrelSpec=barrelPipe, length=length);
      
      // Extractor pusher support
      intersection() {
        hull() {
          translate([ExtractorPusherX(),0,ExtractorPusherZ()])
          rotate([90,0,0])
          linear_extrude(height=1, center=true)
          Teardrop(r=ExtractorPusherPivotRadius()+ExtractorPusherWall(), truncated=false);
          
          translate([ExtractorPusherX(),-ReceiverOR(),ReceiverOR()])
          cube([0.5,ReceiverOD(),ManifoldGap()]);
        }
        
        // Make sure the pivot doesn't extend past the end of the forend
        translate([ForendX()+ForendPivotedX(),-ReceiverOR(),0])
        cube([length, ReceiverOD(), ReceiverLength()]);
      }
    }

    union() {
      
      // Extractor pusher pathway through the forend
      translate([ExtractorPusherX()-length-ExtractorPusherPivotRadius(),
                 -0.255,
                 0])
      cube([length, 0.51, ReceiverCenter()]);
      
      // Extractor pusher pivot on top of the forend
      translate([ExtractorPusherX(),0,ExtractorPusherZ()])
      rotate([90,0,0])
      linear_extrude(height=0.51, center=true) {
        
        // Pivotted section
        difference() {
          rotate(-45)
          semicircle(od=0.75*sqrt(2), angle=315, center=false);
          
          Teardrop(r=ExtractorPusherPivotRadius());
        }
      }

      difference() {
        ForendPivotHull()
        BarrelPivotCollar(cutter=true);
        
        BarrelPivotInnerRace(clearance=-0.01);
      }

      // Pivot collar installation tunnel
      // Note: back-pivoted so the collar is fully retained in normal operation
      Pivot(factor=1, angle=-5)
      BarrelPivotCollar(cutter=true, extend=length);
      
      BarrelPivotCollarBolts(length=ReceiverCenter(),cutter=true);
      
      
      ForendPivotHull() // These need a shortened barrel segment to look decent.
      translate([-BreechFrontX()+ForendX()+ForendPivotedX()-1,0])
      Barrel(barrel=barrelPipe, barrelLength=length+1.5);
    }
  }
}

module PivotLatch(barrel=DEFAULT_BARREL,
                        length=LatchLength(), width=LatchWidth(), height=LatchHeight(),
                        cutter=false, clearance=0.015, alpha=0.9) {
  clear  = Clearance(clearance, cutter);
  clear2 = clear*2;
       
  color("White", alpha)
  render()
  difference() {
    // Latch body
    translate([PivotLatchX()-clear,
               -(width/2)-clear,
               PivotLatchZ(barrel)+clear])
    mirror([0,0,1])
    cube([length+clear2+(cutter ? PivotLatchTravel()+ForendPivotedLatchWall() : 0),
          width+clear2,
          height+clear2]);
    
    if (cutter) {
      
      // Latch Spring Depressor (leave uncut)
      translate([LatchSpringX()+LatchSpringLength()-ManifoldGap(1),
                 -(LatchSpringOD()/2)+clear-ManifoldGap(1),
                 PivotLatchZ(barrel)+clear+ManifoldGap(1)])
      mirror([0,0,1])
      cube([PivotLatchTravel()+(ForendPivotedLatchWall()*2)+ManifoldGap(2),
            LatchSpringOD()-clear2+ManifoldGap(2),
            height+clear2+ManifoldGap(2)]);
    }
    
    if (!cutter) {
      LatchBolt(cutter=true);
      
      // Latch Spring Cutout
      translate([LatchSpringX()-ManifoldGap(1),
                 -(LatchSpringOD()/2)-ManifoldGap(1),
                 PivotLatchZ(barrel)+ManifoldGap(1)])
      mirror([0,0,1])
      cube([LatchSpringLength()+ForendPivotedLatchWall()+ManifoldGap(2),
            LatchSpringOD()+ManifoldGap(2),
            height+ManifoldGap(2)]);
      
      // Latch Bolt Cutout
      translate([LatchBoltX(),
                 0,
                 PivotLatchZ()+ManifoldGap()])
      mirror([0,0,1])
      cylinder(r=BoltRadius(bolt=DEFAULT_LATCH_BOLT, clearance=true),
               h=LatchHeight()+ManifoldGap(2), $fn=8);
      
      // Incline the tip
      translate([PivotLatchX()+(sin(15)*LatchHeight()),
                  -(LatchWidth()/2)-ManifoldGap(),
                  PivotLatchZ(barrel)+ManifoldGap(1)])
      rotate([0,180+25,0])
      cube([1, LatchWidth()+ManifoldGap(2), LatchHeight()*2]);
      
      // Bevel the fork
      translate([LatchSpringX()+LatchSpringLength(),0,PivotLatchZ()])
      scale([1,0.75,1])
      rotate(-45)
      mirror([0,0,1])
      cube([LatchWidth(),LatchWidth(),LatchHeight()+ManifoldGap(2)]);
    }
  }
}

module PivotLatchHandle(diameter=LatchSlotWidth()-0.015,
                        clearance=0.005,
                        $fn=30, alpha=1) {

  height = 0.5;
  zMin = -ReceiverCenter()-height;
  clear  = clearance;
  clear2 = clearance*2;

  color("DimGrey", alpha)
  render()
  difference() {
    union() {
      translate([LatchBoltX(),0,zMin+ManifoldGap()])
      cylinder(r=diameter/2, h=height+(ReceiverCenter()+PivotLatchZ())-LatchHeight());
      
      // Ambidextrous Index-finger Unlock Button
      hull()
      for (m = [0,1])
      mirror([0,m,0]) {

        // Finger interface
        translate([LowerMaxX()-LowerWallFront()-0.125,
                   (LowerMaxWidth()/2)+0.125,
                   zMin])
        rotate(-25)
        cube([0.25, 0.5, height]);
                   
        // Anchor hull to the latch bolt
        translate([LatchBoltX(), 0, zMin])
        cylinder(r=(diameter/2), h=height);
      }
      
      // Slot Key
      translate([ForendX()+BarrelLatchCollarLength()-0.125,
                  -(LatchSlotWidth()/2)+clear,
                  zMin])
      cube([PivotLatchTravel()+1,
            LatchSlotWidth()-clear2,
            height+0.125-clear]);
    }
    
    // Thumbhole? Less material, anyway.
    hull() {
      translate([LowerMaxX()+0.125,0, zMin-ManifoldGap()])
      cylinder(r=0.5,h=height+ManifoldGap(2));
      
      translate([ForendX(),0, zMin-ManifoldGap()])
      cylinder(r=0.375,h=height+ManifoldGap(2));
    }
    
    // Lower clearance
    translate([0,-(LowerMaxWidth()/2)-0.1, zMin-ManifoldGap()])
    cube([LowerMaxX()+clear+ManifoldGap(), LowerMaxWidth()+0.2, height+ManifoldGap(2)]);
    

    LatchBolt(cutter=true);
  }
}


module BarrelLatchCollarBolts(barrel=DEFAULT_BARREL,
                             length=UnitsMetric(14),
                             angles=[0],
                             teardropAngle=0, cap=true,
                             clearance=0.005, cutter=false) {
  translate([ForendX()+0.25,0,0])
  for (r = angles)
  rotate([180,0,0]) // Rotate to bottom
  rotate([r,0,0])   // Lean angle
  rotate([0,-90,0]) // Stand up on-end
  SetScrew(radius=PipeOuterRadius(barrel),
            cap=cap, capHeightExtra=(cutter ? ReceiverCenter() : 0),
            length=length, height=BarrelLatchCollarLength(),
            teardrop=cutter, teardropAngle=teardropAngle,
            cutter=cutter);
}

module BarrelLatchCollar(barrel=DEFAULT_BARREL,
                             wall=WallTee(),
                             length=UnitsMetric(30),
                             height=BarrelLatchCollarLength(),
                             clearance=0.005, cutter=false,
                             $fn=40, alpha=1) {

  radius = ReceiverOR() - clearance;
  
  color("Orange", alpha)
  render()
  difference() {
    union() {
      translate([ForendX(),0,0])
      hull() {
        
        // Extractor Support
        translate([0,-radius,0])
        cube([height,radius*2,ReceiverCenter()]);
        
        // Collar body
        rotate([0,90,0])
        cylinder(r=radius, h=height);
        
        // Latch Support
        translate([0,-radius,-ReceiverCenter()+clearance])
        cube([height,radius*2,0.25]);
      }
    }
    
    if (!cutter) {
      BarrelLatchCollarBolts(barrel=barrel, teardropAngle=-90, cutter=true);
      
      PivotLatch(barrel=barrel, cutter=true);
      
      Extractor(cutter=true);
      
      ExtractorGuide(cutter=true);
      
      Barrel(barrel=barrel, clearance=PipeClearanceSnug(), cutter=true);
    }

    // Cut an incline for the latch to ride on
    translate([ForendX()+height,
                -ReceiverOR(),
                PivotLatchZ(barrel) - (LatchHeight()*0.5)])
    rotate([0,35,0])
    mirror([0,0,1])
    cube([1, ReceiverOD(), 2]);
    
    // Cut the walls with a slight incline for loading
    translate([0,0,-PipeOuterRadius(pipe=barrel)])
    for (m=[0,1])
    mirror([0,m,0])
    rotate([-20,0,0])
    translate([ForendX()-ManifoldGap(),
                radius,
                PivotLatchZ(barrel)-ReceiverLength()])
    cube([height+ManifoldGap(2), radius, ReceiverLength()*2]);
  }
}

module ForendPivotedLatch(barrelPipe=DEFAULT_BARREL,
                       length=ForendPivotedLatchLength(),
                       wall=WallTee(),
                       $fn=Resolution(20,60), alpha=1) {

  color("Gold", alpha)
  render(convexity=4)
  difference() {
    Forend(barrelSpec=barrelPipe, length=length,
           scallops=true,
           clearFloor=true);
    
    // Barrel Slot
    translate([ForendX()-ManifoldGap(),0,0])
    rotate([0,90,0])
    linear_extrude(height=length+ManifoldGap(2))
    rotate(180)
    ForendSlotCutter2d(width=PipeOuterDiameter(pipe=barrelPipe, clearance=PipeClearanceLoose()));
    
    // Latching Collar Slot
    ForendPivotHull()
    scale([1.00,1.01,1.01])
    BarrelLatchCollar(cutter=true);
    
    PivotLatch(barrel=barrelPipe, cutter=true);
    
    LatchSlot(barrel=barrelPipe, extend=length);
  }
}







function ExtractorGuideBoltArray(barrelPipe=DEFAULT_BARREL) = [
  [BreechFrontX()+0.3125, 0.65, PipeOuterRadius(pipe=barrelPipe)+0.375,  UnitsMetric(30)],
  [ForendX()+2.75,        0.55, ReceiverCenter(), UnitsMetric(25)]
];

module ExtractorGuideBolts(barrelPipe=DEFAULT_BARREL,
                           boltSpec=Spec_BoltM3(),
                           cutter=false, teardrop=false, teardropAngle=0) {
  for (XYZL = ExtractorGuideBoltArray(barrelPipe=barrelPipe))
  translate([XYZL[0],XYZL[1],XYZL[2]])
  rotate([90,0,0])
  NutAndBolt(bolt=boltSpec,
             boltLength=XYZL[3], capHeightExtra=(cutter?1:0),
             nutBackset=UnitsMetric(1), nutHeightExtra=(cutter?1:0),
             clearance=cutter, teardrop=teardrop, teardropAngle=teardropAngle);
}

module ExtractorPusher(pivotAngle=PivotAngle(), pivotFactor=1,
                       width=0.5, barWidth=0.25,
                       clearance=0.005,
                       $fn=Resolution(12,30), alpha=1) {
 
  backPivotAngle = 0;
  forwardPivotAngle = 3.5;
  barLength = ExtractorPusherX()
            - ForendPivotedLatchLength()
            - ForendX()
            + 0.25;

  color("Gold", alpha)
  render()
  translate([ExtractorPusherX(), 0, ExtractorPusherZ()])
  rotate([0,(backPivotAngle*(1-pivotFactor))
            +((pivotAngle+forwardPivotAngle)*pivotFactor),0])
  mirror([1,0,0])
  rotate([90,0,0])
  linear_extrude(height=width, center=true)
  difference() {
    union() {
      
      // Bar
      translate([0,-barWidth/2])
      square([barLength,barWidth]);
      
      // Front clip (teardropped for strength)
      Teardrop(r=ExtractorPusherPivotRadius()+ExtractorPusherWall());
      
      // Joint
      hull() {
        for (X = [0,ExtractorJointSlop()])
        translate([barLength+X,0,0])
        rotate(180)
        Teardrop(r=ExtractorJointRadius()+ExtractorJointWall());
      }
    }
      
    // Front clip installation cutout
    rotate(240)
    semicircle(od=(ExtractorPusherPivotRadius()+ExtractorPusherWall())*3, angle=120, center=false);
    
    // Front clip pivot hole
    circle(r=ExtractorPusherPivotRadius()+clearance, center=true);
      
    // Joint hole
    hull()
    for (X = [0,ExtractorJointSlop()])
    translate([barLength+X,0,0])
    circle(r=ExtractorJointRadius()+clearance);
  }
}

module ExtractorGuide(barrelPipe=DEFAULT_BARREL,
                      guideRod=DEFAULT_EXTRACTOR_GUIDE_ROD,
                      sides=[0,1],
                      cutter=false, clearance=0.02,
                      alpha=1) {
  guideWidth=0.1875;
  guideHeight=0.5;
  guideBlockLength = 1.25;
  guideLength = ForendBreechGap()
              + BarrelLatchCollarLength()
              + ExtractorTravel()
              + guideBlockLength
              + 0.25;
  
  extractorGuideOffsetY=0.5625+ManifoldGap();
  extractorGuideOffsetZ=0.125;

  clear  = Clearance(clearance, cutter);
  clear2 = clear*2;
                        
  pivotBoltXYZL = ExtractorGuideBoltArray(barrelPipe=barrelPipe)[0];

  color("DimGrey", alpha)
  render()
  difference() {
    for (m = sides) mirror([0,m,0])
    translate([BreechFrontX()+ManifoldGap(),
               extractorGuideOffsetY,
               PipeOuterRadius(pipe=barrelPipe)])
    translate([0,clear,-clear])
    mirror([0,1,0]) {
      
      // Guide
      translate([0,0,extractorGuideOffsetZ])
      cube([guideLength+clear, guideWidth+clear2, guideHeight+clear2]);
      
      // Guide Block (center chunk)
      hull() {
        translate([guideLength,0,0])
        mirror([1,0,0])
        cube([guideBlockLength,
              extractorGuideOffsetY-ManifoldGap(),
              guideHeight+extractorGuideOffsetZ]);
        
        translate([guideLength,
                   extractorGuideOffsetY-ManifoldGap(),
                   -PipeWall(pipe=barrelPipe)])
        mirror([1,0,0])
        mirror([0,1,0])
        cube([ForendBreechGap()-ManifoldGap(2),
              0.25,
              guideHeight]);
        
      }
    }
    
    if (!cutter) {
      ExtractorGuideBolts(cutter=true, teardrop=false);
      Barrel(barrelPipe=barrelPipe);
      
      // Extractor pusher cutout
      difference() {
        translate([BreechFrontX()+guideLength+ManifoldGap(), -0.255, 0])
        mirror([1,0,0])
        cube([(ExtractorJointRadius()*3)+(ExtractorJointWall()*2)+ExtractorJointSlop(),
               0.51, ReceiverCenter()]);
        
        // Leave some meat for the joint to ride on
        rotate([90,0,0])
        cylinder(r=ExtractorJointRadius()+clearance, h=ReceiverOD(), center=true);
      }
    }
  }
}

*!translate([]) {
  ExtractorPusher(pivotFactor=0);
  ExtractorGuide();
}

module Extractor(barrelPipe=DEFAULT_BARREL, guideSides=[0,1],
                 cutter=false, clearance=0.005) {
                       
  clear  = Clearance(clearance, cutter);
  clear2 = clear*2;
  
  
  length = ForendBreechGap()
         + ExtractorTravel()
         + BarrelLatchCollarLength();
  extractorWidth=0.25;
  extractorHeight = 0.5;
  
  tabLength=0.5;
  tabWidth=0.25;
  tabThickness = 0.03125+0.01;
  
  color("Yellow")
  render()
  difference() {
    
    // Extractor holder body
    hull() {
      translate([BreechFrontX()+ManifoldGap(2),-(1.125/2)+ManifoldGap(),0.3125])
      cube([ForendBreechGap()-ManifoldGap(2),
            1.125-ManifoldGap(2),
            1.0]);
      
    }
    
    if (!cutter) {
      ExtractorGuide(cutter=true);
      
      ExtractorGuideBolts(cutter=true, teardrop=true, teardropAngle=0);
      
      // Extractor spring steel tab slot
      translate([BreechFrontX(),
                 0,
                 PipeInnerRadius(pipe=barrelPipe)])
      rotate([0,-45,0])
      translate([0,-(tabWidth/2)-ManifoldGap(),0])
      cube([tabLength, tabWidth+ManifoldGap(2), tabThickness]);
      
      Barrel(barrel=barrelPipe, clearance=PipeClearanceSnug());
    }
  }
}


module ForendPivotedAssembly() {
  
  ExtractorPusher(pivotFactor = Animate(ANIMATION_STEP_UNLOAD)
                              - Animate(ANIMATION_STEP_LOAD));
  
  // Pivot Latch
  translate([PivotLatchTravel()*Animate(ANIMATION_STEP_UNLOCK),0,0])
  translate([-PivotLatchTravel()*SubAnimate(ANIMATION_STEP_UNLOAD, start=0, end=0.3),0,0])
  translate([PivotLatchTravel()*SubAnimate(ANIMATION_STEP_LOAD, start=0.76),0,0])
  translate([-PivotLatchTravel()*Animate(ANIMATION_STEP_LOCK),0,0]) {
    LatchBolt();
    PivotLatchHandle();
    PivotLatch();
  }

  // The barrel and all the stuff that pivots with it
  Pivot(Animate(ANIMATION_STEP_UNLOAD)-Animate(ANIMATION_STEP_LOAD)) {
    
    BarrelLatchCollarBolts(barrel=DEFAULT_BARREL);
    
    Barrel(barrel=DEFAULT_BARREL, clearance=undef, hollow=true, alpha=1);

    // Extractor
    translate([-ExtractorTravel()*SubAnimate(ANIMATION_STEP_UNLOAD, start=0),0,0])
    translate([ExtractorTravel()*SubAnimate(ANIMATION_STEP_LOAD, start=0),0,0])
    //translate([ExtractorTravel()*Animate(ANIMATION_STEP_EXTRACT),0,0])
    //translate([-ExtractorTravel()*sin(180*Animate(ANIMATION_STEP_EXTRACT)),0,0])
    //translate([ExtractorTravel()*Animate(ANIMATION_STEP_EXTRACT),0,0])
    {
      Extractor();
      ExtractorGuide();
      ExtractorGuideBolts();
    }

    BarrelLatchCollar(barrel=DEFAULT_BARREL, alpha=1);
    

    BarrelPivotCollarBolts();
    BarrelPivotCollar(alpha=1);
  }

  ForendPivotedLatch(alpha=0.25);

  ForendPivoted(alpha=0.25);

}

ForendPivotedAssembly();

//Reference(barrelPipe=DEFAULT_BARREL);

// Plated Forend Pivoted
*!scale(25.4)
rotate([0,90,0])
translate([-ForendPivotedX()-PivotedForendLength(),0,0])
ForendPivoted(bolt=true, alpha=1);

// Plated Pivot Collar
*!scale(25.4)
rotate([0,90,0])
translate([-BarrelPivotX() + PivotRadius() - BarrelPivotInterface(),0,0])
BarrelPivotCollar(barrel=DEFAULT_BARREL);

// Plated Forend Pivoted Latch
*!scale(25.4)
rotate([0,90,0])
translate([-ForendX(),0,0])
ForendPivotedLatch(alpha=1);

// Plated Latch Collar
*!scale(25.4)
rotate([0,-90,0])
translate([-ForendX(),0,0])
BarrelLatchCollar(barrel=DEFAULT_BARREL);

// Plated Pivot Latch
*!scale(25.4)
translate([-PivotLatchX(),0,-PivotLatchZ()+LatchHeight()])
PivotLatch();

// Plated Latch Handle
*!scale(25.4)
translate([-LatchBoltX(),0,0])
PivotLatchHandle();

// Extractor
*!scale(25.4)
rotate([0,-90,0])
translate([-BreechFrontX(),0,0])
Extractor(barrelPipe=DEFAULT_BARREL);

// Extractor Guides
*!scale(25.4)
translate([-BreechFrontX(),0,0]) {
  rotate([-90,0,0])
  ExtractorGuide(barrelPipe=DEFAULT_BARREL, cutter=false, sides=[0]);
  
  rotate([90,0,0])
  ExtractorGuide(barrelPipe=DEFAULT_BARREL, cutter=false, sides=[1]);
}

// Extractor Pusher
*!scale(25.4)
rotate([90,0,0])
translate([-ExtractorPusherX(), 0, -ExtractorPusherZ()])
ExtractorPusher(barrelPipe=DEFAULT_BARREL);