;
;
;
var Formats;
(function (Formats) {
    Formats.G = createFormat({ prefix: "G", decimals: 0 });
    Formats.M = createFormat({ prefix: "M", decimals: 0 });
    Formats.H = createFormat({ prefix: "H", decimals: 0 });
    Formats.D = createFormat({ prefix: "D", decimals: 0 });
    Formats.T = createFormat({ decimals: 6, forceDecimal: true, scale: 100 }); // unitless   
    Formats.XYZ = createFormat({ decimals: (unit == MM ? 3 : 4) });
    Formats.ABC = createFormat({ decimals: 3, forceDecimal: true, scale: DEG, trim: false });
    Formats.Feed = createFormat({ decimals: (unit == MM ? 1 : 2) });
    Formats.Tool = createFormat({ decimals: 0 });
    Formats.RPM = createFormat({ decimals: 0 });
    Formats.Sec = createFormat({ decimals: 1 }); // seconds - range 0.1-900
    Formats.Taper = createFormat({ decimals: 1, scale: DEG });
    Formats.X1 = createFormat({ prefix: "X1=", decimals: 3 });
    Formats.R = createFormat({ prefix: "R", decimals: 3 });
})(Formats || (Formats = {}));
var Modals;
(function (Modals) {
    Modals.GMotion = createModal({ force: true }, Formats.G); // modal group 1 // G0-G3, ...
    Modals.Plane = createModal({ onchange: function () { Modals.GMotion.reset(); } }, Formats.G); // modal group 2 // G17-19
    Modals.AbsInc = createModal({}, Formats.G); // modal group 3 // G90-91
    Modals.FeedMode = createModal({}, Formats.G); // modal group 5 // G94-95
    Modals.Unit = createModal({}, Formats.G); // modal group 6 // G70-71
    Modals.Cycle = createModal({}, Formats.G); // modal group 9 // G81, ...
})(Modals || (Modals = {}));
var Outputs;
(function (Outputs) {
    Outputs.X = createVariable({ prefix: "X" }, Formats.XYZ);
    Outputs.Y = createVariable({ prefix: "Y" }, Formats.XYZ);
    Outputs.Z = createVariable({ onchange: function () { retracted = false; }, prefix: "Z" }, Formats.XYZ);
    Outputs.A = createVariable({ prefix: "A" }, Formats.ABC);
    Outputs.B = createVariable({ prefix: "B" }, Formats.ABC);
    Outputs.C = createVariable({ prefix: "C" }, Formats.ABC);
    Outputs.I = createVariable({ prefix: "I", force: true }, Formats.XYZ);
    Outputs.J = createVariable({ prefix: "J", force: true }, Formats.XYZ);
    Outputs.K = createVariable({ prefix: "K", force: true }, Formats.XYZ);
    Outputs.TX = createVariable({ prefix: "I1=", force: true }, Formats.T);
    Outputs.TY = createVariable({ prefix: "J1=", force: true }, Formats.T);
    Outputs.TZ = createVariable({ prefix: "K1=", force: true }, Formats.T);
    Outputs.Feed = createVariable({ prefix: "F" }, Formats.Feed);
    Outputs.S = createVariable({ prefix: "S", force: true }, Formats.RPM);
    function ForceXYZ() {
        Outputs.X.reset();
        Outputs.Y.reset();
        Outputs.Z.reset();
    }
    Outputs.ForceXYZ = ForceXYZ;
    function ForceABC() {
        Outputs.A.reset();
        Outputs.B.reset();
        Outputs.C.reset();
    }
    Outputs.ForceABC = ForceABC;
    function ForceFeed() {
        // TODO: Add and replace variable to here
        // currentFeedId = undefined;
        Outputs.Feed.reset();
    }
    Outputs.ForceFeed = ForceFeed;
    function ForceAny() {
        ForceXYZ();
        ForceABC();
        ForceFeed();
    }
    Outputs.ForceAny = ForceAny;
})(Outputs || (Outputs = {}));
var Millplus;
(function (Millplus) {
    var Axis;
    (function (Axis) {
        Axis[Axis["X"] = 2] = "X";
        Axis[Axis["Y"] = 4] = "Y";
        Axis[Axis["Z"] = 8] = "Z";
        Axis[Axis["A"] = 16] = "A";
        Axis[Axis["B"] = 32] = "B";
        Axis[Axis["C"] = 64] = "C";
    })(Axis = Millplus.Axis || (Millplus.Axis = {}));
    var Direction;
    (function (Direction) {
        Direction[Direction["Positive"] = 0] = "Positive";
        Direction[Direction["Negative"] = 1] = "Negative";
    })(Direction = Millplus.Direction || (Millplus.Direction = {}));
    var Functions = /** @class */ (function () {
        function Functions() {
        }
        Functions.G45 = function (measurementAxis, direction, x, y, z, clearance, eParameter) {
            var approach = "";
            switch (measurementAxis) {
                case Axis.X:
                    approach += "I";
                    break;
                case Axis.Y:
                    approach += "J";
                    break;
                case Axis.Z:
                    approach += "K";
                    break;
            }
            switch (direction) {
                case Direction.Negative:
                    approach += "-1";
                    break;
                case Direction.Positive:
                    approach += "+1";
                    break;
            }
            writeBlock(Formats.G.format(45), Outputs.X.format(x), Outputs.Y.format(y), Outputs.Z.format(z), approach, Formats.X1.format(clearance), eParameter);
        };
        Functions.G50 = function (axis, workoffsetFormatted) {
            writeBlock(Formats.G.format(50), "N=54." + workoffsetFormatted, (axis & Axis.X) === Axis.X ? "X1" : "", (axis & Axis.Y) === Axis.Y ? "Y1" : "", (axis & Axis.Z) === Axis.Z ? "Z1" : "", (axis & Axis.A) === Axis.A ? "A1" : "", (axis & Axis.B) === Axis.B ? "B1" : "", (axis & Axis.C) === Axis.C ? "C1" : "");
            writeComment("asdasd");
        };
        Functions.G54 = function (workOffset) {
            writeBlock(Formats.G.format(54), "I" + workOffset.toString());
        };
        return Functions;
    }());
    Millplus.Functions = Functions;
    var Movements = /** @class */ (function () {
        function Movements() {
        }
        Movements.RapidZThenXY = function (x, y, z) {
            Outputs.ForceXYZ();
            writeBlock(Formats.G.format(0), Outputs.Z.format(z));
            writeBlock(Formats.G.format(0), Outputs.X.format(x), Outputs.Y.format(y));
        };
        return Movements;
    }());
    Millplus.Movements = Movements;
    var Probing = /** @class */ (function () {
        function Probing() {
        }
        Probing.Probe_RectangularBoss = function () {
            writeComment("Probe Rectangular Boss");
        };
        return Probing;
    }());
    Millplus.Probing = Probing;
})(Millplus || (Millplus = {}));
function test_tsc_function() {
    //Millplus.Functions.G50(Millplus.Axis.X, "");
    //writeComment("Hello World");
    //writeComment(Formats.G.format(1));
    //writeComment(Modals.GMotion.format(4));
    //writeComment(Modals.GMotion.format(4));
    //writeComment(Modals.GMotion.format(1));
    //let format = createFormat(null);
}
