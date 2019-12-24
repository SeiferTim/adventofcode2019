package days;

import flixel.math.FlxPoint;
import haxe.Int64;
import intcode.Computer;
import openfl.Assets;

class Day19 extends Day
{
    override public function start():Void
    {
        var count:Int = 0;
        var computer:Computer = new Computer(Assets.getText("assets/data/day19.txt"));
        var val:Int = 0;

        var consecY:Int = 0;
        var consecX:Int = 0;
        var lastY:Int = 0;
        var lastXY:FlxPoint = FlxPoint.get();
        for (x in 0...50)
        {
            lastY = -1;
            for (y in 0...50)
            {
                computer.reset();
                computer.start([Int64.ofInt(49 - x), Int64.ofInt(49 - y)]);
                val = Int64.toInt(computer.outputs.pop());
                count += val;
                if (val == 1)
                {
                    consecY++;
                }
                else
                    consecY = 0;
                if (consecY >= 100)
                    lastY = y;
            }
            if (consecY >= 100)
            {
                consecX++;
            }
            else
                consecX = 0;
            if (consecX >= 100 && lastY > -1)
            {
                lastXY.set(x, lastY);
            }
        }

        PlayState.addOutput('Day 19 Answer: $count');
        PlayState.addOutput('Day 19b Answer: ' + Std.string(lastXY.x * 10000 + lastXY.y));
    }
}
