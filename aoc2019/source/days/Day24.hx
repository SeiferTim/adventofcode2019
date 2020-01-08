package days;

import haxe.Int64;
import openfl.Assets;

class Day24 extends Day
{
    private final grid_width:Int = 5;
    private final grid_height:Int = 5;
    private var bugs:Array<Array<Int>> = [for (i in 0...500) []];

    override public function start():Void
    {
        var offset:Int = 250;

        var start:Array<String> = Assets.getText("assets/data/day24.txt").split("\r\n");
        for (s in start)
        {
            bugs[offset] = bugs[offset].concat(s.split("").map(function(v) return v == "#" ? 1 : 0));
        }

        var newBugs:Array<Array<Int>> = [for (i in 0...500) []];

        for (i in 0...200)
        {
            trace('MINUTE $i');
            for (l in 0...bugs.length)
            {
                newBugs[l] = computeBugs(l);
            }
            bugs = newBugs.copy();

            // for (l in 0...bugs.length)
            // {
            //     var c:Int = 0;
            //     for (b in bugs[l])
            //         c += b;
            //     if (c > 0)
            //     {
            //         trace('LEVEL $l:');
            //         for (j in 0...5)
            //         {
            //             trace(bugs[l].slice(j * 5, j * 5 + 5).map(function(v) return v == 1 ? "#" : ".").join(""));
            //         }
            //         trace("+++++");
            //     }
            // }
        }

        var answer:Float = 0;
        for (b in bugs)
        {
            for (i in b)
                answer += i;
        }
        PlayState.addOutput('Day 24 answer: $answer');
    }

    private function computeBugs(Layer:Int):Array<Int>
    {
        var result:Array<Int> = [for (i in 0...25) 0];
        var neighbors:Int = 0;
        var tmpBugs:Array<Int> = [];
        var prevLayer:Array<Int> = [for (i in 0...25) 0];
        var nextLayer:Array<Int> = [for (i in 0...25) 0];

        if (Layer > 0)
        {
            if (bugs[Layer - 1].length > 0)
                prevLayer = bugs[Layer - 1].copy();
        }

        if (Layer < bugs.length - 1)
        {
            if (bugs[Layer + 1].length > 0)
                nextLayer = bugs[Layer + 1].copy();
        }

        tmpBugs = bugs[Layer].copy();
        if (tmpBugs.length == 0)
            tmpBugs = [for (i in 0...25) 0];
        tmpBugs[12] = 0;
        for (b in 0...tmpBugs.length)
        {
            if (b == 12)
            {
                result[b] == 0;
            }
            else
            {
                neighbors = (b % grid_width <= 0 ? 0 : tmpBugs[b - 1]) + (b % grid_width >= 4 ? 0 : tmpBugs[b + 1])
                    + (b / grid_width < 1 ? 0 : tmpBugs[b - grid_width]) + (b / grid_width >= 4 ? 0 : tmpBugs[b + grid_width]);

                if (b % grid_width == 0)
                    neighbors += prevLayer[11];

                if (b % grid_width == 4)
                    neighbors += prevLayer[13];

                if (b / grid_width < 1)
                    neighbors += prevLayer[7];

                if (b / grid_width >= 4)
                    neighbors += prevLayer[17];

                if (b == 7)
                {
                    for (i in 0...5)
                        neighbors += nextLayer[i];
                }

                if (b == 17)
                {
                    for (i in 0...5)
                        neighbors += nextLayer[20 + i];
                }

                if (b == 11)
                {
                    for (i in 0...5)
                    {
                        neighbors += nextLayer[5 * i];
                    }
                }

                if (b == 13)
                {
                    for (i in 0...5)
                    {
                        neighbors += nextLayer[(5 * i) + 4];
                    }
                }

                if (tmpBugs[b] == 1)
                {
                    if (neighbors != 1)
                        result[b] = 0;
                    else
                        result[b] = 1;
                }
                else if (tmpBugs[b] == 0)
                {
                    if (neighbors >= 1 && neighbors <= 2)
                        result[b] = 1;
                    else
                        result[b] = 0;
                }
            }
        }
        return result;
    }

    private function checkNeighbors(Initial:Int, Total:Int):Int
    {
        var result:Int = Initial;
        if (Initial == 1)
        {
            if (Total != 1)
                result = 0;
        }
        else
        {
            if (Total >= 1 && Total <= 2)
                result = 1;
        }
        return result;
    }
}
