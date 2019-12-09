package intcode;

import haxe.io.Error;

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
    private static inline final OP_TERMINATE:String = "99";

    private static inline final MODE_POSITION:Int = 0;
    private static inline final MODE_IMMEDIATE:Int = 1;

    public static inline final STATE_ERROR:Int = -2;
    public static inline final STATE_READY:Int = -1;
    public static inline final STATE_FINISHED:Int = 0;
    public static inline final STATE_RUNNING:Int = 1;
    public static inline final STATE_WAITING:Int = 2;

    public var state(default, null):Int = STATE_FINISHED;

    private var program:Array<Int>;
    private var originalProgram:String = "";

    private var pos:Int;

    public var outputs:Array<Int>;

    private var inputs:Array<Int>;
    private var stop:Bool = false;

    public function new(Program:String)
    {
        originalProgram = Program;
        program = originalProgram.split(",").map(function(v) return Std.parseInt(v));
        reset();
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

    public function reset(?KeepChangedProgram = false):Void
    {
        if (!KeepChangedProgram)
            program = originalProgram.split(",").map(function(v) return Std.parseInt(v));
        outputs = [];
        pos = 0;
        state = STATE_READY;
    }

    public function start(?Inputs:Array<Int> = null):Void
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
        var inst:String = Std.string(program[pos]).lpad("0", 5);
        var opcode:String = inst.substr(-2, 2);
        var modes:Array<Int> = inst.substr(0, 3).split("").map(function(v) return Std.parseInt(v));
        modes.reverse();
        var params:Array<Int> = [0, 0, 0];

        //  trace(pos, opcode, modes, params);

        switch (opcode)
        {
            case OP_ADD:
                params[0] = modes[0] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];
                params[2] = program[pos + 3];

                add(params[0], params[1], params[2]);

                pos += 4;
            case OP_MULTIPLY:
                params[0] = modes[0] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];
                params[2] = program[pos + 3];

                multiply(params[0], params[1], params[2]);

                pos += 4;
            case OP_INPUT:
                if (inputs.length > 0)
                {
                    params[0] = inputs.shift();
                    params[1] = program[pos + 1];

                    input(params[0], params[1]);
                    pos += 2;
                    state = STATE_WAITING;
                }
                else
                    stop = true;
            case OP_OUTPUT:
                params[0] = modes[0] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];

                output(params[0]);
                pos += 2;
            case OP_JUMP_IF_TRUE:
                params[0] = modes[0] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];

                if (params[0] != 0)
                    pos = params[1];
                else
                    pos += 3;
            case OP_JUMP_IF_FALSE:
                params[0] = modes[0] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];

                if (params[0] == 0)
                    pos = params[1];
                else
                    pos += 3;
            case OP_LESS_THAN:
                params[0] = modes[0] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];
                params[2] = program[pos + 3];

                lessThan(params[0], params[1], params[2]);

                pos += 4;
            case OP_EQUALS:
                params[0] = modes[0] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];
                params[2] = program[pos + 3];

                equals(params[0], params[1], params[2]);

                pos += 4;
            case OP_TERMINATE:
                state = STATE_FINISHED;
                pos = -1;
            default:
                throw("Error: Invalid Command: " + pos + " - " + opcode);
                state = STATE_ERROR;
                pos = -1;
        }
    }

    private function add(A:Int, B:Int, Out:Int):Void
    {
        program[Out] = A + B;
    }

    private function multiply(A:Int, B:Int, Out:Int):Void
    {
        program[Out] = A * B;
    }

    private function input(A:Int, Out:Int):Void
    {
        program[Out] = A;
    }

    private function output(A:Int):Void
    {
        outputs.push(A);
    }

    private function lessThan(A:Int, B:Int, Out:Int):Void
    {
        program[Out] = A < B ? 1 : 0;
    }

    private function equals(A:Int, B:Int, Out:Int):Void
    {
        program[Out] = A == B ? 1 : 0;
    }
}
