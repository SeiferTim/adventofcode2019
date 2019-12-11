package days;

import flixel.util.FlxSort;
import flixel.math.FlxAngle;
import haxe.ds.ArraySort;
import flixel.util.FlxArrayUtil;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import lime.ui.Window;
import lime.app.Application;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import openfl.utils.Assets;
import flixel.FlxG;

using StringTools;

class Day10 extends Day
{
    override public function start():Void
    {
        var data:String = Assets.getText("assets/data/day10.txt");
        var sData:Array<String> = data.replace(".", "0").replace("#", "1").split("\r\n");
        var aData:Array<Array<Int>> = [];
        var tmp:Array<String> = [];
        for (s in sData)
        {
            tmp = s.split("");
            aData.push(tmp.map(function(v) return Std.parseInt(v)));
        }

        var mapGroup:FlxGroup = new FlxGroup();

        var tilemap:FlxTilemap = new FlxTilemap();
        tilemap.setCustomTileMappings(null, [1], [[1, 2, 3, 4]]);
        tilemap.loadMapFrom2DArray(aData, "assets/images/asteroids.png", 8, 8, FlxTilemapAutoTiling.OFF, 0, 0, 1);

        // tilemap.scale.set(4, 4);
        tilemap.x = FlxG.width - 20 - tilemap.width;
        tilemap.y = FlxG.height - 20 - tilemap.height;

        mapGroup.add(tilemap);

        FlxG.state.add(mapGroup);

        var impacts:Map<String, Map<String, Bool>> = [];
        var subImpacts:Map<String, Bool>;

        var asteroids:Map<String, FlxPoint> = [];

        for (x in 0...tilemap.widthInTiles)
        {
            for (y in 0...tilemap.heightInTiles)
            {
                if (tilemap.getTile(x, y) > 0)
                {
                    asteroids.set('$x,$y', FlxPoint.get(x, y));
                }
            }
        }
        for (aS => pS in asteroids)
        {
            subImpacts = [];
            for (aE => pE in asteroids)
            {
                if (aS != aE)
                {
                    subImpacts.set(getSlope(pS, pE), true);
                }
            }
            impacts.set(aS, subImpacts);
        }

        var counts:Map<String, Int> = [];
        var c:Int = 0;
        for (k => v in impacts)
        {
            c = 0;
            for (i => j in v)
            {
                c++;
            }
            counts.set(k, c);
        }

        var best:String = "";
        var most:Int = -1;
        for (a => c in counts)
        {
            if (c > most)
            {
                best = a;
                most = c;
            }
        }

        PlayState.addOutput('Day 10 Answer: $best => $most');

        var asteroids2:Map<String, Array<Asteroid>> = [];
        var asteroidsByDist:Array<Asteroid>;
        var pS:FlxPoint = asteroids.get(best);
        var a:Float = -1;

        for (aE => pE in asteroids)
        {
            if (aE != best)
            {
                a = getAngle(pS, pE);
                if (asteroids2.exists(Std.string(a)))
                    asteroidsByDist = asteroids2.get(Std.string(a));
                else
                    asteroidsByDist = [];

                asteroidsByDist.push(new Asteroid(aE, pE, getDistance(pS, pE), a));
                asteroids2.set(Std.string(a), asteroidsByDist);
            }
        }

        for (aByA => aByD in asteroids2)
        {
            aByD.sort(sortByDist);
        }

        var keys = [for (key in asteroids2.keys()) key];
        keys.sort(sortByAngle);

        var num:Int = 0;
        var lastToShift:Asteroid = null;
        var blasted:Array<Asteroid> = [];
        for (k in keys)
        {
            asteroidsByDist = asteroids2.get(k);
            if (asteroidsByDist.length > 0)
            {
                lastToShift = asteroidsByDist.shift();
                blasted.push(lastToShift);
                asteroids2.set(k, asteroidsByDist);
                num++;
            }
            if (num == 200)
                break;
        }

        trace(blasted);
        PlayState.addOutput("Day 10b Answer: 200th: " + lastToShift.coords + " => " + Std.string(100 * lastToShift.coords.x + lastToShift.coords.y));
    }

    private function sortByAngle(Obj1:String, Obj2:String):Int
    {
        return FlxSort.byValues(FlxSort.ASCENDING, Std.parseFloat(Obj1), Std.parseFloat(Obj2));
    }

    private function sortByDist(Obj1:Asteroid, Obj2:Asteroid):Int
    {
        return FlxSort.byValues(FlxSort.ASCENDING, Obj1.dist, Obj2.dist);
    }

    private function getAngle(Start:FlxPoint, End:FlxPoint):Float
    {
        var dx = (End.x - Start.x);
        var dy = (End.y - Start.y);
        var tA = FlxMath.roundDecimal(FlxAngle.asDegrees(Math.atan2(dy, dx))+90, 5);
        while (tA < 0)
            tA += 360;
        return tA;
    }

    private function getDistance(Start:FlxPoint, End:FlxPoint):Float
    {
        var dx = (End.x - Start.x);
        var dy = (End.y - Start.y);
        return FlxMath.roundDecimal(Math.sqrt(dx * dx + dy * dy), 5);
    }

    private function getSlope(Start:FlxPoint, End:FlxPoint):String
    {
        var dx = (End.x - Start.x);
        var dy = (End.y - Start.y);
        var gcd:Int = GCD(Std.int(dx), Std.int(dy));
        dx /= gcd;
        dy /= gcd;
        return '$dx/$dy';
    }

    private function removeDuplicates(A:Array<Float>):Array<Float>
    {
        var newA:Array<Float> = [];
        ArraySort.sort(A, function(A, B) return Std.int(A - B));
        newA.push(A[0]);
        for (i in 1...A.length)
        {
            if (!FlxMath.equal(A[i], A[i - 1]))
                newA.push(A[i]);
        }

        return newA;
    }

    private function GCD(A:Int, B:Int):Int
    {
        var r:Int;
        while (B != 0)
        {
            r = A % B;
            A = B;
            B = r;
        }
        return Std.int(Math.abs(A));
    }
}

class Asteroid
{
    public var id:String;
    public var coords:FlxPoint;
    public var dist:Float;
    public var angleTo:Float;

    public function new(ID:String, Coords:FlxPoint, Dist:Float, AngleTo:Float)
    {
        id = ID;
        coords = Coords;
        dist = Dist;
        angleTo = AngleTo;
    }
}
