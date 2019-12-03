package days;

import openfl.Assets;

class Day02 extends Day
{
    private static inline final ADD:Int = 1;
    private static inline final MULTIPLY:Int = 2;
    private static inline final TERMINATE:Int = 99;

    private var data:Array<Int> = [];
    private var pos:Int = 0;

    override public function start():Void
    {
        data = Assets.getText("assets/data/day02.txt").split(",").map(function(v) return Std.parseInt(v));

        data[1] = 12;
        data[2] = 2;

        do
        {
            compute();
        }
        while (pos >= 0);

        trace("Day 2 Answer: " + Std.string(data[0]));

        var noun:Int = 0;
        var verb:Int = 0;
        do
        {
            if (noun == 99)
            {
                noun = 0;
                verb++;
            }
            else
                noun++;

            data = Assets.getText("assets/data/day02.txt").split(",").map(function(v) return Std.parseInt(v));
            pos = 0;
            data[1] = noun;
            data[2] = verb;
            do
            {
                compute();
            }
            while (pos >= 0);
            trace(noun, verb, data[0]);
        }
        while (data[0] != 19690720);
        trace("Day 2b Answer: " + Std.string(100 * noun + verb));
    }

    private function compute():Void
    {
        var action:Int = data[pos];
        switch (action)
        {
            case ADD:
                add();
            case MULTIPLY:
                multiply();
            case TERMINATE:
                pos = -1;
        }
    }

    private function add():Void
    {
        var posInA:Int = data[pos + 1];
        var posInB:Int = data[pos + 2];
        var posOut:Int = data[pos + 3];
        data[posOut] = data[posInA] + data[posInB];
        pos += 4;
    }

    private function multiply():Void
    {
        var posInA:Int = data[pos + 1];
        var posInB:Int = data[pos + 2];
        var posOut:Int = data[pos + 3];
        data[posOut] = data[posInA] * data[posInB];
        pos += 4;
    }
}
