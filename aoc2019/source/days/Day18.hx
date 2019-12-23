package days;

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
    private var playerStart:Int;
    private var keys:Map<String, Int> = [];
    private var map:FlxTilemap;

    private var steps:Int = 0;

    private var mapWidth:Int = -1;
    private var mapHeight:Int = -1;

    private var mapData:Array<Int> = [];
    private var path:Array<Node> = [];

    private var cache:Map<String, Int> = [];

    override public function start():Void
    {
        var tiles:BitmapData = makeTiles();

        var input:Array<Array<String>> = Assets.getText("assets/data/day18.txt").split("\r\n").map(function(v) return v.split(""));

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
                playerStart = n;
            else if (mapData[n] >= 2 && mapData[n] <= 28)
                keys.set(String.fromCharCode(mapData[n] - 2 + "a".charCodeAt(0)), n);
            // else if (mapData[n] >= 31)
            // {
            //     doors.set(String.fromCharCode(mapData[n] - 31 + "A".charCodeAt(0)), n);
            // }
        }

        map = new FlxTilemap();
        map.loadMapFromArray(mapData, mapWidth, mapHeight, tiles, 10, 10, FlxTilemapAutoTiling.OFF, 0, 0, 30);

        /// find shortest route

        var dist:Int = shortestPath("@", [], 0);

        trace(dist);

        var ss:Day18SubState = new Day18SubState(map, this);

        FlxG.state.openSubState(ss);
    }

    private function shortestPath(From:String, Visited:Array<String>, Distance:Int):Int
    {
        if (steps % 100==0)
            trace('steps: $steps');
        steps++;

        var visited:Array<String> = Visited.copy().concat([From]);
        visited.sort(function(A, B) return A.charCodeAt(0) - B.charCodeAt(0));

        var neighbors:Array<Node> = [];

        var cacheName:String = From + ":" + visited.join("");

        //        trace(cacheName);

        var c:Int = 0;
        if (cache.exists(cacheName))
        {
            c = cache.get(cacheName);
            // trace('pulled from cache: $c');
        }
        else
        {
            var dists:Array<Int> = [];
            for (k => n in keys) // for every key...
            {
                if (k != From && visited.indexOf(k) == -1) // .. if it's not the key we're on, and we haven't visited it before...
                {
                    dists = computePathDistance(From == "@" ? playerStart : keys.get(From), n, visited);
                    if (dists != null)
                    {
                        neighbors.push(new Node(k, dists[n], From));
                    }
                }
            }

            if (neighbors.length == 0)
            {
                c = 0;
            }
            else
            {
                var best:Int = -1;
                var t:Int = 0;
                for (n in neighbors)
                {
                    t = shortestPath(n.name, visited, n.distance);
                    if (t < best || best == -1)
                        best = t;
                }
                c = (best > -1 ? best : 0);
            }

            cache.set(cacheName, c);
        }
        return c + Distance;
    }

    private function computePathDistance(StartIndex:Int, EndIndex:Int, KeysCollected:Array<String>):Array<Int>
    {
        // Create a distance-based representation of the tilemap.
        // All walls are flagged as -2, all open areas as -1.
        var mapSize:Int = mapWidth * mapHeight;
        var distances:Array<Int> = new Array<Int>( /*mapSize*/);
        FlxArrayUtil.setLength(distances, mapSize);
        var i:Int = 0;

        while (i < mapSize)
        {
            if (mapData[i] == 30
                || mapData[i] > 30
                && KeysCollected.indexOf(String.fromCharCode(mapData[i] - 31 + "a".charCodeAt(0))) == -1)
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

    private function getClosestNode(Nodes:Array<Node>):String
    {
        var d:Int = 99999;
        var best:Node = null;
        for (n in Nodes)
        {
            if (n.distance < d)
            {
                d = n.distance;
                best = n;
            }
        }
        steps += d;
        path.push(best);
        return best.name;
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
        map.screenCenter(FlxAxes.XY);
        add(map);

        super.create();
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
