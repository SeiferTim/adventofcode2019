package days;

import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.util.FlxArrayUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.text.TextLineMetrics;
import flixel.text.FlxText;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import lime.utils.Assets;
import openfl.display.BitmapData;
import flixel.tile.FlxTilemap;

class Day20 extends Day
{
    private var portals:Map<String, Int> = [];
    private var map:FlxTilemap;
    private var mapWidth:Int = -1;
    private var mapHeight:Int = -1;
    private var mapData:Array<Int> = [];
    private var routes:Array<Day20Route> = [];

    private var portalCount:Int = 0;
    private var iterations:Int = 0;

    private var cache:Map<String, Int> = [];

    private var shortestPaths:Map<String, Int> = [];

    override public function start():Void
    {
        var steps:Int = 0;
        loadMap("assets/data/day20f.txt");

        getRoutes("Z");

        // steps = distanceToExit("A", "Z");
        // PlayState.addOutput('Day 20 Answer: $steps');

        steps = distanceToExitR("A", "Z");
        PlayState.addOutput('Day 20b Answer: $steps');
    }

    private function getRoute(From:String, To:String):Day20Route
    {
        for (r in routes)
            if (r.startKey == From && r.endKey == To)
                return r;
        return null;
    }

    private function getRouteByLevel(LevelFrom:Int, LevelTo:Int, From:String, To:String):Day20Route
    {
        if (LevelFrom == 0 && From != "A" && !(To >= "a" && To <= "~"))
            return null;
        if (LevelTo == 0 && To != "Z" && !(From >= "a" && From <= "~"))
            return null;
        if (LevelTo != 0 && To == "Z")
            return null;
        if (LevelFrom != 0 && From == "A")
            return null;

        var diff:Int = LevelTo - LevelFrom;

        if (diff == 0 && From == otherEnd(To))
            return null;
        if (diff != 0 && From != otherEnd(To))
            return null;

        for (r in routes)
        {
            // if (LevelFrom == 0 && (r.startKey != "A" && r.startKey != "Z" && r.startKey >= "A" && r.startKey <= "^"))
            //     continue;
            // if (LevelTo == 0 && (r.endKey != "A" && r.endKey != "Z" && r.endKey <= "a" && r.startKey >= "~"))
            //     continue;
            // if (diff == 0 && r.startKey == otherEnd(r.endKey))
            //     continue;
            // if (diff != 0 && r.startKey != otherEnd(r.endKey))
            //     continue;
            // if (LevelFrom != 0 && (r.startKey == "A" || r.startKey == "Z"))
            //     continue;
            // if (LevelTo != 0 && (r.endKey == "A" || r.endKey == "Z"))
            //     continue;
            if (r.startKey == From && r.endKey == To)
                return r;
        }
        return null;
    }

    private function getRoutes(End:String = "Z"):Void
    {
        var from:Array<String> = [for (k in portals.keys()) k];
        var to:Array<String> = from.copy();
        var r:Day20Route = null;
        for (f in from)
        {
            for (t in to)
            {
                if (t != f)
                {
                    r = findPath(f, t);

                    if (r != null)
                        routes.push(r);
                }
            }
        }

        // trace(routes);
    }

    private function getCacheKey(From:String, Collected:Array<String>):String
    {
        var c:Array<String> = Collected.copy();
        c.sort(function(A, B) return A.charCodeAt(0) - B.charCodeAt(0));
        return From + ":" + c.join("");
    }

    private function distanceToExitdistanceToExit(From:String, End:String, ?WasPortal:Bool = false, ?Taken:Array<String>):Int
    {
        var maxDist:Int = mapWidth * mapHeight * 100;

        var r:Day20Route = null;

        for (k in portals.keys())
        {
            for (i in portals.keys())
            {
                for (j in portals.keys())
                {
                    var ij:Int = maxDist;
                    var ik:Int = maxDist;
                    var kj:Int = maxDist;
                    if (shortestPaths.exists('$i>$j'))
                    {
                        ij = shortestPaths.get('$i>$j');
                    }
                    else
                    {
                        r = getRoute(i, j);
                        if (r != null)
                            ij = r.length;
                    }
                    if (shortestPaths.exists('$i>$k'))
                    {
                        ik = shortestPaths.get('$i>$k');
                    }
                    else
                    {
                        r = getRoute(i, k);
                        if (r != null)
                            ik = r.length;
                    }
                    if (shortestPaths.exists('$k>$j'))
                    {
                        kj = shortestPaths.get('$k>$j');
                    }
                    else
                    {
                        r = getRoute(k, j);
                        if (r != null)
                            kj = r.length;
                    }

                    if (ij != maxDist || ik != maxDist || kj != maxDist)
                        shortestPaths.set('$i>$j', FlxMath.minInt(ij, ik + kj));
                }
            }
        }

        return shortestPaths.get('$From>$End');
    }

    private function distanceToExitR(From:String, End:String, ?Taken:Array<String>, ?WasPortal:Bool = false, ?Level:Int = 0, ?Iterations:Int = 0):Int // ?
    {
        var maxDist:Int = mapWidth * mapHeight * 1000;

        var r:Day20Route = null;

        for (k in portals.keys())
        {
            for (i in portals.keys())
            {
                for (j in portals.keys())
                {
                    for (lF in 0...11)
                    {
                        for (lT in 0...11)
                        {
                            // var lT:Int = lF + (lM - 1);
                            // if ((lF == lT && i == j) || (lF != 0 && i == "A") || (lF == 0 && i != "A"))
                            //     continue;

                            var ij:Int = maxDist;
                            var ik:Int = maxDist;
                            var kj:Int = maxDist;

                            if (shortestPaths.exists('$lF:$i>$lT:$j'))
                            {
                                ij = shortestPaths.get('$lF:$i>$lT:$j');
                            }
                            else
                            {
                                r = null;
                                r = getRoute(i, j);
                                if (r != null)
                                    ij = r.length;
                            }

                            if (shortestPaths.exists('$lF:$i>$lT:$k'))
                            {
                                ik = shortestPaths.get('$lF:$i>$lT:$k');
                            }
                            else
                            {
                                r = null;
                                r = getRoute(i, k);
                                if (r != null)
                                    ik = r.length;
                            }

                            if (shortestPaths.exists('$lF:$k>$lT:$j'))
                            {
                                kj = shortestPaths.get('$lF:$k>$lT:$j');
                            }
                            else
                            {
                                r = null;
                                r = getRoute(k, j);
                                if (r != null)
                                    kj = r.length;
                            }
                            // trace(i, j, k, lF, lT);
                            // if ((i == "A" || k == "A") && (k == "l" || j == "l") && lF == 0 && lT == 0)
                            //     trace(i, j, k, lF, lT, ij, ik, kj);

                            shortestPaths.set('$lF:$i>$lT:$j', FlxMath.minInt(ij, ik + kj));
                        }
                    }
                }
            }
        }

        trace([
            for (i in [for (k in shortestPaths.keys()) k].filter(function(v) return StringTools.startsWith(v, "0:A>")))
                i + " => " + shortestPaths.get(i)
        ]);
        return shortestPaths.get('0:$From>0:$End');
    }

    private function isValidRoute(LevelFrom:Int, LevelTo:Int, From:String, To:String):Bool
    {
        // if (LevelFrom == 0 && LevelTo == 0 && From == "A" && To == "l")
        // {
        //     trace((LevelFrom == 0 && (From != "A" && !(From >= "a" && From <= "~"))));
        //     trace((LevelTo == 0 && (To != "Z" && !(To >= "a" && To <= "~"))));
        //     trace((LevelTo != 0 && To == "Z"));
        //     trace((LevelFrom != 0 && From == "A"));
        // }
        if (From == To)
            return false;
        if (LevelFrom == 0 && (From != "A" && !(From >= "a" && From <= "~"))) // && (To != "Z" || !(To >= "a" && To <= "~")))
            return false;
        if (LevelTo == 0 && (To != "Z" && !(To >= "a" && To <= "~"))) // && (From != "A" || !(From >= "a" && From <= "~")))
            return false;
        if (LevelTo != 0 && To == "Z")
            return false;
        if (LevelFrom != 0 && From == "A")
            return false;

        // var diff:Int = LevelTo - LevelFrom;

        // if (diff == 0 && From == otherEnd(To))
        //     return false;
        // if (Math.abs(diff) == 1 && From != otherEnd(To))
        //     return false;
        // if (Math.abs(diff) > 1)
        //     return false;
        return true;
    }

    private function otherEnd(Key:String):String
    {
        if (Key.charCodeAt(0) <= 96)
            return String.fromCharCode(Key.charCodeAt(0) + 32);
        else
            return String.fromCharCode(Key.charCodeAt(0) - 32);
    }

    private function addKey(T:Array<String>, Key:String):Array<String>
    {
        var keys:Array<String> = [Key];

        return T.concat(keys);
    }

    private function getKeyR(Key:String, Level:Int):String
    {
        return Key + ";" + Std.string(Level);
    }

    private function computePathDistance(StartIndex:Int, EndIndex:Int):Array<Int>
    {
        // Create a distance-based representation of the tilemap.
        // All walls are flagged as -2, all open areas as -1.
        var mapSize:Int = mapWidth * mapHeight;
        var distances:Array<Int> = new Array<Int>( /*mapSize*/);
        FlxArrayUtil.setLength(distances, mapSize);
        var i:Int = 0;
        while (i < mapSize)
        {
            if (mapData[i] == 30)
            {
                distances[i] = -2;
            }
            else
            {
                distances[i] = -1;
            }
            i++;
        }
        distances[StartIndex] = 0;
        var distance:Int = 1;
        var neighbors:Array<Int> = [StartIndex];
        var current:Array<Int>;
        var currentIndex:Int;
        var left:Bool;
        var right:Bool;
        var up:Bool;
        var down:Bool;
        var currentLength:Int;
        var foundEnd:Bool = false;
        while (neighbors.length > 0)
        {
            current = neighbors;
            neighbors = new Array<Int>();
            i = 0;
            currentLength = current.length;
            while (i < currentLength)
            {
                currentIndex = current[i++];
                if (currentIndex == Std.int(EndIndex))
                {
                    foundEnd = true;
                    neighbors = [];
                    break;
                }
                // Basic map bounds
                left = currentIndex % mapWidth > 0;
                right = currentIndex % mapWidth < mapWidth - 1;
                up = currentIndex / mapWidth > 0;
                down = currentIndex / mapWidth < mapWidth - 1;
                var index:Int;
                if (up)
                {
                    index = currentIndex - mapWidth;
                    if (distances[index] == -1)
                    {
                        distances[index] = distance;
                        neighbors.push(index);
                    }
                }
                if (right)
                {
                    index = currentIndex + 1;
                    if (distances[index] == -1)
                    {
                        distances[index] = distance;
                        neighbors.push(index);
                    }
                }
                if (down)
                {
                    index = currentIndex + mapWidth;
                    if (distances[index] == -1)
                    {
                        distances[index] = distance;
                        neighbors.push(index);
                    }
                }
                if (left)
                {
                    index = currentIndex - 1;
                    if (distances[index] == -1)
                    {
                        distances[index] = distance;
                        neighbors.push(index);
                    }
                }
            }
            distance++;
        }
        if (!foundEnd)
        {
            distances = null;
        }
        return distances;
    }

    private function findPath(Start:String, End:String):Day20Route
    {
        // Figure out what tile we are starting and ending on.
        if (Start == End || Start == "Z" || End == "A")
            return null;
        var startIndex:Int = portals.get(Start);

        var endIndex:Int = portals.get(End);
        // Check if any point given is outside the tilemap
        if ((startIndex < 0) || (endIndex < 0))
            return null;
        if (Start.charCodeAt(0) == otherEnd(End).charCodeAt(0) || End.charCodeAt(0) == otherEnd(Start).charCodeAt(0))
        {
            return new Day20Route(Start, End, 1, End.charCodeAt(0) >= 96 ? -1 : 1);
        }
        // Figure out how far each of the tiles is from the starting tile

        var distances:Array<Int> = computePathDistance(startIndex, endIndex);
        if (distances == null)
        {
            return null;
        }
        var points:Array<Int> = [];
        walkPath(distances, endIndex, points);
        var node:Int;
        var path:Array<Int> = [];

        var i:Int = points.length - 1;
        while (i >= 0)
        {
            node = points[i--];
            if (node != null)
            {
                path.push(node);
            }
        }

        var route:Day20Route = new Day20Route(Start, End, distances[endIndex]);
        return route;
    }

    private function walkPath(Data:Array<Int>, Start:Int, Points:Array<Int>):Void
    {
        Points.push(Start);
        if (Data[Start] == 0)
        {
            return;
        }
        // Basic map bounds
        var left:Bool = (Start % map.widthInTiles) > 0;
        var right:Bool = (Start % map.widthInTiles) < (map.widthInTiles - 1);
        var up:Bool = (Start / map.widthInTiles) > 0;

        var down:Bool = (Start / map.widthInTiles) < (map.heightInTiles - 1);
        var current:Int = Data[Start];

        var i:Int;
        if (up)
        {
            i = Start - map.widthInTiles;
            if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
            {
                return walkPath(Data, i, Points);
            }
        }
        if (right)
        {
            i = Start + 1;
            if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
            {
                return walkPath(Data, i, Points);
            }
        }
        if (down)
        {
            i = Start + map.widthInTiles;
            if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
            {
                return walkPath(Data, i, Points);
            }
        }
        if (left)
        {
            i = Start - 1;
            if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
            {
                return walkPath(Data, i, Points);
            }
        }
        if (up && right)
        {
            i = Start - map.widthInTiles + 1;
            if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
            {
                return walkPath(Data, i, Points);
            }
        }
        if (right && down)
        {
            i = Start + map.widthInTiles + 1;
            if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
            {
                return walkPath(Data, i, Points);
            }
        }
        if (left && down)
        {
            i = Start + map.widthInTiles - 1;
            if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
            {
                return walkPath(Data, i, Points);
            }
        }
        if (up && left)
        {
            i = Start - map.widthInTiles - 1;
            if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
            {
                return walkPath(Data, i, Points);
            }
        }
        return;
    }

    private function loadMap(DataPath:String):Void
    {
        var tiles:BitmapData = makeTiles();

        var input:Array<Array<String>> = Assets.getText(DataPath).split("\r\n").map(function(v) return v.split(""));
        mapWidth = input[0].length;

        mapHeight = input.length;

        var tmp:Array<Int> = [];
        var k:String = "";

        var p:Array<Int> = [];
        for (i in input)
        {
            tmp = i.filter(function(v) return v != "\r\n").map(function(v)
            {
                var result:Int = 0;
                if (v == "#")
                    result = 30;
                else if (v == "." || v == " ")
                    result = 0;
                else if (v >= "a" && v <= "~")
                    result = v.charCodeAt(0) - "a".charCodeAt(0) + 2;
                else if (v >= "A" && v <= "^")
                    result = v.charCodeAt(0) - "A".charCodeAt(0) + 41;

                return result;
            });
            mapData = mapData.concat(tmp);
        }
        // build lists of all keys and doors:

        for (n in 0...mapData.length)
        {
            if (mapData[n] == 30 || mapData[n] == 0)
                continue;
            if (mapData[n] >= 41)
            {
                k = String.fromCharCode(mapData[n] - 41 + "A".charCodeAt(0));
                portals.set(k, n);
            }
            else if (mapData[n] >= 2 && mapData[n] <= 40)
            {
                k = String.fromCharCode(mapData[n] - 2 + "a".charCodeAt(0));
                portals.set(k, n);
            }
            // if (k == "}")
            //     trace(k, mapData[n], n);
        }
        map = new FlxTilemap();
        map.loadMapFromArray(mapData, mapWidth, mapHeight, tiles, 10, 10, FlxTilemapAutoTiling.OFF, 0, 0, 30);
    }

    private function makeTiles():BitmapData
    {
        var hue:Float = 0;
        var point:Point = new Point();
        var rectS:Rectangle = new Rectangle(0, 0, 10, 10);
        var rectD:Rectangle = new Rectangle(0, 0, 10, 10);
        var metrics:TextLineMetrics;
        var letters:FlxText = new FlxText();
        letters.size = 8;

        letters.color = FlxColor.WHITE;
        var tmp:BitmapData = new BitmapData(600, 10, false, FlxColor.BLACK);

        tmp.lock();
        rectD.x = 0;

        tmp.fillRect(rectD, FlxColor.WHITE);
        rectD.x = 10;

        tmp.fillRect(rectD, FlxColor.WHITE);
        letters.color = FlxColor.BLACK;
        letters.text = "@";

        letters.drawFrame(true);

        metrics = letters.textField.getLineMetrics(0);
        rectS.y = letters.framePixels.height - metrics.height;

        rectS.width = letters.framePixels.width;
        point.x = Std.int(rectD.x + 5 - (rectS.width / 2));

        point.y = Std.int(5 - (rectS.height / 2));

        tmp.copyPixels(letters.framePixels, rectS, point, null, null, true);
        for (l in 'a'.charCodeAt(0)...'}'.charCodeAt(0) + 1)
        {
            rectD.x += 10;
            tmp.fillRect(rectD, FlxColor.WHITE);
            hue += 360 / 29;
            letters.color = FlxColor.fromHSB(hue, 1, 1, 1);
            letters.text = String.fromCharCode(l);

            letters.drawFrame(true);

            metrics = letters.textField.getLineMetrics(0);
            rectS.y = letters.framePixels.height - metrics.height;

            rectS.width = letters.framePixels.width;
            point.x = Std.int(rectD.x + 5 - (rectS.width / 2));

            point.y = Std.int(5 - (rectS.height / 2));
            tmp.copyPixels(letters.framePixels, rectS, point, null, null, true);
        }

        rectD.x = 400;

        tmp.fillRect(rectD, FlxColor.GRAY);
        for (l in 'A'.charCodeAt(0)...']'.charCodeAt(0) + 1)
        {
            rectD.x += 10;

            hue += 360 / 29;

            tmp.fillRect(rectD, FlxColor.fromHSB(hue, 1, .8, .8));
            letters.color = FlxColor.WHITE;
            letters.text = String.fromCharCode(l);

            letters.drawFrame(true);

            metrics = letters.textField.getLineMetrics(0);
            rectS.y = letters.framePixels.height - metrics.height;

            rectS.width = letters.framePixels.width;
            point.x = Std.int(rectD.x + 5 - (rectS.width / 2));

            point.y = Std.int(5 - (rectS.height / 2) + 1);
            tmp.copyPixels(letters.framePixels, rectS, point, null, null, true);
        }
        tmp.unlock();

        FlxG.bitmapLog.add(tmp);
        return tmp;
    }
}

class Day20Route
{
    public var startKey:String = "";
    public var endKey:String = "";
    public var length:Int = 0;
    public var level:Int = 0;

    public function new(Start:String, End:String, Length:Int, ?Level:Int = 0)
    {
        startKey = Start;
        endKey = End;
        length = Length;
        level = Level;
    }
}
