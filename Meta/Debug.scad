module DebugHalf(dimension=100, rotateArray=[0,0,0], mirrorArray=[0,0,0], enabled=true) {
  if (enabled) {
    render()
    difference() {
      children();

      mirror(mirrorArray)
      rotate(rotateArray)
      translate([-dimension/2,0,-dimension/2])
      cube([dimension,dimension,dimension]);
    }
  } else {
    children();
  }
}
