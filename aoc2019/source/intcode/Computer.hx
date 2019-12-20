package intcode;

import flixel.util.FlxSort;
import haxe.Int64Helper;
import haxe.Int64;

using StringTools;

class Computer
{
    private static inline final OP_ADD:String = "01";
    private static inline final OP_MULTIPLY:String = "02";
    private static inline final OP_INPUT:String = "03";
    private static inline final OP_OUTPUT:String = "04";
    private static inline final OP_JUMP_IF_TRUE:String = "05";
    private static inline final OP_JUMP_IF_FALSE:String = "06";
    private static inline final OP_LESS_THAN:String = "07";
    private static inline final OP_EQUALS:String = "08";
    private static inline final OP_ADJUST_BASE:String = "09";
    private static inline final OP_TERMINATE:String = "99";

    private static inline final MODE_POSITION:Int = 0;
    private static inline final MODE_IMMEDIATE:Int = 1;
    private static inline final MODE_RELATIVE:Int = 2;

    public static inline final STATE_ERROR:Int = -2;
    public static inline final STATE_READY:Int = -1;
    public static inline final STATE_FINISHED:Int = 0;
    public static inline final STATE_RUNNING:Int = 1;
    public static inline final STATE_WAITING:Int = 2;

    public var state(default, null):Int = STATE_FINISHED;

    private var program:Map<String, Int64>; // Array<Int64>;
    private var originalProgram:String = "";

    private var pos:Int64 = 0;

    public var outputs:Array<Int64>;

    private var inputs:Array<Int64>;
    private var stop:Bool = false;

    private var relativeBase:Int64 = 0;

    public function new(Program:String, ?Pos:Int64, ?InitialState:Int = STATE_READY, ?RelativeBase:Int64)
    {
        originalProgram = Program;
        reset(false, Pos, InitialState, RelativeBase);
    }

    private function mainLoop():Void
    {
        state = STATE_RUNNING;
        do
        {
            readInstruction();
        }
        while (pos >= 0 && !stop);
    }

    public function reset(?KeepChangedProgram = false, ?Pos:Int64, ?InitialState:Int = STATE_ERROR, ?RelativeBase:Int64):Void
    {
        if (!KeepChangedProgram)
        {
            var s:Array<String> = originalProgram.split(",");
            program = [];
            for (i in 0...s.length)
            {
                program.set(Std.string(i), Int64.parseString(s[i]));
            }
        }

        outputs = [];
        pos = Pos == null ? Int64.ofInt(0) : Pos;
        relativeBase = RelativeBase == null ? Int64.ofInt(0) : RelativeBase;
        state = InitialState;
    }

    public function start(?Inputs:Array<Int64> = null):Void
    {
        if (Inputs != null)
            inputs = Inputs.copy();
        else
            Inputs = [];
        stop = false;
        mainLoop();
    }

    private function readInstruction():Void
    {
        var inst:String = getInstruction();
        var opcode:String = inst.substr(-2, 2);
        var modes:Array<Int> = inst.substr(0, 3).split("").map(function(v) return Std.parseInt(v));
        modes.reverse();

        var params:Array<Int64> = [0, 0, 0];
        params[0] = getParamAddress(0, modes[0]);
        params[1] = getParamAddress(1, modes[1]);
        params[2] = getParamAddress(2, modes[2]);

        // PlayState.addOutput(pos, opcode, modes, relativeBase, params, params.map(function(v) return getValue(v)));

        switch (opcode)
        {
            case OP_ADD:
                add(params[0], params[1], params[2]);
                pos += 4;
            case OP_MULTIPLY:
                multiply(params[0], params[1], params[2]);
                pos += 4;
            case OP_INPUT:
                if (inputs != null && inputs.length > 0)
                {
                    params[1] = inputs.shift();

                    input(params[0], params[1]);
                    pos += 2;
                }
                else
                {
                    stop = true;
                    state = STATE_WAITING;
                }
            case OP_OUTPUT:
                output(params[0]);
                pos += 2;
            case OP_JUMP_IF_TRUE:
                if (getValue(params[0]) != 0)
                    pos = getValue(params[1]);
                else
                    pos += 3;
            case OP_JUMP_IF_FALSE:
                if (getValue(params[0]) == 0)
                    pos = getValue(params[1]);
                else
                    pos += 3;
            case OP_LESS_THAN:
                lessThan(params[0], params[1], params[2]);
                pos += 4;
            case OP_EQUALS:
                equals(params[0], params[1], params[2]);
                pos += 4;
            case OP_ADJUST_BASE:
                relativeBase += getValue(params[0]);
                pos += 2;
            case OP_TERMINATE:
                state = STATE_FINISHED;
                stop = true;
                pos = -1;
            default:
                throw("Error: Invalid Command: " + pos + " - " + opcode);
                state = STATE_ERROR;
                stop = true;
                pos = -1;
        }
    }

    private function getInstruction():String
    {
        var inst:Int64 = 0;
        if (program.exists(Int64.toStr(pos)))
            inst = program.get(Int64.toStr(pos));
        return Int64.toStr(inst).lpad("0", 5);
    }

    private function getValue(Pos:Int64):Int64
    {
        var v:Int64 = 0;
        if (program.exists(Int64.toStr(Pos)))
            v = program.get(Int64.toStr(Pos));
        return v;
    }

    public function setValue(Pos:Int64, Value:Int64):Void
    {
        program.set(Int64.toStr(Pos), Value);
    }

    private function getParamAddress(Which:Int, Mode:Int):Int64
    {
        var v:Int64 = switch (Mode)
        {
            case MODE_POSITION:
                getValue(pos + 1 + Which);
            case MODE_IMMEDIATE:
                pos + 1 + Which;
            case MODE_RELATIVE:
                getValue(pos + 1 + Which) + relativeBase;
            default:
                0;
        }

        return v;
    }

    private function add(A:Int64, B:Int64, Out:Int64):Void
    {
        setValue(Out, Int64.add(getValue(A), getValue(B)));
    }

    private function multiply(A:Int64, B:Int64, Out:Int64):Void
    {
        setValue(Out, Int64.mul(getValue(A), getValue(B)));
    }

    private function input(Out:Int64, A:Int64):Void
    {
        setValue(Out, A);
    }

    private function output(A:Int64):Void
    {
        outputs.push(getValue(A));
    }

    private function lessThan(A:Int64, B:Int64, Out:Int64):Void
    {
        setValue(Out, Int64.compare(getValue(A), getValue(B)) < 0 ? 1 : 0);
    }

    private function equals(A:Int64, B:Int64, Out:Int64):Void
    {
        setValue(Out, Int64.compare(getValue(A), getValue(B)) == 0 ? 1 : 0);
    }

    public function clone():Computer
    {
        return new Computer(codeToString(), pos, state, relativeBase);
    }

    private function codeToString():String
    {
        var s:Array<Int64> = [];
        var keys = [for (key in program.keys()) key];
        keys.sort(sortByValue);
        for (k in keys)
        {
            s.push(program.get(k));
        }
        return s.join(",");
    }

    private function sortByValue(A:String, B:String):Int
    {
        return FlxSort.byValues(FlxSort.ASCENDING, Std.parseFloat(A), Std.parseFloat(B));
    }
}
