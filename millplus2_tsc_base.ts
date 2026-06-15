declare function writeComment(comment : string) : void;
declare function writeBlock(...args: any[]): void;
declare function getCurrentPosition(): Vector
declare var unit : Number;

declare const MM : Number;
declare const DEG : Number;

declare class Map {};
declare var cycle: unknown;

// TODO: Remove again
declare var retracted: boolean;

declare class Vector { };
declare class Section { };

// declare class Vector
// {
//     public constructor();
//     public constructor(x: Number, y: Number, z: Number);

//     public getX(): Number;
//     public setX(x: Number): void;

//     public getY(): Number;
//     public setY(y: Number): void;

//     public getZ(): Number;
//     public setZ(z: Number): void;

//     /* 	Vector ()
 
//  	Vector (Number x, Number y, Number z)
 
// Number 	getX ()
 
//  	setX (Number x)
 
// Number 	getY ()
 
//  	setY (Number y)
 
// Number 	getZ ()
 
//  	setZ (Number z)
 
// Number 	getCoordinate (Integer coordinate)
 
//  	setCoordinate (Integer coordinate, Number value)
 
//  	add (Vector value)
 
//  	add (Number x, Number y, Number z)
 
//  	subtract (Vector value)
 
//  	subtract (Number x, Number y, Number z)
 
//  	multiply (Number value)
 
//  	divide (Number value)
 
// Boolean 	isNonZero ()
 
// Boolean 	isZero ()
 
// Number 	getXYAngle ()
 
// Number 	getZAngle ()
 
// Number 	getLength ()
 
// Number 	getLength2 ()
 
//  	normalize ()
 
// Vector 	getNormalized ()
 
//  	negate ()
 
// Vector 	getNegated ()
 
// Vector 	getAbsolute ()
 
// Number 	getMinimum ()
 
// Number 	getMaximum ()
 
// String 	toString ()
 
// Vector 	toDeg ()
 
// Vector 	toRad ()*/

// /* static Vector 	sum (Vector left, Vector right)
 
// static Vector 	diff (Vector left, Vector right)
 
// static Vector 	product (Vector left, Number right)
 
// static Number 	dot (Vector left, Vector right)
 
// static Number 	getAngle (Vector v1, Vector v2)
 
// static Vector 	cross (Vector left, Vector right)
 
// static Number 	getDistance (Vector left, Vector right)
 
// static Number 	getDistance2 (Vector left, Vector right)
 
// static Vector 	lerp (Vector left, Vector right, Number u)
 
// static Vector 	getBySpherical (Number xyAngle, Number zAngle, Number radius) */

// /*Number 	x
//  	The X coordinate.
 
// Number 	y
//  	The Y coordinate.
 
// Number 	z
//  	The Z coordinate.
 
// Number 	length
//  	The length of the vector.
 
// Number 	length2
//  	The square of the length of the vector.
 
// Vector 	negated
//  	The negated vector.
 
// Vector 	abs
//  	The vector with the absolute coordinates.
 
// Vector 	normalized
//  	The vector normalized to length 1.*/

// }

// declare class Section
// {
//     public unit: Number;
//     public workOrigin: Vector;
//     /*Matrix 	workPlane
//  	The work plane in the WCS.
 
// Vector 	wcsOrigin
//  	The work coordinate system (WCS) origin.
 
// Matrix 	wcsPlane
//  	The work coordinate system (WCS) plane.
 
// Integer 	workOffset
//  	The work offset corresponding to the WCS.
 
// Integer 	probeWorkOffset
//  	The work offset corresponding to the Probe WCS.
 
// Integer 	wcsIndex
//  	The index used in the WCS.
 
// String 	wcs
//  	The WCS.
 
// Integer 	dynamicWorkOffset
//  	the display coordinates. More...
 
// Boolean 	axisSubstitution
//  	Specifies that the section uses axis substitution.
 
// Number 	axisSubstitutionRadius
//  	Specifies the nominal axis substitution radius.
 
// Integer 	type
//  	Specifies the type of the section (TYPE_MILLING, TYPE_TURNING, or TYPE_JET).
 
// Integer 	quality
//  	Specifies the associated quality.
 
// Boolean 	tailstock
//  	Specifies that tailstock is used.
 
// Boolean 	partCatcher
//  	Specifies that part catcher should be activated if available.
 
// Integer 	spindle
//  	Specifies the active spindle.
 
// Map 	properties
//  	The operation properties.
 
// String 	strategy
//  	Specifies the strategy type of the section.*/

//      /*Integer 	getId ()
 
// PostPropertyMap::PropertyMap 	getOperationProperties ()
 
// optional< String > 	getStrategy ()
 
// Integer 	getNumberOfRecords ()
 
// Record 	getRecord (Integer id)
 
// Integer 	getJobId ()
 
// Integer 	getPatternId ()
 
// Integer 	getNumberOfPatternInstances ()
 
// Boolean 	isPatterned ()
 
// Integer 	getChannel ()
 
// Boolean 	getForceToolChange ()
 
// Boolean 	isOptional ()
 
// Integer 	getFirstCompensationOffset ()
 
// Tool 	getTool ()
 
// Integer 	getContent ()
 
// Boolean 	isMultiAxis ()
 
// Integer 	getUnit ()
 
// Integer 	getType ()
 
// Integer 	getQuality ()
 
// Integer 	getJetMode ()
 
// Boolean 	getTailstock ()
 
// Boolean 	getPartCatcher ()
 
// Integer 	getSpindle ()
 
// Integer 	getFeedMode ()
 
// Number 	getToolOrientation ()
 
// Vector 	getWorkOrigin ()
 
// Matrix 	getWorkPlane ()
 
// Boolean 	isXOriented ()
 
// Boolean 	isYOriented ()
 
// Boolean 	isZOriented ()
 
// Boolean 	isTopWorkPlane ()
 
// Vector 	getGlobalWorkOrigin ()
 
// Matrix 	getGlobalWorkPlane ()
 
// Integer 	getToolAxis ()
 
// Vector 	getWCSOrigin ()
 
// Matrix 	getWCSPlane ()
 
// Vector 	getDynamicWCSOrigin ()
 
// Matrix 	getDynamicWCSPlane ()
 
// Vector 	getFCSOrigin ()
 
// Matrix 	getFCSPlane ()
 
// Vector 	getModelOrigin ()
 
// Matrix 	getModelPlane ()
 
// Integer 	getWorkOffset ()
 
// Integer 	getProbeWorkOffset ()
 
// String 	getWCS ()
 
// Integer 	getWCSIndex ()
 
// Boolean 	hasDynamicWorkOffset ()
 
// Integer 	getDynamicWorkOffset ()
 
// Boolean 	getAxisSubstitution ()
 
// Number 	getAxisSubstitutionRadius ()
 
// Vector 	getGlobalPosition (Vector p)
 
// Vector 	getWCSPosition (Vector p)
 
// Vector 	getSectionPosition (Vector p)
 
// Number 	getMaximumSpindleSpeed ()
 
// Number 	getMaximumFeedrate ()
 
// Number 	getCuttingDistance ()
 
// Number 	getRapidDistance ()
 
// Integer 	getMovements ()
 
// Number 	getCycleTime ()
 
// Integer 	getNumberOfCyclePoints ()
 
// Range 	getZRange ()
 
// Range 	getGlobalZRange ()
 
// Range 	getGlobalRange (Vector direction)
 
// BoundingBox 	getBoundingBox ()
 
// BoundingBox 	getGlobalBoundingBox ()
 
// Boolean 	isCuttingMotionAwayFromRotary (Number distance, Number tolerance)
 
// Boolean 	hasWellDefinedPosition ()
 
// Vector 	getFirstPosition ()
 
// Vector 	getInitialPosition ()
 
// Vector 	getFinalPosition ()
 
// Vector 	getInitialToolAxis ()
 
// Vector 	getGlobalInitialToolAxis ()
 
// Vector 	getInitialToolAxisABC ()
 
// Vector 	getFinalToolAxis ()
 
// Vector 	getFinalToolAxisABC ()
 
// Vector 	getGlobalFinalToolAxis ()
 
// Boolean 	getInitialSpindleOn ()
 
// Number 	getInitialSpindleSpeed ()
 
// Boolean 	getFinalSpindleOn ()
 
// Number 	getFinalSpindleSpeed ()
 
// Number 	getMaximumTilt ()
 
// Vector 	getLowerToolAxisABC ()
 
// Vector 	getUpperToolAxisABC ()
 
// Boolean 	isOptimizedForMachine ()
 
// Integer 	getOptimizedTCPMode ()
 
// Boolean 	hasParameter (String name)
 
// Value 	getParameter (String name, Value defaultValue)
 
// Boolean 	hasCycle (String uri)
 
// Boolean 	hasAnyCycle ()
 
// Integer 	getNumberOfCyclesWithId (String uri)
 
// Integer 	getNumberOfCycles ()
 
// String 	getCycleId (Integer index)
 
// String 	getFirstCycle ()
 
// String 	getLastCycle ()
 
// Boolean 	doesStartWithCycle (String uri)
 
// Boolean 	doesEndWithCycle (String &_uri) noexcept
 
// Boolean 	doesStartWithCycleIgnoringPositioning (String uri)
 
// Boolean 	doesEndWithCycleIgnoringPositioning (String uri)
 
// Boolean 	doesStrictCycle (String uri)
 
// Boolean 	hasCycleParameter (Integer index, String name)
 
// Value 	getCycleParameter (Integer index, String name)
 
//  	optimizeMachineAnglesByMachine (MachineConfiguration machine, Integer optimizeType)
 
//  	optimize3DPositionsByMachine (MachineConfiguration machine, Vector abc, Integer optimizeType)
 
// Boolean 	checkGroup (Integer groups)*/
// }

declare class Format 
{
    constructor (specifiers: Map)
    public format(value: Number) : string;
    public getResultingValue(value: Number) : Number;
    public getError(value: Number) : Number;
    public isSignificant(value: Number) : boolean;
    public areDifferent(a: Number, b: Number) : Boolean;
    public getMinimumValue() : Number;
}

declare class Variable
{
    constructor (specifiers: Map, format: Format)
    public format(value: Number) : string;
    public getPrefix() : any;
    public setPrefix(prefix: any): any;
    public disable(): void;
    public reset(): void;
    public getCurrent(): any;
}

declare class Modal
{
    constructor (specifiers: Map, format: Format);
    public format (value: Boolean) : string;
    //public format (value: Integer) : string;
    public format (value: Number) : string;
    public format (value: String) : string;
    
    public getPrefix(): Boolean;
    //public getPrefix(): Integer; 
    public getPrefix(): Number; 
    public getPrefix(): String;  
    
    public setPrefix(prefix: Boolean) : void;
    //public setPrefix(prefix: Integer) : void;
    public setPrefix(prefix: Number) : void;
    public setPrefix(prefix: String) : void;
    
    public getSuffix() : Boolean;
    //public getSuffix() : Integer;
    public getSuffix() : Number;
    public getSuffix() : String;
    
    public setSuffix(suffix : Boolean) : void;
    //public setSuffix(suffix : Integer) : void;
    public setSuffix(suffix : Number) : void;
    public setSuffix(suffix : String) : void;
    
    public reset() : void;
    
    public getCurrent() : Boolean; 
    //public getCurrent() : Integer; 
    public getCurrent() : Number; 
    public getCurrent() : String; 
}

declare function createVariable(specifiers: Map, XYZ: Format): Variable;
declare function createFormat(specifiers: Map): Format;
declare function createModal(specifiers: Map, format: Format): Modal;

namespace Formats
{
    export const G = createFormat({ prefix: "G", decimals: 0 });
    export const M = createFormat({ prefix: "M", decimals: 0 });
    export const H = createFormat({ prefix: "H", decimals: 0 });
    export const D = createFormat({ prefix: "D", decimals: 0 });
    export const T = createFormat({ decimals: 6, forceDecimal: true, scale: 100}); // unitless   
    export const XYZ = createFormat({ decimals: (unit == MM ? 3 : 4)});
    export const ABC = createFormat({ decimals: 3, forceDecimal: true, scale: DEG, trim: false});
    export const Feed = createFormat({ decimals: (unit == MM ? 1 : 2)});
    export const Tool = createFormat({ decimals: 0});
    export const RPM = createFormat({ decimals: 0});
    export const Sec = createFormat({ decimals: 1}); // seconds - range 0.1-900
    export const Taper = createFormat({ decimals: 1, scale: DEG});
    export const X1 = createFormat({ prefix:"X1=", decimals:3 });
    export const R = createFormat({ prefix: "R", decimals: 3 });
}

namespace Modals
{
    export const GMotion = createModal({force: true}, Formats.G); // modal group 1 // G0-G3, ...
    export const Plane = createModal({onchange: function () { GMotion.reset(); }}, Formats.G); // modal group 2 // G17-19
    export const AbsInc = createModal({}, Formats.G); // modal group 3 // G90-91
    export const FeedMode = createModal({}, Formats.G); // modal group 5 // G94-95
    export const Unit = createModal({}, Formats.G); // modal group 6 // G70-71
    export const Cycle = createModal({}, Formats.G); // modal group 9 // G81, ...
}

namespace Outputs
{
    export const X = createVariable({ prefix: "X" }, Formats.XYZ);
    export const Y = createVariable({prefix:"Y"}, Formats.XYZ);
    export const Z = createVariable({onchange:function () {retracted = false;}, prefix:"Z"}, Formats.XYZ);

    export const A = createVariable({prefix:"A"}, Formats.ABC);
    export const B = createVariable({prefix:"B"}, Formats.ABC);
    export const C = createVariable({prefix:"C"}, Formats.ABC);

    export const I = createVariable({prefix:"I", force:true}, Formats.XYZ);
    export const J = createVariable({prefix:"J", force:true}, Formats.XYZ);
    export const K = createVariable({prefix:"K", force:true}, Formats.XYZ);

    export const TX = createVariable({prefix:"I1=", force:true}, Formats.T);
    export const TY = createVariable({prefix:"J1=", force:true}, Formats.T);
    export const TZ = createVariable({prefix:"K1=", force:true}, Formats.T);

    export const Feed = createVariable({prefix:"F"}, Formats.Feed);
    export const S = createVariable({prefix:"S", force:true}, Formats.RPM);

    export function ForceXYZ() : void
    {
        X.reset();
        Y.reset();
        Z.reset();
    }

    export function ForceABC(): void
    {
        A.reset();
        B.reset();
        C.reset();
    }

    export function ForceFeed(): void
    {
        // TODO: Add and replace variable to here
        // currentFeedId = undefined;
        Feed.reset();
    }

    export function ForceAny(): void
    {
        ForceXYZ();
        ForceABC();
        ForceFeed();
    }
}

namespace Millplus
{
    export enum Axis 
    {
        X = 1 << 1,
        Y = 1 << 2,
        Z = 1 << 3,
        A = 1 << 4,
        B = 1 << 5,
        C = 1 << 6
    }

    export enum Direction 
    {
        Positive,
        Negative
    }

    export class Functions
    {
        public static G45(
            measurementAxis: Axis, 
            direction: Direction, 
            x: Number, 
            y: Number, 
            z: Number, 
            clearance: Number, 
            eParameter: string)
        {
            let approach = "";

            switch (measurementAxis)
            {
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

            switch (direction)
            {
                case Direction.Negative:
                    approach += "-1";
                    break;

                case Direction.Positive:
                    approach += "+1";
                    break;
            }

            writeBlock(
                Formats.G.format(45),
                Outputs.X.format(x),
                Outputs.Y.format(y),
                Outputs.Z.format(z),
                approach,
                Formats.X1.format(clearance),
                eParameter);
        }

        public static G50(axis: Axis, workoffsetFormatted: string): void
        {
            writeBlock(
                Formats.G.format(50),
                "N=54." + workoffsetFormatted,
                (axis & Axis.X) === Axis.X ? "X1" : "",
                (axis & Axis.Y) === Axis.Y ? "Y1" : "",
                (axis & Axis.Z) === Axis.Z ? "Z1" : "",
                (axis & Axis.A) === Axis.A ? "A1" : "",
                (axis & Axis.B) === Axis.B ? "B1" : "",
                (axis & Axis.C) === Axis.C ? "C1" : "");
        }

        public static G54(workOffset: Number): void
        {
            writeBlock(
                Formats.G.format(54), 
                "I" + workOffset.toString());
        }
    }

    export class Movements
    {
        public static RapidZThenXY(x: Number, y: Number, z: Number): void
        {
            Outputs.ForceXYZ();

            writeBlock(Formats.G.format(0), Outputs.Z.format(z));
            writeBlock(Formats.G.format(0), Outputs.X.format(x), Outputs.Y.format(y));
        }

        // public static ProtectedProbeMove(x: Number, y: Number, z: Number): void
        // {
        //     var _x = Outputs.X.format(x);
        //     var _y = Outputs.Y.format(y);
        //     var _z = Outputs.Z.format(z);
          
        //     if (_z && z >= getCurrentPosition().z) 
        //     {
        //       writeBlock(Formats.G.format(1), _z, getFeed(cycle.feedrate)); // protected positioning move
        //     }
          
        //     if (_x || _y) 
        //     {
        //       writeBlock(Formats.G.format(0), _x, _y); // protected positioning move
        //     }
          
        //     if (_z && z < getCurrentPosition().z) 
        //     {
        //       writeBlock(Formats.G.format(1), _z, getFeed(cycle.feedrate)); // protected positioning move
        //     }
        // }
    }

    export class Probing
    {
        public static Probe_RectangularBoss(): void
        {
            writeComment("Probe Rectangular Boss");
        }
        // public static Probe_X(x: Number, y: Number, z: Number, cycle: Map, workOffset: Number): void
        // {
        //     writeComment("Probe X");
        //     protectedProbeMove(cycle, x, y, z - cycle.depth);
          
        //     Outputs.ForceXYZ();
          
        //     var workoffsetFormatted = workOffset < 10 ? "0" + workOffset : workOffset.toString();
        //     var approachDirection = cycle.approach1 == "positive" ? Millplus.Direction.Positive : Millplus.Direction.Negative; 
        //     var resultingCoordinate = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
        //     var probeZ = z - cycle.depth;

        //     Millplus.Functions.G45(Millplus.Axis.X, approachDirection, resultingCoordinate, y, probeZ, cycle.probeClearance, "E90");
        //     Millplus.Functions.G50(Millplus.Axis.X, workoffsetFormatted);  
        //     Millplus.Functions.G54(workOffset);
        // };
    }
}

function test_tsc_function()
{
    //Millplus.Functions.G50(Millplus.Axis.X, "");
    //writeComment("Hello World");
    //writeComment(Formats.G.format(1));
    //writeComment(Modals.GMotion.format(4));
    //writeComment(Modals.GMotion.format(4));
    //writeComment(Modals.GMotion.format(1));

    //let format = createFormat(null);
}