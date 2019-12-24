package days;

import flixel.math.FlxMath;
import flixel.util.FlxArrayUtil;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import openfl.text.TextLineMetrics;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import openfl.Assets;

class Day18 extends Day
{
    private var playerStarts:Array<Int> = [];
    private var keys:Map<String, Int> = [];
    private var doors:Map<Int, String> = [];
    private var map:FlxTilemap;

    private var steps:Int = 0;

    private var mapWidth:Int = -1;
    private var mapHeight:Int = -1;

    private var mapData:Array<Int> = [];

    private var routes:Array<Route> = [];

    private var cache:Map<String, Int> = [];

    private var pathTaken:Array<String> = [];

    override public function start():Void
    {
        var dist:Int = 0;

        // loadMap("assets/data/day18.txt");
        // getRoutes();
        // // trace(routes);
        // dist = distanceToCollectKeys(["1"]);
        // PlayState.addOutput('Day 18 Answer: $dist');

        dist = 0;
        loadMap("assets/data/day18b.txt");
        getRoutes();
        dist = distanceToCollectKeys(["1", "2", "3", "4"]);
        PlayState.addOutput('Day 18b Answer: $dist');

        // var ss:Day18SubState = new Day18SubState(map, this);

        // FlxG.state.openSubState(ss);
    }

    private function getRoutes():Void
    {
        var from:Array<String> = [for (k in keys.keys()) k];
        var to:Array<String> = from.copy();
        for (i in 0...playerStarts.length)
            from.unshift(Std.string(i + 1));
        var r:Route = null;
        for (f in from)
        {
            for (t in to)
            {
                if (t != f)
                {
                    r = findPath(f, t);
                    if (r != null)
                    {
                        routes.push(r);
                    }
                }
            }
        }
    }

    private function loadMap(DataPath:String):Void
    {
        var tiles:BitmapData = makeTiles();

        var input:Array<Array<String>> = Assets.getText(DataPath).split("\r\n").map(function(v) return v.split(""));

        mapWidth = input[0].length;
        mapHeight = input.length;

        var tmp:Array<Int> = [];
        for (i in input)
        {
            tmp = i.filter(function(v) return v != "\r\n").map(function(v)
            {
                var result:Int = 0;
                if (v == "#")
                    result = 30;
                else if (v == ".")
                    result = 0;
                else if (v >= "a" && v <= "z")
                    result = v.charCodeAt(0) - "a".charCodeAt(0) + 2;
                else if (v >= "A" && v <= "Z")
                    result = v.charCodeAt(0) - "A".charCodeAt(0) + 31;
                else if (v == "@")
                {
                    result = 1;
                }
                return result;
            });
            mapData = mapData.concat(tmp);
        }

        // build lists of all keys and doors:
        for (n in 0...mapData.length)
        {
            if (mapData[n] == 1)
                playerStarts.push(n);
            else if (mapData[n] >= 2 && mapData[n] <= 28)
                keys.set(String.fromCharCode(mapData[n] - 2 + "a".charCodeAt(0)), n);
            else if (mapData[n] >= 31)
                doors.set(n, String.fromCharCode(mapData[n] - 31 + "A".charCodeAt(0)));
        }

        map = new FlxTilemap();
        map.loadMapFromArray(mapData, mapWidth, mapHeight, tiles, 10, 10, FlxTilemapAutoTiling.OFF, 0, 0, 30);
    }

    private function getCacheKey(From:String, Collected:Array<String>):String
    {
        var c:Array<String> = Collected.copy();
        c.sort(function(A, B) return A.charCodeAt(0) - B.charCodeAt(0));
        return From + ":" + c.join("");
    }

    private function haveAllNeededKeys(Needed:Array<String>, Collected:Array<String>):Bool
    {
        for (n in Needed)
        {
            if (Collected.indexOf(n.toLowerCase()) == -1)
                return false;
        }
        return true;
    }

    private function distanceToCollectKeys(From:Array<String>, ?Collected:Array<String>):Int
    {
        if (Collected == null)
            Collected = [];

        var best:Int = mapWidth * mapHeight * 4;

        var cacheKey:String = getCacheKey(From.join(""), Collected);
        if (cache.exists(cacheKey))
        {
            best = cache.get(cacheKey);
        }
        else
        {
            for (whichBot in 0...From.length)
            {
                var result:Int = mapWidth * mapHeight * 4;

                var d:Int = 0;
                /// if we have no more keys we can get to, return 0
                if (Collected.length >= [for (k in keys.keys()) k].length)
                {
                    result = 0;
                }
                else
                {
                    for (r in routes)
                    {
                        if (r.startKey == From[whichBot] && Collected.indexOf(r.endKey) == -1)
                        {
                            if (haveAllNeededKeys(r.keysNeeds, Collected))
                            {
                                d = r.distance
                                    + distanceToCollectKeys([for (i in 0...From.length) (i == whichBot) ?r.endKey:From[i]], Collected.concat([r.endKey]));
                                if (d < result)
                                {
                                    result = d;
                                }
                            }
                        }
                    }
                }
                if (result < best)
                {
                    best = result;
                }
            }
        }
        cache.set(cacheKey, best);
        return best;
    }

    private function findPath(Start:String, End:String):Route
    {
        // Figure out what tile we are starting and ending on.
        var startIndex:Int = Start >= "a" && Start <= "z" ? keys.get(Start) : playerStarts[Std.parseInt(Start) - 1];
        var endIndex:Int = End >= "a" && End <= "z" ? keys.get(End) : playerStarts[Std.parseInt(End) - 1];

        // Check if any point given is outside the tilemap
        if ((startIndex < 0) || (endIndex < 0))
            return null;

        // Figure out how far each of the tiles is from the starting tile
        var distances:Array<Int> = computePathDistance(startIndex, endIndex);

        if (distances == null)
        {
            return null;
        }

        // Then count backward to find the shortest path.
        var points:Array<Int> = [];
        walkPath(distances, endIndex, points);

        // Reset the start and end points to be exact
        var node:Int;
        // node = points[points.length - 1];
        // node.copyFrom(Start);
        // node = points[0];
        // node.copyFrom(End);

        // // Some simple path cleanup options
        // if (Simplify)
        // {
        //     simplifyPath(points);
        // }
        // if (RaySimplify)
        // {
        //     raySimplifyPath(points);
        // }

        // Finally load the remaining points into a new path object and return it
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

        var keysNeeded:Array<String> = [];
        for (n in path)
        {
            if (doors.exists(n))
                keysNeeded.push(doors.get(n));
        }

        var route:Route = new Route(Start, End, distances[endIndex], keysNeeded);
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

        for (l in 'a'.charCodeAt(0)...'z'.charCodeAt(0) + 1)
        {
            rectD.x += 10;
            tmp.fillRect(rectD, FlxColor.WHITE);
            hue += 360 / 27;
            letters.color = FlxColor.fromHSB(hue, 1, 1, 1);
            letters.text = String.fromCharCode(l);
            letters.drawFrame(true);

            metrics = letters.textField.getLineMetrics(0);

            rectS.y = letters.framePixels.height - metrics.height;
            rectS.width = letters.framePixels.width;

            point.x = Std.int(rectD.x + 5 - (rectS.width / 2));
            point.y = Std.int(5 - (rectS.height / 2));

            tmp.copyPixels(letters.framePixels, rectS, point, null, null, true);
        };

        rectD.x = 300;
        tmp.fillRect(rectD, FlxColor.GRAY);

        for (l in 'A'.charCodeAt(0)...'Z'.charCodeAt(0) + 1)
        {
            rectD.x += 10;
            hue += 360 / 27;

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
        };

        tmp.unlock();
        FlxG.bitmapLog.add(tmp);

        return tmp;
    }
}

class Day18SubState extends FlxSubState
{
    private var map:FlxTilemap;
    private var parent:Day18;

    public function new(Map:FlxTilemap, Parent:Day18)
    {
        super();
        parent = Parent;
        map = Map;
    }

    override public function create():Void
    {
        var scale:Float = Math.min(1, Math.min((FlxG.width - 10) / map.width, (FlxG.height - 10) / map.height));
        map.scale.set(scale, scale);

        map.screenCenter(FlxAxes.XY);
        add(map);

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.anyJustReleased([ESCAPE]))
            close();
    }
}

class Node
{
    public var name:String;
    public var distance:Int;
    public var parent:String;

    public function new(Name:String, Distance:Int, Parent:String)
    {
        name = Name;
        distance = Distance;
        parent = Parent;
    }
}

class Route
{
    public var startKey:String = "";
    public var endKey:String = "";
    public var keysNeeds:Array<String> = [];
    public var distance:Int = 0;

    public function new(Start:String, End:String, Distance:Int, Keys:Array<String>)
    {
        startKey = Start;
        endKey = End;
        distance = Distance;
        keysNeeds = Keys;
    }
}
