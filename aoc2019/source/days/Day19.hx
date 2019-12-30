package days;

import haxe.ds.Vector;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import haxe.Int64;
import intcode.Computer;
import openfl.Assets;

class Day19 extends Day
{
    private var computer:Computer = new Computer(Assets.getText("assets/data/day19.txt"));

    override public function start():Void
    {
        var x:Float = 0;
        var X:Float = 100000;
        var y:Float = 0;

        while (true)
        {
            var m:Float = Std.int((x + X) / 2);
            y = findMaxY(m);
            if (isGood(m, y))
                X = m;
            else
                x = m;
            if (x == X - 1)
                break;
        }
        var Y:Float = findMaxY(X);
        trace(X, Y);

        PlayState.addOutput('Day 19b Answer: ' + Std.string((X - 99) * 10000 + Y));
    }

    private function isGood(X:Float, Y:Float):Bool
    {
        return (getValue(X, Y) == 1 && getValue(X, Y + 99) == 1 && getValue(X - 99, Y) == 1 && getValue(X - 99, Y + 99) == 1);
    }

    private function findMaxY(X:Float):Float
    {
        var y:Float = 0;
        var Y:Float = X / 0.6;

        while (true)
        {
            var m:Int = Std.int((y + Y) / 2);
            if (getValue(X, m) == 1)
                Y = m;
            else
                y = m;
            if (y == Y - 1)
                break;
        }
        return Y;
    }

    private function getValue(X:Float, Y:Float):Int
    {
        computer.reset();
        computer.start([Int64.ofInt(Std.int(X)), Int64.ofInt(Std.int(Y))]);
        return Int64.toInt(computer.outputs.pop());
    }
}
