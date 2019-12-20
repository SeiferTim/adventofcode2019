package days;

import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import flixel.tile.FlxTilemap;
import haxe.Int64;
import openfl.Assets;
import intcode.Computer;

class Day17 extends Day
{
    public var map:FlxTilemap;

    override public function start():Void
    {
        var scanner:Computer = new Computer(Assets.getText("assets/data/day17.txt"));
        scanner.start();

        var mapWidth:Int = 0;
        for (i in 0...scanner.outputs.length)
        {
            if (Int64.ucompare(scanner.outputs[i], 10) == 0)
            {
                mapWidth = i;
                break;
            }
        }
        var mapHeight:Int = scanner.outputs.filter(function(v) return v == 10).length - 1;

        var mapData:Array<Int> = scanner.outputs.map(function(v) return Int64.toInt(v)).filter(function(v) return v != 10);

        var rIndex:Int = mapData.indexOf(94);
        var robotPos:FlxPoint = FlxPoint.get(rIndex % mapWidth, Std.int(rIndex / mapWidth));
        mapData[rIndex] = 35;

        for (i in 0...mapData.length)
        {
            mapData[i] = mapData[i] == 35 ? 0 : 1;
        }

        var tiles:BitmapData = new BitmapData(2, 1, false, 0xff000000);
        tiles.setPixel32(0, 0, FlxColor.WHITE);

        trace(mapWidth, mapHeight, rIndex, robotPos, mapData);

        map = new FlxTilemap();
        map.loadMapFromArray(mapData, mapWidth, mapHeight, tiles, 1, 1, FlxTilemapAutoTiling.OFF, 0, 0, 1);

        // var robot:Vacuumbot = new Vacuumbot(robotPos.x, robotPos.y, this);

        // var ss:Day17SubState = new Day17SubState(map, robot);

        var neighborCount:Int = 0;
        var intersections:Array<FlxPoint> = [];
        var x:Int = -1;
        var y:Int = -1;
        for (i in 1...mapData.length - 1)
        {
            neighborCount = 0;
            x = i % mapWidth;
            y = Std.int(i / mapWidth);
            if (map.getTile(x, y) == 0)
            {
                neighborCount += map.getTile(x - 1, y) == 0 ? 1 : 0;
                neighborCount += map.getTile(x + 1, y) == 0 ? 1 : 0;
                neighborCount += map.getTile(x, y - 1) == 0 ? 1 : 0;
                neighborCount += map.getTile(x, y + 1) == 0 ? 1 : 0;

                if (neighborCount == 4)
                    intersections.push(FlxPoint.get(x, y));
            }
        }

        var alignment:Int = 0;
        for (i in intersections)
        {
            alignment += Std.int(i.x * i.y);
        }

        var s:String = 'Day 17 Answer:  $alignment';

        PlayState.addOutput(s);

        part2();
    }

    private function part2():Void
    {
        var routine:String = "A,B,A,B,C,A,B,C,A,C";
        var functionA:String = "R,6,L,6,L,10";
        var functionB:String = "L,8,L,6,L,10,L,6";
        var functionC:String = "R,6,L,8,L,10,R,6";

        var program:Computer = new Computer(Assets.getText("assets/data/day17.txt"));

        program.setValue(0, 2);
        program.start();
        output(program.outputs);
        if (program.state == Computer.STATE_WAITING)
        {
            program.start(stringToCode(routine));
            output(program.outputs);
            if (program.state == Computer.STATE_WAITING)
            {
                program.start(stringToCode(functionA));
                output(program.outputs);
                if (program.state == Computer.STATE_WAITING)
                {
                    program.start(stringToCode(functionB));
                    output(program.outputs);
                    if (program.state == Computer.STATE_WAITING)
                    {
                        program.start(stringToCode(functionC));
                        output(program.outputs);
                        if (program.state == Computer.STATE_WAITING)
                        {
                            program.start(stringToCode("n"));
                            output(program.outputs);
                        }
                    }
                }
            }
        }

        trace("...done!");

        output(program.outputs);
        trace(program.outputs);
    }

    private function stringToCode(Data:String):Array<Int64>
    {
        var result:Array<Int64> = [];
        for (i in 0...Data.length)
        {
            result.push(Data.charCodeAt(i));
        }
        result.push(10);
        trace(result);
        return result;
    }

    private function output(Data:Array<Int64>):Void
    {
        var s:String = Data.map(function(v) return String.fromCharCode(Int64.toInt(v))).join("");
        Sys.print(s);
    }
}
