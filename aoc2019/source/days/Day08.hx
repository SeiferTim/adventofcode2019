package days;

import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.Assets;

class Day08 extends Day
{
    private final WIDTH:Int = 25;
    private final HEIGHT:Int = 6;

    private var layers:Array<Array<Int>> = [];

    override public function start():Void
    {
        var input:String = Assets.getText("assets/data/day08.txt");
        var pos:Int = 0;
        var chunk:String = "";
        do
        {
            chunk = input.substr(pos, WIDTH * HEIGHT);
            layers.push(chunk.split("").map(function(v) return Std.parseInt(v)));
            pos += WIDTH * HEIGHT;
        }
        while (pos < input.length);

        var numZeros:Int = 0;
        var leastZeroCount:Int = WIDTH * HEIGHT;
        var leastZeros:Int = 0;
        for (l in 0...layers.length)
        {
            numZeros = 0;
            for (i in layers[l])
            {
                if (i == 0)
                    numZeros++;
            }
            if (numZeros < leastZeroCount)
            {
                leastZeroCount = numZeros;
                leastZeros = l;
            }
        }

        var numOnes:Int = 0;
        var numTwos:Int = 0;
        for (i in layers[leastZeros])
        {
            if (i == 1)
                numOnes++;
            else if (i == 2)
                numTwos++;
        }

        trace("Day 08 Answer: " + Std.string(numOnes * numTwos));

        var bmp:BitmapData = new BitmapData(WIDTH, HEIGHT, true, FlxColor.GRAY);
        var layer:Array<Int> = [];
        var x:Int = 0;
        var y:Int = 0;
        for (l in 0...layers.length)
        {
            layer = layers[layers.length - 1 - l];
            for (i in 0...layer.length)
            {
                x = i % WIDTH;
                y = Std.int(i / WIDTH);
                switch (layer[i])
                {
                    case 0:
                        bmp.setPixel32(x, y, FlxColor.BLACK);
                    case 1:
                        bmp.setPixel32(x, y, FlxColor.WHITE);
                }
            }
        }

        FlxG.bitmapLog.add(bmp, "Day 08b Answer");
    }
}
