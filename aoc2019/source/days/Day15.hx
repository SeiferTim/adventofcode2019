package days;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import flixel.util.FlxSort;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import haxe.Int64;
import flixel.math.FlxAngle;
import flixel.ui.FlxSpriteButton;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.utils.Assets;
import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import intcode.Computer;

class Day15 extends Day
{
    public static inline final TILE_UNKNOWN:Int = 0;
    public static inline final TILE_FLOOR:Int = 1;
    public static inline final TILE_START:Int = 2;
    public static inline final TILE_END:Int = 3;
    public static inline final TILE_WALL:Int = 4;
    public static final MAP_WIDTH:Int = 50;
    public static final MAP_HEIGHT:Int = 50;
    public static final TILE_SIZE:Int = 1;

    public var map:FlxTilemap;
    public var mapData:Array<Int> = [for (i in 0...(MAP_WIDTH * MAP_HEIGHT)) 0];
    public var robots:Array<Robot> = [];

    public var ss:Day15SubState;

    public static final START:FlxPoint = FlxPoint.get(Std.int(MAP_WIDTH / 2), Std.int(MAP_HEIGHT / 2));

    public var bestToEnd:Int = 99999;
    public var endLocation:FlxPoint;

    public var distances:Array<Int> = [for (i in 0...(MAP_WIDTH * MAP_HEIGHT)) -1];

    override public function start():Void
    {
        map = new FlxTilemap();
        mapData[Std.int(START.y * MAP_WIDTH + START.x)] = TILE_START;
        map.loadMapFromArray(mapData, MAP_WIDTH, MAP_HEIGHT, "assets/images/robot_map_tiles.png", TILE_SIZE, TILE_SIZE, FlxTilemapAutoTiling.OFF, 0, 0,
            TILE_WALL);

        var program:String = Assets.getText("assets/data/day15.txt");

        mapData = [for (i in 0...(MAP_WIDTH * MAP_HEIGHT)) 99999];
        for (i in 0...4)
        {
            robots.push(new Robot(new Computer(program), START.x, START.y, i + 1, 0, this));
        }
        ss = new Day15SubState(map, robots, this);
        FlxG.state.openSubState(ss);
    }

    public function foundEnd(Pos:FlxPoint, Steps:Int):Void
    {
        endLocation = Pos.copyTo();
        if (bestToEnd > Steps)
            bestToEnd = Steps;
        // for (r in robots)
        // {
        //     if (r.steps >= bestToEnd)
        //         r.kill();
        // }
    }

    public function calculateDistances():Int
    {
        var tmp:Array<Int> = map.getTileInstances(TILE_UNKNOWN);
        for (i in tmp)
        {
            map.setTileByIndex(i, TILE_WALL);
        }

        distances = map.computePathDistance(Std.int(endLocation.y * MAP_WIDTH + endLocation.y), Std.int(START.y * MAP_WIDTH + START.x),
            FlxTilemapDiagonalPolicy.NONE, false);
        var largest:Int = 0;
        var largestAmt:Int = 0;
        for (i in 0...distances.length)
        {
            if (distances[i] > largestAmt)
            {
                largest = i;
                largestAmt = distances[i];
            }
        }

        distances = map.computePathDistance(Std.int(endLocation.y * MAP_WIDTH + endLocation.y), largest, FlxTilemapDiagonalPolicy.NONE, false);
        var tmp:Array<Int> = map.getTileInstances(TILE_WALL);
        for (i in tmp)
        {
            distances[i] = -10;
        }

        largest = largestAmt = 0;

        for (i in 0...distances.length)
        {
            if (distances[i] > largestAmt)
            {
                largest = i;
                largestAmt = distances[i];
            }
        }

        var bmp:BitmapData = new BitmapData(MAP_WIDTH, MAP_HEIGHT, true, 0x0);
        bmp.lock();

        for (i in 0...distances.length)
        {
            if (distances[i] >= 0)
                bmp.setPixel32(i % MAP_WIDTH, Std.int(i / MAP_WIDTH), FlxColor.fromHSB((distances[i] / largestAmt) * 360, 1, 1));
        }

        bmp.unlock();

        var b:FlxSprite = new FlxSprite();
        b.loadGraphic(bmp);
        b.scale.set(5, 5);
        b.centerOffsets();
        b.centerOrigin();
        b.screenCenter(FlxAxes.XY);
        ss.add(b);

        trace(distances);

        return largestAmt;
    }
}

class Day15SubState extends FlxSubState
{
    public var map:FlxTilemap;
    public var robots:Array<Robot>;

    public var rSprites:FlxTypedGroup<Robot>;

    public var parent:Day15;
    public var stop:Bool = false;

    public function new(Map:FlxTilemap, Robots:Array<Robot>, Parent:Day15)
    {
        super();

        parent = Parent;
        map = Map;
        map.scale.set(5, 5);
        map.screenCenter(FlxAxes.XY);
        add(map);

        rSprites = new FlxTypedGroup<Robot>();
        add(rSprites);
        robots = Robots;
        for (r in robots)
        {
            r.program.start();
            rSprites.add(r);
        }
    }

    private function updateRobotPos():Void
    {
        for (r in rSprites.members.filter(function(R) return R.alive && R.exists && R.program.state == Computer.STATE_WAITING))
            r.move();
        if (rSprites.countLiving() == 0)
        {
            var s:String = "Day 15 Fewest Steps: " + parent.bestToEnd;
            PlayState.addOutput(s);
            trace(s);
            stop = true; // we have the whole map at this point?! check how long it takes to fill with O2
            var timeToFill:Int = parent.calculateDistances();
            s = 'Day 15b Time to Fill $timeToFill min';
            PlayState.addOutput(s);
            trace(s);
        }
    }

    private function sortByValue(A:Int, B:Int):Int
    {
        return FlxSort.byValues(FlxSort.DESCENDING, A, B);
    }

    private function updateMapPos():Void
    {
        if (FlxG.keys.anyJustReleased([ESCAPE]))
        {
            close();
        }
        else if (FlxG.keys.anyJustReleased([SPACE]))
        {
            map.screenCenter(FlxAxes.XY);
        }
        else
        {
            if (FlxG.keys.anyPressed([LEFT, A]))
            {
                map.x += 10;
            }
            else if (FlxG.keys.anyPressed([RIGHT, D]))
            {
                map.x -= 10;
            }

            if (FlxG.keys.anyPressed([DOWN, S]))
            {
                map.y += 10;
            }
            else if (FlxG.keys.anyPressed([UP, W]))
            {
                map.y -= 10;
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!stop)
            updateRobotPos();
        else
        {
            // we have the whole map!
        }

        updateMapPos();
    }
}

class Robot extends FlxSprite
{
    private static final HIT_WALL:Int = 0;
    private static final MOVED:Int = 1;
    private static final MOVED_TO_END:Int = 2;
    private static final N:Int = 1;
    private static final S:Int = 2;
    private static final W:Int = 3;
    private static final E:Int = 4;

    public var parent:Day15;

    public var program:Computer;
    public var location:FlxPoint;
    public var dir:Int;
    public var steps:Int = 0;

    public function new(Program:Computer, X:Float, Y:Float, Dir:Int, Steps:Int = 0, Parent:Day15)
    {
        super(0, 0, "assets/images/robot.png");
        steps = Steps;
        parent = Parent;
        program = Program;
        location = FlxPoint.get(X, Y);
        dir = Dir;
        angle = switch (dir)
        {
            case N:
                -90;
            case S:
                90;
            case W:
                0;
            case E:
                180;
            default:
                0;
        };
    }

    private function checkNextLocation(NewLocation:FlxPoint):Bool
    {
        var t:Int = parent.map.getTile(Std.int(NewLocation.x), Std.int(NewLocation.y));
        var s:Int = parent.mapData[Std.int(NewLocation.y * Day15.MAP_WIDTH + NewLocation.y)];
        if (s == Day15.TILE_WALL)
            return false;
        else if (t != Day15.TILE_UNKNOWN && s <= steps)
            return false;
        return true;
    }

    public function move():Void
    {
        if (!alive || program.state != Computer.STATE_WAITING)
            return;
        var newPos:Int = -1;
        var newLocation:FlxPoint = location.copyTo();
        var newTile:Int = -1;
        switch (dir)
        {
            case N:
                newLocation.y--;
            case S:
                newLocation.y++;
            case W:
                newLocation.x--;
            case E:
                newLocation.x++;
        }

        // before we move, if we already know about the new location - and it's a wall or someone has gotten there faster, we don't need to do anything and can die.
        if (!checkNextLocation(newLocation))
        {
            kill();
            return;
        }

        // trace(location, dir);
        program.start([dir]);
        if (program.outputs.length > 0)
        {
            switch (Int64.toInt(program.outputs.pop()))
            {
                case HIT_WALL:
                    // trace("HIT WALL!");
                    parent.map.setTile(Std.int(newLocation.x), Std.int(newLocation.y), Day15.TILE_WALL);
                    kill();
                    return;
                case MOVED:
                    // trace("MOVED!");
                    newTile = Day15.TILE_FLOOR;
                case MOVED_TO_END:
                    // trace("FOUND END!");
                    newTile = Day15.TILE_END;
            }

            steps++;
            // if (steps > parent.bestToEnd)
            // {
            //     kill();
            //     return;
            // }

            newPos = parent.map.getTile(Std.int(newLocation.x), Std.int(newLocation.y));
            if (newPos != Day15.TILE_UNKNOWN)
            {
                if (parent.mapData[Std.int(newLocation.y * Day15.MAP_WIDTH + newLocation.x)] <= steps)
                {
                    // trace(parent.mapData[Std.int(newLocation.y * Day15.MAP_WIDTH + newLocation.x)], steps);
                    kill();
                    return;
                }
            }
            else
            {
                parent.map.setTile(Std.int(newLocation.x), Std.int(newLocation.y), newTile);
            }
            parent.mapData[Std.int(newLocation.y * Day15.MAP_WIDTH + newLocation.x)] = steps;

            if (newTile == Day15.TILE_END)
            {
                parent.foundEnd(newLocation, steps);
                kill();
                return;
            }

            location.copyFrom(newLocation);

            // spawn 3 new robots and then die
            var newR:Robot;
            var revDir:Int = switch (dir)
            {
                case N:
                    S;
                case S:
                    N;
                case W:
                    E;
                case E:
                    W;
                default:
                    0;
            }
            var tmpLoc:FlxPoint = newLocation.copyTo();
            for (i in 1...5)
            {
                if (revDir != i)
                {
                    newR = new Robot(program.clone(), newLocation.x, newLocation.y, i, steps, this.parent);
                    parent.ss.rSprites.add(newR);
                    parent.robots.push(newR);
                }
            }
            kill();
        }
        else
        {
            // trace("state: " + program.state);
            kill();
        }
    }

    override public function draw():Void
    {
        x = parent.map.x + (location.x * 5);
        y = parent.map.y + (location.y * 5);

        angle = switch (dir)
        {
            case N:
                -90;
            case S:
                90;
            case W:
                0;
            case E:
                180;
            default:
                0;
        };
        super.draw();
    }

    override public function kill():Void
    {
        // trace('killed...');
        super.kill();
        // parent.robots.remove(this);
        parent = null;
        program = null;
    }
}
