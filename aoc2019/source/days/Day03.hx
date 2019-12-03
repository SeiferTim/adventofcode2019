package days;

import flixel.FlxObject;
import flixel.util.FlxSort;
import lime.math.Vector2;
import flixel.math.FlxVector;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import openfl.Assets;

class Day03 extends Day
{
    private static inline final WIRE_A:Int = 0x0001;
    private static inline final WIRE_B:Int = 0x0010;

    private var wires:Map<String, Int>;
    private var steps:Map<String, Int>;
    private var stepTotal:Int = 0;

    private var posX:Int = 0;
    private var posY:Int = 0;

    override public function start():Void
    {
        wires = [];
        steps = [];
        var data:Array<String> = Assets.getText("assets/data/day03.txt").split("\r\n");
        var wireData:Array<Array<String>> = [data[0].split(","), data[1].split(",")];
        var command:String;
        var value:Int;

        for (wire in 0...2)
        {
            posX = posY = 0;
            stepTotal = 0;
            for (w in wireData[wire])
            {
                command = w.substr(0, 1);
                value = Std.parseInt(w.substr(-(w.length - 1)));

                switch (command)
                {
                    case "R":
                        move(wire == 0 ? WIRE_A : WIRE_B, value, FlxAxes.X);
                    case "L":
                        move(wire == 0 ? WIRE_A : WIRE_B, -value, FlxAxes.X);
                    case "U":
                        move(wire == 0 ? WIRE_A : WIRE_B, -value, FlxAxes.Y);
                    case "D":
                        move(wire == 0 ? WIRE_A : WIRE_B, value, FlxAxes.Y);
                }
            }
        }
        trace("getting Intersections");

        var intersections:Array<String> = [];
        var distances:Array<Int> = [];
        var totals:Array<Int> = [];

        for (pos => value in wires)
        {
            if (value == WIRE_A | WIRE_B && pos != "0,0")
            {
                intersections.push(pos);
                distances.push(getDistance(pos));
                totals.push(steps.get(pos));
            }
        }

        // trace(totals);

        distances.sort(function(a, b):Int return a - b);

        trace("Day 3 Answer: " + Std.string(distances[0]));

        totals.sort(function(a, b):Int return a - b);

        trace("Day 3b Answer: " + Std.string(totals[0]));
    }

    private function getDistance(I:String):Int
    {
        var values:Array<Int> = I.split(",").map(function(v)
        {
            return Std.int(Math.abs(Std.parseInt(v)));
        });

        return values[0] + values[1];
    }

    private function addWire(Wire:Int, X:Int, Y:Int):Void
    {
        var v:String = Std.string(X) + "," + Std.string(Y);

        var w:Int = 0;
        if (wires.exists(v))
            w = wires.get(v);
        wires.set(v, w | Wire);
    }

    private function addStep(Wire:Int, X:Int, Y:Int):Void
    {
        var v:String = Std.string(X) + "," + Std.string(Y);

        if (wires.exists(v))
        {
            // trace(v, wires.get(v), Wire, wires.get(v) & Wire, steps.get(v));
            if (wires.get(v) & Wire > 0)
                return;
        }

        var w:Int = 0;

        if (steps.exists(v))
            w = steps.get(v);
        // trace(v, w + stepTotal);
        steps.set(v, w + stepTotal);
    }

    private function move(Wire:Int, Amount:Int, Axis:FlxAxes):Void
    {
        var dir:Int = FlxMath.signOf(Amount);
        var end:Int = 0;
        switch (Axis)
        {
            case FlxAxes.X:
                end = posX + Amount;

                do
                {
                    stepTotal++;
                    posX += dir;
                    addStep(Wire, posX, posY);
                    addWire(Wire, posX, posY);
                }
                while ((dir == 1 && posX < end) || (dir == -1 && posX > end));

            case FlxAxes.Y:
                end = posY + Amount;
                do
                {
                    stepTotal++;
                    posY += dir;
                    addStep(Wire, posX, posY);
                    addWire(Wire, posX, posY);
                }
                while ((dir == 1 && posY < end) || (dir == -1 && posY > end));

            default:
        }
    }
}
