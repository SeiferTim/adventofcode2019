package days;

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
    private var playerStarts:Array<Int> = [];
    private var portals:Map<String, Int> = [];
    private var map:FlxTilemap;
    private var mapWidth:Int = -1;
    private var mapHeight:Int = -1;
    private var mapData:Array<Int> = [];
    private var routes:Array<Day20Route> = [];
    private var cache:Map<String, Int> = [];
    private var pathTaken:Array<String> = [];

    override public function start():Void
    {
        var steps:Int = 0;
        loadMap("assets/data/day20a.txt");

        getRoutes("Z");

        // trace(routes);
        steps = distanceToExit("A", "Z");
        // var path:Array<String> = BFS("A", "Z");
        // trace(path);
        // for (p in 1...path.length)
        // {
        //     steps += getRoute(path[p - 1], path[p]).length;
        // }
        PlayState.addOutput('Day 20 Answer: $steps');
    }

    private function getRoute(From:String, To:String):Day20Route
    {
        for (r in routes)
            if (r.startKey == From && r.endKey == To)
                return r;
        return null;
    }

    private function BFS(From:String, To:String):Array<String>
    {
        var queue:Array<String> = [];
        var visited:Array<String> = [];
        var best:Day20Route = null;
        queue.push(From);

        while (true)
        {
            var f:String = queue.shift();
            visited.push(f);
            if (f == To)
            {
                // trace(visited);
                break; // return f.len;
            }
            best = new Day20Route("", "", 999999);
            for (r in routes.filter(function(v) return v.startKey == f && visited.indexOf(v.endKey) == -1))
            {
                if (r.length < best.length)
                {
                    best = r;
                }
                // trace(f, r);
            }
            queue.push(best.endKey);
        }
        return visited;
    }

    private function getRoutes(End:String = "Z"):Void
    {
        trace(portals);
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

                    if (f == "~" || t == "~" || f == "^" || t == "^" || f == "t" || t == "t")
                        trace(r);
                    if (r != null)
                        routes.push(r);
                }
            }
        }

        // var removedDeadEnd:Bool = false;
        // do
        // {
        //     removedDeadEnd = false;
        //     for (r1 in routes)
        //     {
        //         if (r1.endKey != End)
        //         {
        //             var count:Int = 0;
        //             for (r2 in routes)
        //             {
        //                 if (r2.startKey == r1.endKey)
        //                 {
        //                     count++;
        //                 }
        //             }
        //             if (count == 0)
        //             {
        //                 removedDeadEnd = true;
        //                 routes.remove(r1);
        //             }
        //         }
        //     }
        //     trace(removedDeadEnd);
        // }
        // while (removedDeadEnd);

        // do
        // {
        //     removedDeadEnd = false;
        //     for (r1 in routes)
        //     {
        //         for (r2 in routes)
        //         {
        //             if (r2 != r1 && r2.startKey == r1.startKey && r2.endKey == r1.endKey && r2.length >= r1.length)
        //             {
        //                 removedDeadEnd = true;
        //                 routes.remove(r2);
        //             }
        //         }
        //     }
        //     trace(removedDeadEnd);
        // }
        // while (removedDeadEnd);

        trace(routes);
    }

    private function getCacheKey(From:String, Collected:Array<String>):String
    {
        var c:Array<String> = Collected.copy();
        c.sort(function(A, B) return A.charCodeAt(0) - B.charCodeAt(0));
        return From + ":" + c.join("");
    }

    private function distanceToExit(From:String, End:String, ?WasPortal:Bool = false, ?Taken:Array<String>):Int
    {
        if (Taken == null)
            Taken = [];

        // trace(From, End, WasPortal, Taken);

        var result:Int = mapWidth * mapHeight * 10;
        var d:Int = 0;
        /// if we have no more keys we can get to, return 0
        if (From == End)
        {
            trace(Taken.concat(["Z"]));
            result = 0;
        }
        else
        {
            for (r in routes)
            {
                // trace(WasPortal, r.endKey, otherEnd(r.startKey));
                if (r.startKey == From
                    && ((WasPortal && r.endKey == otherEnd(r.startKey)) || (!WasPortal && r.endKey != otherEnd(r.startKey)))
                    && Taken.indexOf(r.endKey) == -1) //
                {
                    // trace(r.startKey + " -> " + r.endKey);
                    // var cacheKey:String = getCacheKey(r.startKey + "->" + r.endKey, Taken);
                    // // PlayState.addOutput(cacheKey);
                    // if (cache.exists(cacheKey))
                    //     result = cache.get(cacheKey);
                    // else
                    // {
                    // if (r.endKey == "Z")
                    //     d = 0;
                    // else
                    d = r.length + distanceToExit(r.endKey, End, !WasPortal, addKey(Taken, r.startKey));
                    if (d < result)
                    {
                        result = d;
                    }
                    //     cache.set(cacheKey, d);
                    // }
                }
            }
        }
        // trace(result);
        return result;
    }

    private function otherEnd(Key:String):String
    {
        // trace(Key, Key.charCodeAt(0), String.fromCharCode(Key.charCodeAt(0) + 32), String.fromCharCode(Key.charCodeAt(0) - 32));
        if (Key.charCodeAt(0) <= 96)
            return String.fromCharCode(Key.charCodeAt(0) + 32);
        else
            return String.fromCharCode(Key.charCodeAt(0) - 32);
    }

    private function addKey(T:Array<String>, Key:String):Array<String>
    {
        var keys:Array<String> = [Key];

        // if (Key.charCodeAt(0) <= 93)
        //     keys.push(String.fromCharCode(Key.charCodeAt(0) + 65));
        // else
        //     keys.push(String.fromCharCode(Key.charCodeAt(0) - 65));

        return T.concat(keys);
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
        if (Start == End)
            return null;
        var startIndex:Int = portals.get(Start);

        var endIndex:Int = portals.get(End);
        // Check if any point given is outside the tilemap
        if ((startIndex < 0) || (endIndex < 0))
            return null;
        if (Start.charCodeAt(0) == otherEnd(End).charCodeAt(0) || End.charCodeAt(0) == otherEnd(Start).charCodeAt(0))
        {
            return new Day20Route(Start, End, 1);
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

// class Day20Node
// {
//     public var name:String = "";
//     public var len:Int = 0;
//     public function new(Name:String = "", Len:Int = 0)
//     {
//         name = Name;
//         len = Len;
//     }
// }
// class Graph
// {
//     private var v:Int;
//     private var adj:Map<String, Array<String>>;
//     private var path:Array<String>;
//     public function new(V:Int)
//     {
//         v = V;
//         adj = new Map<String, Array<String>>();
//     }
//     public function addEdge(V:String, W:String):Void
//     {
//         var a:Array<String> = [W];
//         if (adj.exists(V))
//             a = a.concat(adj.get(V));
//         adj.set(V, a);
//     }
//     public function BFS(S:String):Array<String>
//     {
//         path = [];
//         var visited:Map<String, Bool> = [];
//         for (k in adj.keys())
//             visited.set(k, false);
//         var queue:Array<String> = [];
//         visited.set(S, true);
//         queue.push(S);
//         while (queue.length > 0)
//         {
//             var s = queue.shift();
//             path.push(s);
//             for (i in adj.get(s))
//             {
//                 if (!visited.get(i))
//                 {
//                     visited.set(i, true);
//                     queue.push(i);
//                 }
//             }
//         }
//         return path;
//     }
// }

class Day20Route
{
    public var startKey:String = "";
    public var endKey:String = "";
    public var length:Int = 0;

    public function new(Start:String, End:String, Length:Int)
    {
        startKey = Start;
        endKey = End;
        length = Length;
    }
}
