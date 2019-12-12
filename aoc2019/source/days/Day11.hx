package days;

import flixel.FlxG;
import flixel.system.debug.log.BitmapLog;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import haxe.Int64;
import flixel.math.FlxAngle;
import flixel.FlxObject;
import openfl.Assets;
import intcode.Computer;

class Day11 extends Day
{
    override public function start():Void
    {
        var comp:Computer = new Computer(Assets.getText("assets/data/day11.txt"));
        var x:Int = 0;
        var y:Int = 0;
        var angle:Int = 0;
        var tiles:Map<String, Int> = [];
        var painted:Int = 0;

        var toSend:Int = -1;
        var stop:Bool = false;

        comp.start([0]); // PART 1
        do
        {
            // trace(comp.outputs, comp.state);

            if (comp.state == Computer.STATE_WAITING)
            {
                if (!tiles.exists('$x,$y'))
                {
                    painted++;
                }
                tiles.set('$x,$y', Int64.toInt(comp.outputs.shift()));

                if (comp.outputs.shift() == 0)
                    angle -= 90;
                else
                    angle += 90;
                while (angle < 0)
                    angle += 360;
                while (angle >= 360)
                    angle -= 360;

                switch (angle)
                {
                    case 0:
                        y--;
                    case 90:
                        x++;
                    case 180:
                        y++;
                    case 270:
                        x--;
                }

                if (tiles.exists('$x,$y'))
                    toSend = tiles.get('$x,$y');
                else
                    toSend = 0;
                // trace(angle, '$x, $y', toSend);
                comp.start([toSend]);
            }
            else
            {
                stop = true;
                if (comp.state == Computer.STATE_ERROR)
                {
                    // some kind of error
                    trace(comp.outputs);
                }
            }
        }
        while (!stop);

        PlayState.addOutput("Day 11 Answer: " + painted);

        var lowestX:Int = 0;
        var highestX:Int = 0;
        var lowestY:Int = 0;
        var highestY:Int = 0;

        tiles = [];
        x = y = angle = 0;
        stop = false;

        comp.reset();
        comp.start([1]); // PART 2
        do
        {
            if (comp.state == Computer.STATE_WAITING)
            {
                tiles.set('$x,$y', Int64.toInt(comp.outputs.shift()));

                if (comp.outputs.shift() == 0)
                    angle -= 90;
                else
                    angle += 90;
                while (angle < 0)
                    angle += 360;
                while (angle >= 360)
                    angle -= 360;

                switch (angle)
                {
                    case 0:
                        y--;
                    case 90:
                        x++;
                    case 180:
                        y++;
                    case 270:
                        x--;
                }
                if (x < lowestX)
                    lowestX = x;
                else if (x > highestX)
                    highestX = x;
                if (y < lowestY)
                    lowestY = y;
                else if (y > highestY)
                    highestY = y;

                if (tiles.exists('$x,$y'))
                    toSend = tiles.get('$x,$y');
                else
                    toSend = 0;
                // trace(angle, '$x, $y', toSend);
                comp.start([toSend]);
            }
            else
            {
                stop = true;
                if (comp.state == Computer.STATE_ERROR)
                {
                    // some kind of error
                    trace(comp.outputs);
                }
            }
        }
        while (!stop);

        var offsetX:Int = 0;
        var offsetY:Int = 0;
        if (lowestX < 0)
            offsetX = -lowestX;
        if (lowestY < 0)
            offsetY = -lowestY;
        var bmp:BitmapData = new BitmapData(highestX - lowestX + offsetX, highestY - lowestY + offsetY, false, FlxColor.BLACK);
        for (x in (lowestX + offsetX)...(highestX + offsetX))
        {
            for (y in (lowestY + offsetY)...(highestY + offsetY))
            {
                if (tiles.exists('$x,$y'))
                    if (tiles.get('$x,$y') == 1)
                        bmp.setPixel(x, y, FlxColor.WHITE);
            }
        }
        FlxG.bitmapLog.add(bmp, "Day 11b Answser");
    }
}
