/**
  Copyright (C) 2012-2018 by Autodesk, Inc.
  All rights reserved.

  MillPlus post processor configuration.

  $Revision: 42285 2a92613bd2b26bbe483938c4c193a033ed9d6f3f $
  $Date: 2019-04-01 18:08:11 $
  
  FORKID {72356D88-2414-401a-805E-5842DB111BB6}
*/

// TODO: Replace forceABC() with Outputs.ForceXYZ();

description = "MillPlus";
vendor = "bamboocha.racing";
vendorUrl = "http://www.millplus.de";
legal = "Copyright (C) 2012-2018 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45702;

longDescription = "Generic milling post for MillPlus.";

extension = "PM";
programNameIsInteger = true;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
mapWorkOrigin = true; // set to false to get G93 blocks

safeRetractDistance = 35;

// user-defined properties
properties = {
  writeMachine: true, // write machine
  writeTools: true, // writes the tools
  preloadTool: true, // preloads next tool on tool change if any
  showSequenceNumbers: true, // show sequence numbers
  sequenceNumberStart: 10, // first sequence number
  sequenceNumberIncrement: 1, // increment for sequence numbers
  optionalStop: true, // optional stop
  MC84: 1, // MC84 machine parameter
  useParametricFeed: false, // specifies that feed should be output using Q values
  showNotes: true, // specifies that operation notes should be output.

  isDmu50v: true,
  useG74retract: true,
  retractHeightAboveParts: 100,
  useDpmFeed: false,
  dpmTolerance: 0.5,
  safeRetractDistance: 35,
  dontResetG7RotaryAxis: false
};

// user-defined property definitions
propertyDefinitions = {
  writeMachine: {title:"Write machine", description:"Output the machine settings in the header of the code.", group:0, type:"boolean"},
  writeTools: {title:"Write tool list", description:"Output a tool list in the header of the code.", group:0, type:"boolean"},
  preloadTool: {title:"Preload tool", description:"Preloads the next tool at a tool change (if any).", type:"boolean"},
  showSequenceNumbers: {title:"Use sequence numbers", description:"Use sequence numbers for each block of outputted code.", group:1, type:"boolean"},
  sequenceNumberStart: {title:"Start sequence number", description:"The number at which to start the sequence numbers.", group:1, type:"integer"},
  sequenceNumberIncrement: {title:"Sequence number increment", description:"The amount by which the sequence number is incremented by in each block.", group:1, type:"integer"},
  optionalStop: {title:"Optional stop", description:"Outputs optional stop code during when necessary in the code.", type:"boolean"},
  MC84: {title:"MC84 Parameter", description:"Sets the MC84 machine parameter", type:"integer"},
  useParametricFeed:  {title:"Parametric feed", description:"Specifies the feed value that should be output using a Q value.", type:"boolean"},
  showNotes: {title:"Show notes", description:"Writes operation notes as comments in the outputted code.", type:"boolean"},

  useG74retract: { title: "Use G74 Retract", description: "Writes a G74 Z-1 L1 whenever a retract is requested.", type: "boolean" },
  isDmu50v: { title: "DMU 50V", description: "DMU50V (5Axis).", type: "boolean" },
  retractHeightAboveParts: { title: "Retract Plane Height", description: "The retract height above the part.", type: "integer" },
  useDpmFeed: { title: "Use DPM Feed for multiaxis feedrates.", description: "Uses DPM feed", type: "boolean" },
  dpmTolerance: { title: "Tolerance to determine when the DPM feed has changed", description: "DPM Feed Tolerance", type: "number" },
  dontResetG7RotaryAxis: { title: "Dont Reset G7 with moving Rotary axis.", description: "Reset G7 Rotary Axis", type: "boolean" },
};

var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines
// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
var coolants = [
  {id: COOLANT_FLOOD, on: [73, 8]},
  {id: COOLANT_MIST, on: 7},
  {id: COOLANT_THROUGH_TOOL},
  {id: COOLANT_AIR, on: [72, 8]},
  {id: COOLANT_AIR_THROUGH_TOOL},
  {id: COOLANT_SUCTION},
  {id: COOLANT_FLOOD_MIST},
  {id: COOLANT_FLOOD_THROUGH_TOOL},
  {id: COOLANT_OFF, off: 9}
];

// fixed settings
var firstFeedParameter = 1;

var WARNING_WORK_OFFSET = 0;
var WARNING_LENGTH_OFFSET = 1;
var WARNING_DIAMETER_OFFSET = 2;

// collected state
var sequenceNumber;
var currentWorkOffset;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var retracted = false; // specifies that the tool has been retracted to the safe plane
var isFirstRetract = true;

/**
  Writes the specified block.
*/
function writeBlock() {
  if (!formatWords(arguments)) {
    return;
  }
  if (properties.showSequenceNumbers) {
    writeWords2("N" + sequenceNumber, arguments);
    sequenceNumber += properties.sequenceNumberIncrement;
  } else {
    writeWords(arguments);
  }
}

function formatComment(text) {
  return "(" + String(text).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  if (properties.showSequenceNumbers) {
    writeWords2("N" + sequenceNumber, formatComment(text));
    sequenceNumber += properties.sequenceNumberIncrement;
  } else {
    writeWords(formatComment(text));
  }
}

function onOpen() {
  if (properties.isDmu50v == true) { // note: setup your machine here
    
    // DMU50V/eVo/eVolution Setup without TCPM
    // The B Axis is pointing 45° Upward
    // 0° is X/Y Plane
    // 180° is X/Z Plane

    // A workplane tilted by 45° around the B-Axis is e.g. B65.53° and C24.42°
    // The C axis needs to turn in order to reach the desired tool axis vector.

    var bAxis = createAxis(
      {
        coordinate:1, 
        table:true, 
        axis:[0, 0.70710677, -0.70710677], 
        range:[0 - 0.5, 180 + 0.5], 
        preference:1, 
        offset: [0, 0, 0]
      });

    var cAxis = createAxis(
      {
        coordinate:2, 
        table: true,
        axis:[0, 0, 1], 
        range:[-999999, 999999], 
        preference:1, 
        cyclic: false,
        offset: [0, 0, 0],
        reset: 3
      });    
    
    machineConfiguration = new MachineConfiguration(bAxis, cAxis);
    machineConfiguration.enableMachineRewinds();
    safeRetractDistance = 35;

    if (properties.useDpmFeed) {
      machineConfiguration.setMultiAxisFeedrate(
        FEED_DPM,
        6119,          // maximum output value for inverse time feed rates
        DPM_COMBINATION,  // INVERSE_MINUTES/INVERSE_SECONDS or DPM_COMBINATION/DPM_STANDARD
        0.5,              // tolerance to determine when the DPM feed has changed
        1.5               // ratio of rotary accuracy to linear accuracy for DPM calculations
      );
    }

    var performRewinds = true; // set to true to enable the rewind/reconfigure logic
    if (performRewinds) {
      machineConfiguration.enableMachineRewinds(); // enables the retract/reconfigure logic
      safeRetractDistance = (unit == IN) ? 1 : 25; // additional distance to retract out of stock, can be overridden with a property
      safeRetractFeed = (unit == IN) ? 20 : 2000; // retract feed rate
      safePlungeFeed = (unit == IN) ? 10 : 500; // plunge feed rate
      machineConfiguration.setSafeRetractDistance(safeRetractDistance);
      machineConfiguration.setSafeRetractFeedrate(safeRetractFeed);
      machineConfiguration.setSafePlungeFeedrate(safePlungeFeed);
      var stockExpansion = new Vector(toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN)); // expand stock XYZ values
      machineConfiguration.setRewindStockExpansion(stockExpansion);
    }

    machineConfiguration.setMaximumSpindleSpeed(8000);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(1); // NO TCP!
  }

  if (!machineConfiguration.isMachineCoordinate(0)) {
    Outputs.A.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1)) {
    Outputs.B.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2)) {
    Outputs.C.disable();
  }

  sequenceNumber = properties.sequenceNumberStart;

  if (programName) {
    var programId;
    try {
      programId = getAsInt(programName);
    } catch(e) {
      error(localize("Program name must be a number."));
      return;
    }
    if (!((programId >= 1) && (programId <= 9999999))) {
      error(localize("Program number is out of range."));
      return;
    }
    //writeln("%PM" + programId);
    writeln("N" + programId + " (" + programName + ")");
  } else {
    error(localize("Program name has not been specified."));
    return;
  }
  
  if (programComment) {
    writeComment(programComment);
  }

  writeComment("---------------------------");

  if (properties.showNotes && hasGlobalParameter("job-notes")) {
    var notes = getGlobalParameter("job-notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }

      writeComment("---------------------------");
    }
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (properties.writeMachine && (vendor || model || description)) {
    writeComment(localize("Machine"));
    if (vendor) {
      writeComment("  " + localize("vendor") + ": " + vendor);
    }
    if (model) {
      writeComment("  " + localize("model") + ": " + model);
    }
    if (description) {
      writeComment("  " + localize("description") + ": "  + description);
    }

    writeComment("---------------------------");
  }

  // dump tool information
  if (properties.writeTools) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var comment = "T" + Formats.Tool.format(tool.number) + "  " +
          "D=" + Formats.XYZ.format(tool.diameter) + " " +
          localize("CR") + "=" + Formats.XYZ.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + Formats.Taper.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + Formats.XYZ.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        comment += " - " + tool.description;
        writeComment(comment);
      }

      writeComment("---------------------------");
    }
  }

  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }

  // absolute coordinates and feed per min
  writeBlock(Modals.AbsInc.format(90));
  writeBlock(Modals.FeedMode.format(94));
  writeBlock(Modals.Plane.format(17));

  switch (unit) {
  case IN:
    writeBlock(Modals.Unit.format(70));
    break;
  case MM:
    writeBlock(Modals.Unit.format(71));
    break;
  }
}

function onComment(message) {
  writeComment(message);
}

function forceFeed() {
  currentFeedId = undefined;
  Outputs.Feed.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
// function forceAny() {
//   Outputs.ForceXYZ();
//   Outputs.ForceABC();
//   forceFeed();
// }

function onParameter(name, value) {
}

function onPassThrough(text) {
  writeBlock(text);
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!Formats.Feed.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F=E" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return Outputs.Feed.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  
  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }
  
  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), Math.max(getParameter("operation:tool_feedCutting"), getParameter("operation:tool_feedEntry"), getParameter("operation:tool_feedExit")));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), this.highFeedrate);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }
  
  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("E" + (firstFeedParameter + feedContext.id) + "=" + Formats.Feed.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;
var currentWorkPlaneXYZ = new Vector(0, 0, 0);
var currentWorkPlaneABCTurned = false;

function forceWorkPlane() {
  if (properties.isDmu50v)
  {
    writeBlock(Formats.G.format(7), properties.dontResetG7RotaryAxis ? "" : "L1=1");
    if (properties.dontResetG7RotaryAxis)
      writeComment("Dont Reset");
  }

  currentWorkPlaneABC = undefined;
}

function resetWorkOffset() {
  currentWorkOffset.x = 0;
  currentWorkOffset.y = 0;
  currentWorkOffset.z = 0;
}

function setWorkPlane(xyz, abc, turn) {
  if (properties.isDmu50v == false)
  {
    return;
  }

  if (is3D() && !machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        Formats.ABC.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        Formats.ABC.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        Formats.ABC.areDifferent(abc.z, currentWorkPlaneABC.z) ||
        (!currentWorkPlaneABCTurned && turn) ||
        Formats.XYZ.areDifferent(xyz.x, currentWorkPlaneXYZ.x) ||
        Formats.XYZ.areDifferent(xyz.y, currentWorkPlaneXYZ.y) ||
        Formats.XYZ.areDifferent(xyz.z, currentWorkPlaneXYZ.z)) && !abc.isZero()) {
          writeComment("aaa" + currentWorkPlaneABC.isZero());
    return; // no change
  }
  currentWorkPlaneABC = abc;
  currentWorkPlaneABCTurned = turn;

  if (turn) {
    onCommand(COMMAND_UNLOCK_MULTI_AXIS);
  }
  
  if (!mapWorkOrigin && (Formats.XYZ.areDifferent(xyz.x, currentWorkPlaneXYZ.x) ||
      Formats.XYZ.areDifferent(xyz.y, currentWorkPlaneXYZ.y) ||
      Formats.XYZ.areDifferent(xyz.z, currentWorkPlaneXYZ.z))) {
    writeBlock(Formats.G.format(93),
      conditional(Formats.XYZ.areDifferent(xyz.x, currentWorkPlaneXYZ.x), "X" + Formats.XYZ.format(xyz.x)),
      conditional(Formats.XYZ.areDifferent(xyz.y, currentWorkPlaneXYZ.y), "Y" + Formats.XYZ.format(xyz.y)),
      conditional(Formats.XYZ.areDifferent(xyz.z, currentWorkPlaneXYZ.z), "Z" + Formats.XYZ.format(xyz.z))
    );
  }
  currentWorkPlaneXYZ = xyz;

  // TODO: Wieder einkommentieren für 5 Achs bzw. 3+2 Bearbeitung
  if (abc.isZero()) {
    // reset working plane
    if (properties.isDmu50v) {
      writeBlock(Formats.G.format(7), "L1=" + (turn ? 1 : 0));
    }
    Outputs.ForceABC();
  } else {
    if (properties.isDmu50v) {
      writeBlock(
        Formats.G.format(7),
        "A5=" + Formats.ABC.format(abc.x),
        "B5=" + Formats.ABC.format(abc.y),
        "C5=" + Formats.ABC.format(abc.z),
        "L1=" + (turn ? 1 : 0)
      );
    }
  }
  
  if (turn) {
    //if (!currentSection.isMultiAxis()) {
      onCommand(COMMAND_LOCK_MULTI_AXIS);
    //}
  }
}

function isProbeOperation() {
  return hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe");
}

function onSection() {
  if (firstToolChange) { // stock - workpiece
    var workpiece = getWorkpiece();
    var delta = Vector.diff(workpiece.upper, workpiece.lower);
    if (delta.isNonZero()) {
      // G196-199 are recommended
      var offset = 10;
      writeBlock(
        Formats.G.format(99), "X" + Formats.XYZ.format(workpiece.lower.x - offset),
        "Y" + Formats.XYZ.format(workpiece.lower.y - offset),
        "Z" + Formats.XYZ.format(workpiece.lower.z - offset),
        "I" + Formats.XYZ.format(delta.x + 2 * offset),
        "J" + Formats.XYZ.format(delta.y + 2 * offset),
        "K" + Formats.XYZ.format(delta.z + 2 * offset)
      );
      writeBlock(
        Formats.G.format(98), "X" + Formats.XYZ.format(workpiece.lower.x),
        "Y" + Formats.XYZ.format(workpiece.lower.y),
        "Z" + Formats.XYZ.format(workpiece.lower.z),
        "I" + Formats.XYZ.format(delta.x),
        "J" + Formats.XYZ.format(delta.y),
        "K" + Formats.XYZ.format(delta.z)
      );
    }
  }

  var insertToolCall = isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);
  
  retracted = false;
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
      Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
      getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations
  if (insertToolCall || newWorkOffset || newWorkPlane) {
    
    // retract to safe plane
    if (isMultiAxis()) {
      writeBlock(Formats.G.format(40));
    }
    
    // retract to safe plane

    if (isFirstRetract)
    {
      writeBlock(Formats.G.format(74), "Z-1 L1"); // retract
      
      if (properties.isDmu50v)
      {
        writeBlock(Formats.G.format(74), "X1=1 Y1=1 K1 L1");
      }

      retracted = true;
      isFirstRetract = false;
    }
    else
    {
      writeRetract(Z);
    }

    Outputs.Z.reset();

    // if (newWorkPlane)
    // {
    //   writeComment("new workplane");
    //   forceWorkPlane();
    // }
  }

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
    }
  }
  
  if (properties.showNotes && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }
  
  if (insertToolCall) {
    forceWorkPlane();
    
    setCoolant(COOLANT_OFF);
  
    if (!isFirstSection() && properties.optionalStop) {
      onCommand(COMMAND_OPTIONAL_STOP);
    }

    if (tool.number > 99999999) {
      warning(localize("Tool number exceeds maximum value."));
    }

    writeBlock(Formats.M.format(5));

    var isManual = tool.manualToolChange; // tool.manualToolChange 
    var toolchangeMcode = isManual ? 66 : 6;

    // TODO: Implement this
    // If it is a manual tool change we need to remove the current tool from 
    // the spindle before doing the M66 change
    // if (!isFirstSection() && tool.number != getPreviousSection().getTool().number &&
    //     getPreviousSection().getTool().manualToolChange && isManual) {
    //       writeComment("remove tool from spindle");
    //       writeBlock("T" + Formats.Tool.format(0), Formats.M.format(6));
    //       writeRetract(Z);
    // }

    writeBlock("T" + Formats.Tool.format(tool.number), Formats.M.format(toolchangeMcode));
    if (tool.comment) {
      writeComment(tool.comment);
    }
    //writeComment(currentSection.getTool().description);
    //writeComment(currentSection.getTool().vendor);
    
    var showToolZMin = false;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
      }
    }

    // if (properties.preloadTool) {
    //   var nextTool = getNextTool(tool.number);
    //   if (nextTool) {
    //     writeBlock("T" + Formats.Tool.format(nextTool.number));
    //   } else {
    //     // preload first tool
    //     var section = getSection(0);
    //     var firstToolNumber = section.getTool().number;
    //     if (tool.number != firstToolNumber) {
    //       writeBlock("T" + Formats.Tool.format(firstToolNumber));
    //     }
    //   }
    // }
  }

  if (insertToolCall ||
      forceSpindleSpeed ||
      isFirstSection() ||
      Outputs.S.getCurrent() == undefined ||
      (Formats.RPM.areDifferent(spindleSpeed, Outputs.S.getCurrent())) ||
      (tool.clockwise != getPreviousSection().getTool().clockwise)) {
    forceSpindleSpeed = false;
    
    if (!isProbeOperation())
    {
      if (spindleSpeed < 1) {
        // error(localize("Spindle speed out of range."));
        // return;
      }
      // TODO: Check why getMaximumSpindleSpeed doesnt work?
      if (spindleSpeed.toPrecision(1) > 8000) { // machine specific
        error(localize("Spindle speed exceeds maximum value. Requested:" + spindleSpeed + ">" + machineConfiguration.getMaximumSpindleSpeed()));
      }
      writeBlock(
        Outputs.S.format(spindleSpeed), Formats.M.format(tool.clockwise ? 3 : 4)
      );
    }
  }

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    // if (properties.MC84 == 0) {
    //   warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    // } else {
    //   warningOnce(localize("Work offset has not been specified. Using G54 I1 as WCS."), WARNING_WORK_OFFSET);
    // }

    warning("Work Offset has not been specified!");

    workOffset = 1;
  }
  if (workOffset > 0) {
    if (properties.MC84 == 0) {
      if (workOffset > 6) {
        error(localize("Work offset out of range."));
        return;
      }
      if (workOffset != currentWorkOffset) {
        writeBlock(Formats.G.format(53 + workOffset)); // G54->G59
        currentWorkOffset = workOffset;
      }
    } else {
      if (workOffset > 99) {
        error(localize("Work offset out of range."));
        return;
      }
      if (workOffset != currentWorkOffset) {
        writeBlock(Formats.G.format(54), "I" + (workOffset));
        currentWorkOffset = workOffset;
      }
    }
    resetWorkOffset();
  }

  Outputs.ForceXYZ();

  if (!is3D() || machineConfiguration.isMultiAxisConfiguration() || newWorkPlane) { // use 5-axis indexing for multi-axis mode
    // set working plane after datum shift

    var abc = new Vector(0, 0, 0);
    var xyz = currentSection.workOrigin;
    cancelTransformation();
    if (!currentSection.isMultiAxis()) {
       //abc = getWorkPlaneMachineABC(currentSection.workPlane);
      abc = currentSection.workPlane.getEuler2(EULER_XYZ_S);
    }
    setWorkPlane(xyz, abc, true); // turn
    //writeBlock(Formats.G.format(93), "C3=1", "(Reset Axis)");
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }

  // set coolant after we have positioned at Z
  setCoolant(tool.coolant);

  Outputs.ForceAny();
  //forceAny();

  if (tool.lengthOffset != 0) {
    warningOnce(localize("Length offset is not supported."), WARNING_LENGTH_OFFSET);
  }
  
  // if (currentSection.isMultiAxis()) {
  //   writeBlock(Formats.G.format(141)); // TCPM - absolute positions
  // }

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (!retracted && !insertToolCall) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(Modals.GMotion.format(0), Outputs.Z.format(initialPosition.z));
    }
  }
  
  if (!machineConfiguration.isHeadConfiguration()) {
    writeBlock(Modals.AbsInc.format(90));
    writeBlock(
      Modals.GMotion.format(0), Outputs.X.format(initialPosition.x), Outputs.Y.format(initialPosition.y)
    );
    var z = Outputs.Z.format(initialPosition.z);
    if (z) {
      //writeBlock(Modals.GMotion.format(0), z);
    }
  } else {
    writeBlock(Modals.AbsInc.format(90));
    writeBlock(
      Modals.GMotion.format(0),
      Outputs.X.format(initialPosition.x),
      Outputs.Y.format(initialPosition.y),
      Outputs.Z.format(initialPosition.z)
    );
  }

  if (properties.useParametricFeed &&
      hasParameter("operation-strategy") &&
      (getParameter("operation-strategy") != "drill") && // legacy
      !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
    if (!insertToolCall &&
        activeMovements &&
        (getCurrentSectionId() > 0) &&
        ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }
  
  if (insertToolCall) {
    Modals.Plane.reset();
  }
}

var expandCycle;

function onDrilling(cycle) {
  onCounterBoring(cycle);
}

function onCounterBoring(cycle) {
  writeBlock(Modals.AbsInc.format(90));
  writeBlock(
    Modals.Cycle.format(81),
    "Z" + Formats.XYZ.format(-cycle.depth),
    "Y" + Formats.XYZ.format(cycle.retract - cycle.stock),
    conditional(cycle.clearance > cycle.retract, "B" + Formats.XYZ.format(cycle.clearance - cycle.retract)),
    conditional(cycle.dwell > 0, "X" + Formats.Sec.format(clamp(0.1, cycle.dwell, 900))),
    Outputs.Feed.format(cycle.feedrate)
  );
}

function onChipBreaking(cycle) {
  writeBlock(Modals.AbsInc.format(90));
  writeBlock(
    Modals.Cycle.format(83),
    "Z" + Formats.XYZ.format(-cycle.depth),
    "Y" + Formats.XYZ.format(cycle.retract - cycle.stock),
    conditional(cycle.clearance > cycle.retract, "B" + Formats.XYZ.format(cycle.clearance - cycle.retract)),
    "K" + Formats.XYZ.format(cycle.incrementalDepth),
    "I0",
    "J" + Formats.XYZ.format((cycle.chipBreakDistance != undefined) ? cycle.chipBreakDistance : machineParameters.chipBreakingDistance),
    "K1=" + cycle.plungesPerRetract,
    conditional(cycle.dwell > 0, "X" + Formats.Sec.format(clamp(0.1, cycle.dwell, 900))),
    Outputs.Feed.format(cycle.feedrate)
  );
}

function onDeepDrilling(cycle) {
  writeBlock(Modals.AbsInc.format(90));
  writeBlock(
    Modals.Cycle.format(83),
    "Z" + Formats.XYZ.format(-cycle.depth),
    "Y" + Formats.XYZ.format(cycle.retract - cycle.stock),
    conditional(cycle.clearance > cycle.retract, "B" + Formats.XYZ.format(cycle.clearance - cycle.retract)),
    "K" + Formats.XYZ.format(cycle.incrementalDepth),
    "I0",
    "J0",
    conditional(cycle.dwell > 0, "X" + Formats.Sec.format(clamp(0.1, cycle.dwell, 900))),
    Outputs.Feed.format(cycle.feedrate)
  );
}

function onLeftTapping(cycle) {
  writeBlock(Modals.AbsInc.format(90));
  writeBlock(
    Modals.Cycle.format(84),
    "Z" + Formats.XYZ.format(-cycle.depth),
    "Y" + Formats.XYZ.format(cycle.retract - cycle.stock),
    conditional(cycle.clearance > cycle.retract, "B" + Formats.XYZ.format(cycle.clearance - cycle.retract)),
    conditional(cycle.dwell > 0, "X" + Formats.Sec.format(clamp(0.1, cycle.dwell, 900))),
    // Outputs.Feed.format(cycle.feedrate),
    "J" + Formats.XYZ.format(tool.threadPitch),
    properties.isDmu50v ? "I1=1" : "I1"
  );
}

function onRightTapping(cycle) {
  writeBlock(Modals.AbsInc.format(90));
  writeBlock(
    Modals.Cycle.format(84),
    "Z" + Formats.XYZ.format(-cycle.depth),
    "Y" + Formats.XYZ.format(cycle.retract - cycle.stock),
    conditional(cycle.clearance > cycle.retract, "B" + Formats.XYZ.format(cycle.clearance - cycle.retract)),
    conditional(cycle.dwell > 0, "X" + Formats.Sec.format(clamp(0.1, cycle.dwell, 900))),
    // Outputs.Feed.format(cycle.feedrate),
    "J" + Formats.XYZ.format(tool.threadPitch),
    properties.isDmu50v ? "I1=1" : "I1"
  );
}

function onReaming(cycle) {
  onBoring(cycle);
}

function onStopBoring(cycle) {
  writeBlock(Modals.AbsInc.format(90));
  writeBlock(
    Modals.Cycle.format(86),
    "Z" + Formats.XYZ.format(-cycle.depth),
    "Y" + Formats.XYZ.format(cycle.retract - cycle.stock),
    conditional(cycle.clearance > cycle.retract, "B" + Formats.XYZ.format(cycle.clearance - cycle.retract)),
    conditional(cycle.dwell > 0, "X" + Formats.Sec.format(clamp(0.1, cycle.dwell, 900))),
    Outputs.Feed.format(cycle.feedrate)
  );
}

function onBoring(cycle) {
  writeBlock(Modals.AbsInc.format(90));
  writeBlock(
    Modals.Cycle.format(85),
    "Z" + Formats.XYZ.format(-cycle.depth),
    "Y" + Formats.XYZ.format(cycle.retract - cycle.stock),
    conditional(cycle.clearance > cycle.retract, "B" + Formats.XYZ.format(cycle.clearance - cycle.retract)),
    conditional(cycle.dwell > 0, "X" + Formats.Sec.format(clamp(0.1, cycle.dwell, 900))),
    Outputs.Feed.format(cycle.feedrate),
    conditional(cycle.retractFeedrate != cycle.feedrate, "F2=" + Formats.Feed.format(cycle.retractFeedrate))
  );
}

function onDwell(seconds) {
  if (seconds > 900) {
    warning(localize("Dwelling time is out of range."));
  }
  seconds = clamp(0.1, seconds, 900);
  writeBlock(Formats.G.format(4), "X" + Formats.Sec.format(seconds));
}

function onSpindleSpeed(spindleSpeed)
{
  writeBlock(Outputs.S.format(spindleSpeed));
}

function onCycle() {
  if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) 
  {
    expandCurrentCycle = properties.expandCycles;

    if (!expandCurrentCycle) 
    {
      cycleNotSupported();
    }

    return;
  }

  writeBlock(Modals.Plane.format(17));

  if (isProbeOperation())
  {
    return;
  }

  // go to the initial retract level
  if (getCurrentPosition().z > cycle.clearance) 
  {
    if (getNumberOfCyclePoints() > 0) 
    {
      var p = getCyclePoint(0);
      writeBlock(Modals.GMotion.format(0), Outputs.X.format(p.x), Outputs.Y.format(p.y));
    }
  }

  writeBlock(Modals.GMotion.format(0), Outputs.Z.format(cycle.clearance));
  setCurrentPositionZ(cycle.clearance);

  expandCycle = false;
  
  switch (cycleType) {
  case "drilling": // G81 style
    onDrilling(cycle);
    break;
  case "counter-boring":
    onCounterBoring(cycle);
    break;
  case "chip-breaking":
    onChipBreaking(cycle);
    break;
  case "deep-drilling":
    onDeepDrilling(cycle);
    break;
  case "tapping":
    if (tool.type == TOOL_TAP_LEFT_HAND) {
      onLeftTapping(cycle);
    } else {
      onRightTapping(cycle);
    }
    break;
  case "left-tapping":
    onLeftTapping(cycle);
    break;
  case "right-tapping":
    onRightTapping(cycle);
    break;
  case "back-boring":
    var revolutions = 0;
    if (cycle.dwell > 0) {
      revolutions = Outputs.S.getCurrent() * cycle.dwell/60;
    }
    writeBlock(Modals.AbsInc.format(90));
    writeBlock(
      Modals.Cycle.format(790),
      "L" + Formats.XYZ.format(cycle.backBoreDistance),
      "Z" + Formats.XYZ.format(-cycle.depth),
      "L1=" + Formats.XYZ.format(cycle.retract - cycle.stock),
      conditional(cycle.clearance > cycle.retract, "L2=" + Formats.XYZ.format(cycle.clearance - cycle.retract)),
      "C1=" + Formats.XYZ.format(cycle.shift),
      "C2=0",
      "D" + angleFormat.format(cycle.shiftDirection),
      conditional(revolutions > 0, "D3=" + revFormat.format(revolutions)),
      Outputs.Feed.format(cycle.feedrate)
    );
    break;
  case "reaming":
    onReaming(cycle);
    break;
  case "stop-boring":
    onStopBoring(cycle);
    break;
  case "fine-boring":
    expandCyclePoint(x, y, z);
    break;
  case "boring":
    onBoring(cycle);
    break;

  default:
    expandCycle = true;
  }
}

function protectedProbeMove(_cycle, x, y, z) 
{
  var _x = Outputs.X.format(x);
  var _y = Outputs.Y.format(y);
  var _z = Outputs.Z.format(z);

  if (_z && z >= getCurrentPosition().z) 
  {
    writeBlock(Formats.G.format(1), _z, getFeed(cycle.feedrate)); // protected positioning move
  }

  if (_x || _y) 
  {
    writeBlock(Formats.G.format(0), _x, _y); // protected positioning move
  }

  if (_z && z < getCurrentPosition().z) 
  {
    writeBlock(Formats.G.format(1), _z, getFeed(cycle.feedrate)); // protected positioning move
  }
}

function approach(value) {
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

function onCycleEnd() 
{
  expandCycle = false;
  Outputs.Z.reset();
  Modals.Cycle.reset();

  switch (cycleType) 
  {
  case "tapping":
    if (tool.type == TOOL_TAP_LEFT_HAND)
    {
      // not supported
    } 
    else 
    {
      onCommand(COMMAND_SPINDLE_CLOCKWISE);
    }
    break;

  case "left-tapping":
    // not supported
    break;

  case "right-tapping":
    onCommand(COMMAND_SPINDLE_CLOCKWISE);
    break;
  }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() 
{
  pendingRadiusCompensation = radiusCompensation;
}

var isRapid5dInPosition = true;
function setG0inPosition(activated) {
  if (isRapid5dInPosition != activated) {
    isRapid5dInPosition = activated;

    if (!isRapid5dInPosition) {
      writeBlock(Modals.GMotion.format(28), "I4=1 I5=1");
    }
    else {
      writeBlock(Modals.GMotion.format(28), "I4=0 I5=0");
    }
  }
}

function onRapid(_x, _y, _z) {
  setG0inPosition(true);

  var x = Outputs.X.format(_x);
  var y = Outputs.Y.format(_y);
  var z = Outputs.Z.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(Modals.GMotion.format(0), x, y, z);
    forceFeed();
  }
}

function onLinear(_x, _y, _z, feed) {
  setG0inPosition(true);

  if (pendingRadiusCompensation >= 0) {
    // ensure that we end at desired position when compensation is turned off
    Outputs.X.reset();
    Outputs.Y.reset();
  }
  var x = Outputs.X.format(_x);
  var y = Outputs.Y.format(_y);
  var z = Outputs.Z.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      if (tool.diameterOffset) {
        warningOnce(localize("Diameter offset is not supported."), WARNING_DIAMETER_OFFSET);
      }
      writeBlock(Modals.Plane.format(17));
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(Formats.G.format(41));
        writeBlock(Modals.GMotion.format(1), x, y, z, f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(Formats.G.format(42));
        writeBlock(Modals.GMotion.format(1), x, y, z, f);
        break;
      default:
        writeBlock(Formats.G.format(40));
        writeBlock(Modals.GMotion.format(1), x, y, z, f);
      }
    } else {
      writeBlock(Modals.GMotion.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(Modals.GMotion.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  if (currentSection.isOptimizedForMachine()) {
    //Outputs.ForceXYZ();
    //Outputs.ForceABC();

    var x = Outputs.X.format(_x);
    var y = Outputs.Y.format(_y);
    var z = Outputs.Z.format(_z);
    var a = Outputs.A.format(_a);
    var b = Outputs.B.format(_b);
    var c = Outputs.C.format(_c);

    if ((x || y || z) && (a || b || c)) {
      setG0inPosition(false);
    }
    else {
      setG0inPosition(true);
    }

    writeBlock(Modals.GMotion.format(0), x, y, z, a, b, c);
  } else {
    Outputs.ForceXYZ(); // required
    var x = Outputs.X.format(_x);
    var y = Outputs.Y.format(_y);
    var z = Outputs.Z.format(_z);
    var i = Outputs.TX.format(_a);
    var j = Outputs.TY.format(_b);
    var k = Outputs.TZ.format(_c);
    writeBlock(Modals.GMotion.format(0), x, y, z, i, j, k);
  }
  forceFeed();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  setG0inPosition(true);

  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }

  if (currentSection.isOptimizedForMachine()) {
    var x = Outputs.X.format(_x);
    var y = Outputs.Y.format(_y);
    var z = Outputs.Z.format(_z);
    var a = Outputs.A.format(_a);
    var b = Outputs.B.format(_b);
    var c = Outputs.C.format(_c);
    var f = getFeed(feed);
    writeBlock(Modals.GMotion.format(1), x, y, z, a, b, c, f);
  } else {
    Outputs.ForceXYZ(); // required
    var x = Outputs.X.format(_x);
    var y = Outputs.Y.format(_y);
    var z = Outputs.Z.format(_z);
    var i = Outputs.TX.format(_a);
    var j = Outputs.TY.format(_b);
    var k = Outputs.TZ.format(_c);
    var f = getFeed(feed);
    writeBlock(Modals.GMotion.format(1), x, y, z, i, j, k, f);
  }
}

// /** Adjust final point to lie exactly on circle. */
// function CircularData(_plane, _center, _end) {
//   // use Output variables, since last point could have been adjusted if previous move was circular
//   var start = new Vector(Outputs.X.getCurrent(), Outputs.Y.getCurrent(), Outputs.Y.getCurrent());
//   var saveStart = new Vector(start.x, start.y, start.z);
//   var center = new Vector(
//     Formats.XYZ.getResultingValue(_center.x),
//     Formats.XYZ.getResultingValue(_center.y),
//     Formats.XYZ.getResultingValue(_center.z)
//   );
//   var end = new Vector(_end.x, _end.y, _end.z);
//   switch (_plane) {
//   case PLANE_XY:
//     start.setZ(center.z);
//     end.setZ(center.z);
//     break;
//   case PLANE_ZX:
//     start.setY(center.y);
//     end.setY(center.y);
//     break;
//   case PLANE_YZ:
//     start.setX(center.x);
//     end.setX(center.x);
//     break;
//   default:
//     this.center = new Vector(_center.x, _center.y, _center.z);
//     this.start = new Vector(start.x, start.y, start.z);
//     this.end = new Vector(_end.x, _end.y, _end.z);
//     this.offset = Vector.diff(center, start);
//     this.radius = this.offset.length;
//     break;
//   }
//   this.start = new Vector(
//     Formats.XYZ.getResultingValue(start.x),
//     Formats.XYZ.getResultingValue(start.y),
//     Formats.XYZ.getResultingValue(start.z)
//   );
//   var temp = Vector.diff(center, start);
//   this.offset = new Vector(
//     Formats.XYZ.getResultingValue(temp.x),
//     Formats.XYZ.getResultingValue(temp.y),
//     Formats.XYZ.getResultingValue(temp.z)
//   );
//   this.center = Vector.sum(this.start, this.offset);
//   this.radius = this.offset.length;

//   temp = Vector.diff(end, center).normalized;
//   this.end = new Vector(
//     Formats.XYZ.getResultingValue(this.center.x + temp.x * this.radius),
//     Formats.XYZ.getResultingValue(this.center.y + temp.y * this.radius),
//     Formats.XYZ.getResultingValue(this.center.z + temp.z * this.radius)
//   );

//   switch (_plane) {
//   case PLANE_XY:
//     this.start.setZ(saveStart.z);
//     this.end.setZ(_end.z);
//     this.offset.setZ(0);
//     break;
//   case PLANE_ZX:
//     this.start.setY(saveStart.y);
//     this.end.setY(_end.y);
//     this.offset.setY(0);
//     break;
//   case PLANE_YZ:
//     this.start.setX(saveStart.x);
//     this.end.setX(_end.x);
//     this.offset.setX(0);
//     break;
//   }
// }


function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  writeBlock(Modals.AbsInc.format(90));
  var start = getCurrentPosition();

  // var circle = new CircularData(getCircularPlane(), new Vector(cx, cy, cz), new Vector(x, y, z));
  // x = circle.end.x;
  // y = circle.end.y;
  // z = circle.end.z;
  // cx = circle.center.x;
  // cy = circle.center.y;
  // cz = circle.center.z;
  
  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(Modals.GMotion.format(clockwise ? 2 : 3), Outputs.I.format(cx), Outputs.J.format(cy), "B5=360", getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(Modals.GMotion.format(clockwise ? 2 : 3), Outputs.I.format(cx), Outputs.K.format(cz), "B5=360", getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(Modals.GMotion.format(clockwise ? 2 : 3), Outputs.J.format(cy), Outputs.K.format(cz), "B5=360", getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else {
    Outputs.ForceXYZ();

    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(
        Modals.GMotion.format(clockwise ? 2 : 3), 
        Outputs.X.format(x), 
        Outputs.Y.format(y), 
        Outputs.Z.format(z), 
        Outputs.I.format(cx/*, 0*/), 
        Outputs.J.format(cy/*, 0*/), 
        getFeed(feed));

      break;
    case PLANE_ZX:
      if (isHelical()) {
        linearize(tolerance);
        return;
      }
      writeBlock(Modals.GMotion.format(clockwise ? 2 : 3), Outputs.X.format(x), Outputs.Z.format(z), Outputs.I.format(cx), Outputs.K.format(cz), getFeed(feed));
      break;
    case PLANE_YZ:
      if (isHelical()) {
        linearize(tolerance);
        return;
      }
      writeBlock(Modals.GMotion.format(clockwise ? 2 : 3), Outputs.Y.format(y), Outputs.Z.format(z), Outputs.J.format(cy), Outputs.K.format(cz), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var mapCommand = {
  COMMAND_STOP:0,
  COMMAND_OPTIONAL_STOP:1,
  COMMAND_END:30,
  COMMAND_SPINDLE_CLOCKWISE:3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE:4,
  COMMAND_STOP_SPINDLE:5,
  COMMAND_ORIENTATE_SPINDLE:19,
  COMMAND_LOAD_TOOL:6
};

function onCommand(command) 
{
  switch (command) 
  {
  case COMMAND_STOP:
    writeBlock(Formats.M.format(0));
    forceSpindleSpeed = true;
    return;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    return;
  case COMMAND_STOP_CHIP_TRANSPORT:
    return;
  case COMMAND_BREAK_CONTROL:
    return;
  case COMMAND_TOOL_MEASURE:
    return;
  }
  
  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];

  if (mcode != undefined)
   {
    writeBlock(Formats.M.format(mcode));
  } 
  else 
  {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() 
{
  if (isMultiAxis()) 
  {
    writeBlock(Formats.G.format(40));
  }

  if (!isLastSection() && (getNextSection().getTool().coolant != tool.coolant)) 
  {
    setCoolant(COOLANT_OFF);
  }

  writeBlock(Modals.Plane.format(17));
  Outputs.ForceAny();
  //forceAny();
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  if (arguments.length == 0) {
    error(localize("No axis specified for writeRetract()."));
    return;
  }
  var words = []; // store all retracted axes in an array
  for (var i = 0; i < arguments.length; ++i) {
    let instances = 0; // checks for duplicate retract calls
    for (var j = 0; j < arguments.length; ++j) {
      if (arguments[i] == arguments[j]) {
        ++instances;
      }
    }
    if (instances > 1) { // error if there are multiple retract calls for the same axis
      error(localize("Cannot retract the same axis twice in one line"));
      return;
    }
    switch (arguments[i]) {
    case X:
      words.push("X" + Formats.XYZ.format(machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : 0));
      break;
    case Y:
      words.push("Y" + Formats.XYZ.format(machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : 0));
      break;
    case Z:
      if (!properties.useG74retract)
      {
        var workpiece = getWorkpiece();
        var retractHeight = workpiece.upper.z + (properties.retractHeightAboveParts);        
        words.push("Z" + Formats.XYZ.format(retractHeight));
      }
      else
      {
        // words.push("Z" + Formats.XYZ.format(machineConfiguration.getRetractPlane()));
        words.push("Z" + Formats.XYZ.format(-1));
      }
      
      retracted = true; // specifies that the tool has been retracted to the safe plane
      break;
    default:
      error(localize("Bad axis specified for writeRetract()."));
      return;
    }
  }
  if (words.length > 0) {
    Modals.GMotion.reset();

    if (properties.useG74retract)
    {
      writeBlock(Formats.G.format(74), words, "L1"); // retract

      if (properties.isDmu50v)
      {
        writeBlock(Formats.G.format(74), "X1=1 Y1=1 K1 L1");
      }
    }
    else
    {
      writeBlock(Formats.G.format(0), words); // retract
    }
  }
  Outputs.Z.reset();
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;

function setCoolant(coolant) {
  var coolantCodes = getCoolantCodes(coolant);
  if (Array.isArray(coolantCodes)) {
    if (singleLineCoolant) {
      writeBlock(coolantCodes.join(getWordSeparator()));
    } else {
      for (var c in coolantCodes) {
        writeBlock(coolantCodes[c]);
      }
    }
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant) {
  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (isProbeOperation()) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode) {
    return undefined; // coolant is already active
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined)) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(Formats.M.format(coolantOff[i]));
      }
    } else {
      multipleCoolantBlocks.push(Formats.M.format(coolantOff));
    }
  }

  var m;
  var coolantCodes = {};
  for (var c in coolants) { // find required coolant codes into the coolants array
    if (coolants[c].id == coolant) {
      coolantCodes.on = coolants[c].on;
      if (coolants[c].off != undefined) {
        coolantCodes.off = coolants[c].off;
        break;
      } else {
        for (var i in coolants) {
          if (coolants[i].id == COOLANT_OFF) {
            coolantCodes.off = coolants[i].off;
            break;
          }
        }
      }
    }
  }
  if (coolant == COOLANT_OFF) {
    m = !coolantOff ? coolantCodes.off : coolantOff; // use the default coolant off command when an 'off' value is not specified
  } else {
    coolantOff = coolantCodes.off;
    m = coolantCodes.on;
  }

  if (!m) {
    onUnsupportedCoolant(coolant);
    m = 9;
  } else {
    if (Array.isArray(m)) {
      for (var i in m) {
        multipleCoolantBlocks.push(Formats.M.format(m[i]));
      }
    } else {
      multipleCoolantBlocks.push(Formats.M.format(m));
    }
    currentCoolantMode = coolant;
    return multipleCoolantBlocks; // return the single formatted coolant value
  }
  return undefined;
}

function onClose() 
{
  setCoolant(COOLANT_OFF);

  setG0inPosition(true);

  //writeRetract(Z);
  writeBlock(Formats.G.format(74), "Z-1 L1");
  
  if (properties.isDmu50v)
  {
    writeBlock(Formats.G.format(74), "X1=1 Y1=1 K1 L1");
  }

  setWorkPlane(new Vector(0, 0, 0), new Vector(0, 0, 0), true); // reset working plane

  if (machineConfiguration.hasHomePositionX() || machineConfiguration.hasHomePositionY()) 
  {
    writeRetract(X, Y);
  }

  if (properties.isDmu50v)
  {
  writeBlock(Formats.G.format(93), "C3=1");
  writeBlock(Formats.G.format(0), "B0 C0");
  }

  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);

  writeBlock(Formats.M.format(30)); // stop program, spindle stop, coolant off
}



// ## PROBING 

function onCyclePoint(x, y, z) 
{
  test_tsc_function();

  // if (isProbingCycle())
  // {
  //   writeComment("hello world");
  // }

  // if (isProbeOperation())
  // {
  //   writeBlock(Formats.M.format(27));
  //   protectedProbeMove(cycle, x, y, z);

  //   if (currentSection.workOffset == 0)
  //   {
  //     error("Probing requires a set Work Offset!");
  //   }
  // }

    // Probe is now prepositioned
  if (currentSection.getTool().getType() == TOOL_PROBE)
  {
    switch (cycleType)
    {
      case "probing-x":
        writeBlock(Formats.M.format(27));
        probing_x(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
    
      case "probing-y":
        writeBlock(Formats.M.format(27));
        probing_y(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
    
      case "probing-z":
        writeBlock(Formats.M.format(27));
        probing_z(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-xy-inner-corner":
        writeBlock(Formats.M.format(27));
        probing_xy_inner_corner(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-xy-outer-corner":
        writeBlock(Formats.M.format(27));
        probing_xy_outer_corner(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      
      case "probing-x-channel":
        writeBlock(Formats.M.format(27));
        probing_x_channel(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-y-channel":
        writeBlock(Formats.M.format(27));
        probing_y_channel(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-x-channel-with-island":
        writeBlock(Formats.M.format(27));
        probing_x_channel_with_island(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-y-channel-with-island":
        writeBlock(Formats.M.format(27));
        probing_y_channel_with_island(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-xy-rectangular-hole":
        writeBlock(Formats.M.format(27));
        probing_xy_rectangular_hole(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-xy-rectangular-hole-with-island":
        writeBlock(Formats.M.format(27));
        probing_xy_rectangular_hole_with_island(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-xy-rectangular-boss":
        writeBlock(Formats.M.format(27));
        probing_xy_rectangular_boss(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
        
      case "probing-xy-circular-boss":
        writeBlock(Formats.M.format(27));
        probing_xy_circular_boss(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-xy-circular-hole":
        writeBlock(Formats.M.format(27));
        probing_xy_circular_hole(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-x-wall":
        writeBlock(Formats.M.format(27));
        probing_x_wall(x, y, z);
        break;
      case "probing-y-wall":
        writeBlock(Formats.M.format(27));
        probing_y_wall(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      case "probing-y-plane-angle":
        writeBlock(Formats.M.format(27));
        probing_y_plane_angle(x, y, z);
        writeBlock(Formats.M.format(28));
        break;
      default:
        error("Probing cycle: " + cycleType + " not yet implemented");
    }
  }
  else
  {
    if (!expandCycle) 
        {
          Outputs.X.reset();
          Outputs.Y.reset();
          Outputs.Z.reset();
          writeBlock(
            Formats.G.format(79),
            Outputs.X.format(x),
            Outputs.Y.format(y),
            Outputs.Z.format(cycle.stock)
          );
        } 
        else 
        {
          expandCyclePoint(x, y, z);
        }
  }

  // } 
  // else if (!expandCycle) 
  // {
  //   Outputs.X.reset();
  //   Outputs.Y.reset();
  //   Outputs.Z.reset();
  //   writeBlock(
  //     Formats.G.format(79),
  //     Outputs.X.format(x),
  //     Outputs.Y.format(y),
  //     Outputs.Z.format(cycle.stock)
  //   );
  // } 
  // else 
  // {
  //   expandCyclePoint(x, y, z);
  // }
}

 function onRewindMachineEntry(_a, _b, _c) {
   writeComment("rewind");
   debug("rewind max");
   // reset the rotary encoder if supported to avoid large rewind
   if (true) { // disabled by default
   if ((Formats.ABC.getResultingValue(_c) == 0) && !Formats.ABC.areDifferent(getCurrentDirection().y,
 _b)) {
    writeBlock(Formats.G.format(93), "C3=1");
   // writeBlock(gAbsIncModal.format(91), gFormat.format(28), "C" + abcFormat.format(0));
   writeBlock(gAbsIncModal.format(90));
   return true;
   }
   }
   return false;
  }
 

function onMoveToSafeRetractPosition()
{
  writeComment("REWIND RETRACT START");
  writeBlock("M1");
  writeRetract(Z);
  writeComment("REWIND RETRACT END");
}

function onRotateAxes(x, y, z, a, b, c)
{
  writeComment("REWIND ROTATE AXES START");
  writeBlock("M1");
  Outputs.X.disable();
  Outputs.Y.disable();
  Outputs.Z.disable();
  onRapid5D(x, y, z, a, b, c);
  setCurrentABC(new Vector(a, b, c));
  Outputs.X.enable();
  Outputs.Y.enable();
  Outputs.Z.enable();
  writeComment("REWIND ROTATE AXES END");
}

// function onMoveToSafeRetractPosition() {
//   writeRetract(Z);
// }

// /** Rotate axes to new position above reentry position */
// function onRotateAxes(_x, _y, _z, _a, _b, _c) {
//   // position rotary axes
//   Outputs.X.disable();
//   Outputs.Y.disable();
//   Outputs.Z.disable();
//   invokeOnRapid5D(_x, _y, _z, _a, _b, _c);
//   setCurrentABC(new Vector(_a, _b, _c));
//   Outputs.X.enable();
//   Outputs.Y.enable();
//   Outputs.Z.enable();
// }

function onReturnFromSafeRetractPosition(_x, _y, _z) {
  // position in XY
  Outputs.ForceXYZ();
  Outputs.X.reset();
  Outputs.Y.reset();
  Outputs.Z.disable();
  invokeOnRapid(_x, _y, _z);

  // position in Z
  Outputs.Z.enable();
  invokeOnRapid(_x, _y, _z);
}


include("millplus2_probingextension2.js");
include("tsc_post_out.js");