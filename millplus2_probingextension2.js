// E90  X1
// E91  Y1
// E92  Z1

// E93  X2
// E94  Y2
// E95  Z2

// E96  X3
// E97  Y3
// E98  Z3

// E80  Berechnungsvariable
// E81  Berechnungsvariable
// E82  Berechnungsvariable
// E83  Berechnungsvariable
// E84  Berechnungsvariable
// E85  Berechnungsvariable
// E86  Berechnungsvariable

function probing_x(x, y, z) {
    writeComment("Probe X");
    protectedProbeMove(cycle, x, y, z - cycle.depth);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var approachDirection = cycle.approach1 == "positive" ? Millplus.Direction.Positive : Millplus.Direction.Negative; 
    var resultingCoordinate = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);

    Millplus.Functions.G45(Millplus.Axis.X, approachDirection, resultingCoordinate, y, z - cycle.depth, cycle.probeClearance, "E90");
    Millplus.Functions.G50(Millplus.Axis.X, workoffsetFormatted);  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_y(x, y, z) {
    writeComment("Probe Y");
    protectedProbeMove(cycle, x, y, z - cycle.depth);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var approachDirection = cycle.approach1 == "positive" ? "+1" : "-1"; 
    var resultingCoordinate = y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
  
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinate),
      Outputs.Z.format(z - cycle.depth),
      "J" + approachDirection,
      Formats.X1.format(cycle.probeClearance),
      "E91");

    Millplus.Functions.G50(Millplus.Axis.Y, workoffsetFormatted);  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_z(x, y, z){
    writeComment("Probe Z");
    protectedProbeMove(cycle, x, y, z - cycle.depth + cycle.probeClearance + tool.diameter / 2);
  
    Outputs.ForceXYZ();
  
    if (cycle.approach1 == "positive")
    {
      error("Cannot probe in Z positive direction");
    }
    
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var approachDirection = cycle.approach1 == "positive" ? "+1" : "-1"; 
    var resultingCoordinate = z - cycle.depth;
  
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(y),
      Outputs.Z.format(resultingCoordinate),
      "K" + approachDirection,
      Formats.X1.format(cycle.probeClearance),
      "E92");
    
    Millplus.Functions.G50(Millplus.Axis.Z, workoffsetFormatted);  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_xy_inner_corner(x, y, z){
    writeComment("Probe XY Inner corner");
    protectedProbeMove(cycle, x, y, Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract));
  
    Outputs.ForceXYZ();
          
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var approachDirectionX = cycle.approach1 == "positive" ? "+1" : "-1";
    var approachDirectionY = cycle.approach2 == "positive" ? "+1" : "-1";
    var resultingCoordinateX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
    var resultingCoordinateY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
  
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinateX),
      Outputs.Y.format(y),
      Outputs.Z.format(z - cycle.depth),
      "I" + approachDirectionX,
      Formats.X1.format(cycle.probeClearance),
      "E90");
  
    Outputs.Z.reset();
  
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateY),
      Outputs.Z.format(z - cycle.depth),
      "J" + approachDirectionY,
      Formats.X1.format(cycle.probeClearance),
      "E91");
  
    Millplus.Functions.G50(Millplus.Axis.X | Millplus.Axis.Y, workoffsetFormatted);  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_xy_outer_corner(x, y, z){
    writeComment("Probe XY Outer corner");
    protectedProbeMove(cycle, x, y, Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract));
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var approachDirectionX = cycle.approach1 == "positive" ? "+1" : "-1";
    var approachDirectionY = cycle.approach2 == "positive" ? "+1" : "-1";
    var resultingCoordinateX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
    var resultingCoordinateY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
  
    var measCoordinateX = x + approach(cycle.approach1) * (cycle.probeClearance * 2 + tool.diameter);
    var measCoordinateY = y + approach(cycle.approach2) * (cycle.probeClearance * 2 + tool.diameter);
  
    // Move to measuring position in Y coordinate
    writeBlock(Formats.G.format(1), Outputs.Y.format(measCoordinateY));
    Outputs.Y.reset();
  
    // Measure X
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinateX),
      Outputs.Y.format(measCoordinateY),
      Outputs.Z.format(z - cycle.depth),
      "I" + approachDirectionX,
      Formats.X1.format(cycle.probeClearance),
      "E90");
  
    Outputs.Z.reset();
  
    // Move back to start position in Y coordinate
    writeBlock(Formats.G.format(1), Outputs.Y.format(y));
    Outputs.Y.reset();
  
    // Move to measuring position in X coordinate
    writeBlock(Formats.G.format(1), Outputs.X.format(measCoordinateX));
    Outputs.X.reset();
  
    // Measure Y
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(measCoordinateX),
      Outputs.Y.format(resultingCoordinateY),
      Outputs.Z.format(z - cycle.depth),
      "J" + approachDirectionY,
      Formats.X1.format(cycle.probeClearance),
      "E91");
  
      Outputs.Z.reset();
  
    // Move back to start position X in coordinate
    writeBlock(Formats.G.format(1), Outputs.X.format(x));
    Outputs.X.reset();

    Millplus.Functions.G50(Millplus.Axis.X | Millplus.Axis.Y, workoffsetFormatted);
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_x_channel(x, y, z) {
    writeComment("Probe X Pocket");
    protectedProbeMove(cycle, x, y, z - cycle.depth);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinate = x;
    var resultingCoordinatePositive = resultingCoordinate + (cycle.width1 / 2);
    var resultingCoordinateNegative = resultingCoordinate - (cycle.width1 / 2);
  
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinatePositive),
      Outputs.Y.format(y),
      Outputs.Z.format(z - cycle.depth),
      "I+1",
      Formats.X1.format(cycle.probeClearance),
      "E90");
  
      Outputs.ForceXYZ();
    writeBlock(Formats.G.format(1), Outputs.X.format(x), Outputs.Y.format(y));
  
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinateNegative),
      Outputs.Y.format(y),
      Outputs.Z.format(z - cycle.depth),
      "I-1",
      Formats.X1.format(cycle.probeClearance),
      "E93");
  
      Outputs.ForceXYZ();
    writeBlock(Formats.G.format(1), Outputs.X.format(x), Outputs.Y.format(y));
    Outputs.ForceXYZ();

      writeBlock("E86=" + Formats.XYZ.format(x));
      Outputs.X.reset();
  
      writeBlock("E80=E90-((E90-E93):2)")
      writeBlock("E81=E80-E86");
    
      writeBlock(Formats.G.format(149), 
        "N1=54." + workoffsetFormatted,
        "X7=84");
    
      writeBlock(Formats.G.format(150),
        "N1=54." + workoffsetFormatted,
        "X7=E84+E81");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_y_channel(x, y, z) {
    writeComment("Probe Y Pocket");
    protectedProbeMove(cycle, x, y, z - cycle.depth);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinate = y;
    var resultingCoordinatePositive = resultingCoordinate + (cycle.width1 / 2);
    var resultingCoordinateNegative = resultingCoordinate - (cycle.width1 / 2);
  
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositive),
      Outputs.Z.format(z - cycle.depth),
      "J+1",
      Formats.X1.format(cycle.probeClearance),
      "E91");
  
      Outputs.ForceXYZ();
    writeBlock(Formats.G.format(1), Outputs.X.format(x), Outputs.Y.format(y));
  
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegative),
      Outputs.Z.format(z - cycle.depth),
      "J-1",
      Formats.X1.format(cycle.probeClearance),
      "E94");
  
      Outputs.ForceXYZ();
    writeBlock(Formats.G.format(1), Outputs.X.format(x), Outputs.Y.format(y));
    Outputs.ForceXYZ();
  
      writeBlock("E87=" + Formats.XYZ.format(y));
      Outputs.Y.reset();
  
  
      writeBlock("E82=E91-((E91-E94):2)")
      writeBlock("E83=E82-E87")
    
      writeBlock(Formats.G.format(149), 
        "N1=54." + workoffsetFormatted,
        "Y7=85");
    
      writeBlock(Formats.G.format(150),
        "N1=54." + workoffsetFormatted,
        "Y7=E85+E83");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_x_channel_with_island(x, y, z) {
    writeComment("Probe X Pocket with Island");
    protectedProbeMove(cycle, x, y, z - cycle.depth);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinate = x;
    var resultingCoordinatePositive = resultingCoordinate + (cycle.width1 / 2);
    var resultingCoordinateNegative = resultingCoordinate - (cycle.width1 / 2);
    var probeHeight = z - cycle.depth;
  
    // Preposition X Positive
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(resultingCoordinatePositive - cycle.probeClearance - tool.diameter / 2),
      Outputs.Y.format(y));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // Probe X Positive
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinatePositive),
      Outputs.Y.format(y),
      Outputs.Z.format(probeHeight),
      "I+1",
      Formats.X1.format(cycle.probeClearance),
      "E90");
  
    // Move Back
    Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition X Negative
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(resultingCoordinateNegative + cycle.probeClearance + tool.diameter / 2),
      Outputs.Y.format(y));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // Probe X Negative
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinateNegative),
      Outputs.Y.format(y),
      Outputs.Z.format(probeHeight),
      "I-1",
      Formats.X1.format(cycle.probeClearance),
      "E93");
  
    // Move Back
    Millplus.Movements.RapidZThenXY(x, y, z);
    Outputs.ForceXYZ();

      writeBlock("E86=" + Formats.XYZ.format(x));
      Outputs.X.reset();
  
      writeBlock("E80=E90-((E90-E93):2)")
      writeBlock("E81=E80-E86");
    
      writeBlock(Formats.G.format(149), 
        "N1=54." + workoffsetFormatted,
        "X7=84");
    
      writeBlock(Formats.G.format(150),
        "N1=54." + workoffsetFormatted,
        "X7=E84+E81");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_y_channel_with_island(x, y, z) {
    writeComment("Probe Y Pocket with Island");
    protectedProbeMove(cycle, x, y, z - cycle.depth);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinate = y;
    var resultingCoordinatePositive = resultingCoordinate + (cycle.width1 / 2);
    var resultingCoordinateNegative = resultingCoordinate - (cycle.width1 / 2);
    var probeHeight = z - cycle.depth;
  
    // Preposition Y Positive
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositive - cycle.probeClearance - tool.diameter / 2));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // Probe Y Positive
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositive),
      Outputs.Z.format(probeHeight),
      "J+1",
      Formats.X1.format(cycle.probeClearance),
      "E91");
  
    // Move Back
    Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition Y Negative
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegative + cycle.probeClearance + tool.diameter / 2));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // Probe Y Negative
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegative),
      Outputs.Z.format(probeHeight),
      "J-1",
      Formats.X1.format(cycle.probeClearance),
      "E94");
  
    // Move Back
    Millplus.Movements.RapidZThenXY(x, y, z);
    Outputs.ForceXYZ();

      writeBlock("E87=" + Formats.XYZ.format(y));
      Outputs.Y.reset();

      writeBlock("E82=E91-((E91-E94):2)")
      writeBlock("E83=E82-E87")
    
      writeBlock(Formats.G.format(149), 
        "N1=54." + workoffsetFormatted,
        "Y7=85");
    
      writeBlock(Formats.G.format(150),
        "N1=54." + workoffsetFormatted,
        "Y7=E85+E83");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_xy_rectangular_hole(x, y, z) {
    writeComment("Probe XY Pocket");
    protectedProbeMove(cycle, x, y, z - cycle.depth);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinateX = x;
    var resultingCoordinateY = y;
    var resultingCoordinatePositiveX = resultingCoordinateX + (cycle.width1 / 2);
    var resultingCoordinateNegativeX = resultingCoordinateX - (cycle.width1 / 2);
    var resultingCoordinatePositiveY = resultingCoordinateY + (cycle.width2 / 2);
    var resultingCoordinateNegativeY = resultingCoordinateY - (cycle.width2 / 2);
  
    // X Positive
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinatePositiveX),
      Outputs.Y.format(y),
      Outputs.Z.format(z - cycle.depth),
      "I+1",
      Formats.X1.format(cycle.probeClearance),
      "E90");
  
    Outputs.X.reset();
    Outputs.Y.reset();
    writeBlock(Formats.G.format(1), Outputs.X.format(x), Outputs.Y.format(y));
  
    // X Negative
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinateNegativeX),
      Outputs.Y.format(y),
      Outputs.Z.format(z - cycle.depth),
      "I-1",
      Formats.X1.format(cycle.probeClearance),
      "E93");
  
    Outputs.X.reset();
    Outputs.Y.reset();
    writeBlock(Formats.G.format(1), Outputs.X.format(x), Outputs.Y.format(y));
    
    // Y Positive
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositiveY),
      Outputs.Z.format(z - cycle.depth),
      "J+1",
      Formats.X1.format(cycle.probeClearance),
      "E91");
  
    Outputs.X.reset();
    Outputs.Y.reset();
    writeBlock(Formats.G.format(1), Outputs.X.format(x), Outputs.Y.format(y));
  
    // Y Negative
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegativeY),
      Outputs.Z.format(z - cycle.depth),
      "J-1",
      Formats.X1.format(cycle.probeClearance),
      "E94");
  
    Outputs.X.reset();
    Outputs.Y.reset();
    writeBlock(Formats.G.format(1), Outputs.X.format(x), Outputs.Y.format(y));
    Outputs.ForceXYZ();
  
    writeBlock("E86=" + Formats.XYZ.format(x));
    writeBlock("E87=" + Formats.XYZ.format(y));
    Outputs.X.reset();
    Outputs.Y.reset();

    writeBlock("E80=E90-((E90-E93):2)")
    writeBlock("E81=E80-E86");

    writeBlock("E82=E91-((E91-E94):2)")
    writeBlock("E83=E82-E87")
  
    writeBlock(Formats.G.format(149), 
      "N1=54." + workoffsetFormatted,
      "X7=84",
      "Y7=85");
  
    writeBlock(Formats.G.format(150),
      "N1=54." + workoffsetFormatted,
      "X7=E84+E81",
      "Y7=E85+E83");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_xy_rectangular_hole_with_island(x, y, z) {
    writeComment("Probe XY Pocket with Island");
    protectedProbeMove(cycle, x, y, z);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinateX = x;
    var resultingCoordinateY = y;
    var resultingCoordinatePositiveX = resultingCoordinateX + (cycle.width1 / 2);
    var resultingCoordinateNegativeX = resultingCoordinateX - (cycle.width1 / 2);
    var resultingCoordinatePositiveY = resultingCoordinateY + (cycle.width2 / 2);
    var resultingCoordinateNegativeY = resultingCoordinateY - (cycle.width2 / 2);
    var probeHeight = z - cycle.depth;
  
    // Preposition X Positive
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(resultingCoordinatePositiveX - cycle.probeClearance - tool.diameter / 2),
      Outputs.Y.format(y));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // X Positive
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinatePositiveX),
      Outputs.Y.format(y),
      Outputs.Z.format(probeHeight),
      "I+1",
      Formats.X1.format(cycle.probeClearance),
      "E90");
  
      Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition X Negative
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(resultingCoordinateNegativeX + cycle.probeClearance + tool.diameter / 2),
      Outputs.Y.format(y));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // X Negative
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinateNegativeX),
      Outputs.Y.format(y),
      Outputs.Z.format(probeHeight),
      "I-1",
      Formats.X1.format(cycle.probeClearance),
      "E93");
  
      Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition Y Positive
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositiveY - cycle.probeClearance - tool.diameter / 2));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
    
    // Y Positive
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositiveY),
      Outputs.Z.format(probeHeight),
      "J+1",
      Formats.X1.format(cycle.probeClearance),
      "E91");
  
      Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition Y Negative
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegativeY + cycle.probeClearance + tool.diameter / 2));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // Y Negative
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegativeY),
      Outputs.Z.format(probeHeight),
      "J-1",
      Formats.X1.format(cycle.probeClearance),
      "E94");
  
      Millplus.Movements.RapidZThenXY(x, y, z);
    Outputs.ForceXYZ();
  
    writeBlock("E86=" + Formats.XYZ.format(x));
    writeBlock("E87=" + Formats.XYZ.format(y));
    Outputs.X.reset();
    Outputs.Y.reset();

    writeBlock("E80=E90-((E90-E93):2)")
    writeBlock("E81=E80-E86");

    writeBlock("E82=E91-((E91-E94):2)")
    writeBlock("E83=E82-E87")
  
    writeBlock(Formats.G.format(149), 
      "N1=54." + workoffsetFormatted,
      "X7=84",
      "Y7=85");
  
    writeBlock(Formats.G.format(150),
      "N1=54." + workoffsetFormatted,
      "X7=E84+E81",
      "Y7=E85+E83");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_xy_rectangular_boss(x, y, z) {
    writeComment("Probe XY Rectangular Boss");
    protectedProbeMove(cycle, x, y, z);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinateX = x;
    var resultingCoordinateY = y;
    var resultingCoordinatePositiveX = resultingCoordinateX + (cycle.width1 / 2);
    var resultingCoordinateNegativeX = resultingCoordinateX - (cycle.width1 / 2);
    var resultingCoordinatePositiveY = resultingCoordinateY + (cycle.width2 / 2);
    var resultingCoordinateNegativeY = resultingCoordinateY - (cycle.width2 / 2);
    var probeHeight = z - cycle.depth;
  
    // Preposition X Positive
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(resultingCoordinatePositiveX + cycle.probeClearance + tool.diameter / 2),
      Outputs.Y.format(y));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // X Positive
    Millplus.Functions.G45(Millplus.Axis.X, Millplus.Direction.Negative, resultingCoordinatePositiveX, y, probeHeight, cycle.probeClearance, "E90");
    Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition X Negative
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(resultingCoordinateNegativeX - cycle.probeClearance - tool.diameter / 2),
      Outputs.Y.format(y));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // X Negative
    Millplus.Functions.G45(Millplus.Axis.X, Millplus.Direction.Positive, resultingCoordinateNegativeX, y, probeHeight, cycle.probeClearance, "E93");
    Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition Y Positive
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositiveY + cycle.probeClearance + tool.diameter / 2));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
    
    // Y Positive
    Millplus.Functions.G45(Millplus.Axis.Y, Millplus.Direction.Negative, x, resultingCoordinatePositiveY, probeHeight, cycle.probeClearance, "E91");
    Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition Y Negative
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegativeY - cycle.probeClearance - tool.diameter / 2));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // Y Negative
    Millplus.Functions.G45(Millplus.Axis.Y, Millplus.Direction.Positive, x, resultingCoordinateNegativeY, probeHeight, cycle.probeClearance, "E94");
    Millplus.Movements.RapidZThenXY(x, y, z);

    Outputs.ForceXYZ();
  
    writeBlock("E86=" + Formats.XYZ.format(x));
    writeBlock("E87=" + Formats.XYZ.format(y));
    Outputs.X.reset();
    Outputs.Y.reset();

    writeBlock("E80=E90-((E90-E93):2)")
    writeBlock("E81=E80-E86");

    writeBlock("E82=E91-((E91-E94):2)")
    writeBlock("E83=E82-E87")
  
    writeBlock(Formats.G.format(149), 
      "N1=54." + workoffsetFormatted,
      "X7=84",
      "Y7=85");
  
    writeBlock(Formats.G.format(150),
      "N1=54." + workoffsetFormatted,
      "X7=E84+E81",
      "Y7=E85+E83");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }

  function probing_xy_circular_boss(x, y, z) {
    writeComment("Probe XY Circular Boss");
    protectedProbeMove(cycle, x, y, z);
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
  
    Outputs.ForceXYZ();

    writeBlock(
      Formats.G.format(46),
      Formats.R.format(cycle.width1 / 2),
      "I-1 J-1",
      Outputs.X.format(x),
      Outputs.Y.format(y),
      Outputs.Z.format(z - cycle.depth),
      "F" + Formats.Feed.format(cycle.feedrate),
      Formats.X1.format(cycle.probeClearance),
      "N=1",
      "E91");

    Millplus.Functions.G50(Millplus.Axis.X | Millplus.Axis.Y, workoffsetFormatted); 

    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_xy_circular_hole(x, y, z) {
    writeComment("Probe XY Circular Hole");

    protectedProbeMove(cycle, x, y, z);
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
  
    Outputs.ForceXYZ();

    writeBlock(
      Formats.G.format(46),
      Formats.R.format(cycle.width1 / 2),
      "I+1 J+1",
      Outputs.X.format(x),
      Outputs.Y.format(y),
      Outputs.Z.format(z - cycle.depth),
      "F" + Formats.Feed.format(cycle.feedrate),
      Formats.X1.format(cycle.probeClearance),
      "N=1",
      "E91");

    Millplus.Functions.G50(Millplus.Axis.X | Millplus.Axis.Y, workoffsetFormatted); 

    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_x_wall(x, y, z) {
    writeComment("Probe X Wall");
    protectedProbeMove(cycle, x, y, z);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinateX = x;
    var resultingCoordinatePositiveX = resultingCoordinateX + (cycle.width1 / 2);
    var resultingCoordinateNegativeX = resultingCoordinateX - (cycle.width1 / 2);
    var probeHeight = z - cycle.depth;
  
    // Preposition X Positive
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(resultingCoordinatePositiveX + cycle.probeClearance + tool.diameter / 2),
      Outputs.Y.format(y));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // X Positive
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinatePositiveX),
      Outputs.Y.format(y),
      Outputs.Z.format(probeHeight),
      "I-1",
      Formats.X1.format(cycle.probeClearance),
      "E90");
  
      Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition X Negative
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(resultingCoordinateNegativeX - cycle.probeClearance - tool.diameter / 2),
      Outputs.Y.format(y));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // X Negative
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(resultingCoordinateNegativeX),
      Outputs.Y.format(y),
      Outputs.Z.format(probeHeight),
      "I+1",
      Formats.X1.format(cycle.probeClearance),
      "E93");
  
      Millplus.Movements.RapidZThenXY(x, y, z);
    Outputs.ForceXYZ();
  
    writeBlock("E86=" + Formats.XYZ.format(x));
    Outputs.X.reset();

    writeBlock("E80=E90-((E90-E93):2)")
    writeBlock("E81=E80-E86");
  
    writeBlock(Formats.G.format(149), 
      "N1=54." + workoffsetFormatted,
      "X7=84");
  
    writeBlock(Formats.G.format(150),
      "N1=54." + workoffsetFormatted,
      "X7=E84+E81");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }
  
  function probing_y_wall(x, y, z) {
    writeComment("Probe Y Wall");
    protectedProbeMove(cycle, x, y, z);
  
    Outputs.ForceXYZ();
  
    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinateY = y;
    var resultingCoordinatePositiveY = resultingCoordinateY + (cycle.width1 / 2);
    var resultingCoordinateNegativeY = resultingCoordinateY - (cycle.width1 / 2);
    var probeHeight = z - cycle.depth;
  
    // Preposition Y Positive
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositiveY + cycle.probeClearance + tool.diameter / 2));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // Y Positive
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinatePositiveY),
      Outputs.Z.format(probeHeight),
      "J-1",
      Formats.X1.format(cycle.probeClearance),
      "E91");
  
      Millplus.Movements.RapidZThenXY(x, y, z);
  
    // Preposition Y Negative
    writeBlock(
      Formats.G.format(1),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegativeY - cycle.probeClearance - tool.diameter / 2));
    writeBlock(Formats.G.format(1), Outputs.Z.format(probeHeight));
    Outputs.ForceXYZ();
  
    // Y Negative
    writeBlock(
      Formats.G.format(45),
      Outputs.X.format(x),
      Outputs.Y.format(resultingCoordinateNegativeY),
      Outputs.Z.format(probeHeight),
      "J+1",
      Formats.X1.format(cycle.probeClearance),
      "E94");
  
    Millplus.Movements.RapidZThenXY(x, y, z);
    Outputs.ForceXYZ();
  
    writeBlock("E87=" + Formats.XYZ.format(y));
    Outputs.Y.reset();

    writeBlock("E82=E91-((E91-E94):2)")
    writeBlock("E83=E82-E87")
  
    writeBlock(Formats.G.format(149), 
      "N1=54." + workoffsetFormatted,
      "Y7=85");
  
    writeBlock(Formats.G.format(150),
      "N1=54." + workoffsetFormatted,
      "Y7=E85+E83");
  
    Millplus.Functions.G54(currentSection.workOffset);
  }

  function probing_y_plane_angle(x, y, z) {
    writeComment("Probe Y Plane Angle");
    protectedProbeMove(cycle, x, y, z);  
    Outputs.ForceXYZ();

    var workoffsetFormatted = currentSection.workOffset < 10 ? "0" + currentSection.workOffset : currentSection.workOffset;
    var resultingCoordinateX = x;
    var resultingCoordinatePositiveX = resultingCoordinateX + (cycle.probeSpacing / 2);
    var resultingCoordinateNegativeX = resultingCoordinateX - (cycle.probeSpacing / 2);
    var probeHeight = z - cycle.depth;
    var approachDirection = cycle.approach1 == "positive" ? Millplus.Direction.Positive : Millplus.Direction.Negative; 
    var resultingCoordinateY = y + cycle.probeClearance;
    var angle = "C" + Formats.ABC.format(cycle.nominalAngle);

    Millplus.Functions.G45(Millplus.Axis.Y, approachDirection, resultingCoordinateNegativeX, resultingCoordinateY, probeHeight, cycle.probeClearance, angle);
    Outputs.ForceXYZ();
    Millplus.Functions.G45(Millplus.Axis.Y, approachDirection, resultingCoordinatePositiveX, resultingCoordinateY, probeHeight, cycle.probeClearance, "");
    Millplus.Functions.G50(Millplus.Axis.C, workoffsetFormatted);  
    Millplus.Movements.RapidZThenXY(x, y, z);
    Millplus.Functions.G54(currentSection.workOffset);
    writeBlock(Formats.G.format(0), angle);
  }