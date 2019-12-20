package days;

import openfl.Assets;

class Day18 extends Day
{
    private var playerStart:Int = -1;

    override public function start():Void
    {
        var mapWidth:Int = -1;
        var mapHeight:Int = -1;
        var input:Array<Array<String>> = Assets.getText("assets/data/day18.txt").split("\r").map(function(v) return v.split(""));

        mapWidth = input[0].length;
        mapHeight = input.length;

        var mapData:Array<Int> = [];
        for (i in input)
        {
            mapData.concat(i.map(function(v)
            {
                var result:Int = 0;
                if (v == "#")
                    result = 30;
                else if (v == ".")
                    result = 0;
                else if (v >= "a" && v <= "z")
                    result = v.charCodeAt(0) - "a".charCodeAt(0) + 2;
                else if (v >= "A" && v <= "Z")
                    result = v.charCodeAt(0) - "A".charCodeAt(0) + 30;
                else if (v == "@")
                {
                    result = 1;
                }
                return result;
            }));
        }

        trace(mapData);
    }
}
