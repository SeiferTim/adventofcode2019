package intcode;

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

    private static var program:Array<Int>;

    private static var pos:Int;
    private static var outputs:Array<Int>;

    public static function process(Program:String, ?Input:Int = 0):String
    {
        program = Program.split(",").map(function(v) return Std.parseInt(v));
        outputs = [];
        pos = 0;

        do
        {
            readInstruction(Input);
        }
        while (pos >= 0);

        return outputs.join(",");
    }

    private static function readInstruction(Input:Int):Void
    {
        var inst:String = Std.string(program[pos]).lpad("0", 5);
        var opcode:String = inst.substr(-2, 2);
        var modes:Array<Int> = inst.substr(0, 3).split("").map(function(v) return Std.parseInt(v));
        var params:Array<Int> = [0, 0, 0];

        switch (opcode)
        {
            case OP_ADD:
                params[0] = modes[2] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];
                params[2] = program[pos + 3];
                trace(pos, opcode, params);
                add(params[0], params[1], params[2]);
                trace(program[params[2]]);
                pos += 4;
            case OP_MULTIPLY:
                params[0] = modes[2] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];
                params[2] = program[pos + 3];
                trace(pos, opcode, params);
                multiply(params[0], params[1], params[2]);
                trace(program[params[2]]);
                pos += 4;
            case OP_INPUT:
                params[0] = Input;
                params[1] = program[pos + 1];
                trace(pos, opcode, params);
                input(params[0], params[1]);
                trace(program[params[1]]);
                pos += 2;
            case OP_OUTPUT:
                params[0] = modes[2] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                trace(pos, opcode, params);
                output(params[0]);
                pos += 2;
            case OP_JUMP_IF_TRUE:
                params[0] = modes[2] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = program[pos + 2];
                trace(pos, opcode, params);
                if (params[0] != 0)
                    pos = params[1];
                else
                    pos += 3;
            case OP_JUMP_IF_FALSE:
                params[0] = modes[2] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = program[pos + 2];
                trace(pos, opcode, params);
                if (params[0] == 0)
                    pos = params[1];
                else
                    pos += 3;
            case OP_LESS_THAN:
                params[0] = modes[2] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];
                params[2] = program[pos + 3];
                trace(pos, opcode, params);
                lessThan(params[0], params[1], params[2]);
                trace(program[params[2]]);
                pos += 4;
            case OP_EQUALS:
                params[0] = modes[2] == MODE_POSITION ? program[program[pos + 1]] : program[pos + 1];
                params[1] = modes[1] == MODE_POSITION ? program[program[pos + 2]] : program[pos + 2];
                params[2] = program[pos + 3];
                trace(pos, opcode, params);
                equals(params[0], params[1], params[2]);
                trace(program[params[2]]);
                pos += 4;
            case OP_TERMINATE:
                trace(pos, opcode, params);
                pos = -1;
            default:
                trace("ERROR: Unknown Operation: ", pos, opcode);
                pos = -1;
        }
    }

    private static function add(A:Int, B:Int, Out:Int):Void
    {
        program[Out] = A + B;
    }

    private static function multiply(A:Int, B:Int, Out:Int):Void
    {
        program[Out] = A * B;
    }

    private static function input(A:Int, Out:Int):Void
    {
        program[Out] = A;
    }

    private static function output(A:Int):Void
    {
        outputs.push(A);
    }

    private static function lessThan(A:Int, B:Int, Out:Int):Void
    {
        program[Out] = A < B ? 1 : 0;
    }

    private static function equals(A:Int, B:Int, Out:Int):Void
    {
        program[Out] = A == B ? 1 : 0;
    }
}
