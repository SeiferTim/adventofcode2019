package days;

import flixel.util.FlxArrayUtil;
import openfl.Assets;

class Day12 extends Day
{
    override public function start():Void
    {
        var data:String = Assets.getText("assets/data/day12.txt");
        var pattern = ~/(?:<x=)(-?\d+)(?:, y=)(-?\d+)(?:, z=)(-?\d+)(?:>)/g;
        var inputs:Array<String> = data.split("\n");
        var moonsInitial:Array<Moon> = [];
        var moons:Array<Moon> = [];
        var moons2:Array<Moon> = [];
        var no:Int = 0;
        for (i in inputs)
        {
            if (pattern.match(i))
            {
                moonsInitial.push(new Moon(no, Std.parseInt(pattern.matched(1)), Std.parseInt(pattern.matched(2)), Std.parseInt(pattern.matched(3))));
                moons.push(new Moon(no, Std.parseInt(pattern.matched(1)), Std.parseInt(pattern.matched(2)), Std.parseInt(pattern.matched(3))));
                moons2.push(new Moon(no, Std.parseInt(pattern.matched(1)), Std.parseInt(pattern.matched(2)), Std.parseInt(pattern.matched(3))));
                no++;
            }
        }

        var pairs:Array<Array<Int>> = [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]];

        for (i in 0...1000)
        {
            for (p in pairs)
            {
                computeGravity(moons[p[0]], moons[p[1]]);
            }
            for (m in moons)
            {
                m.updatePosition();
            }
        }

        PlayState.addOutput("Day 12 Answer: " + getTotalEnergy(moons));

        var steps:Int = 0;
        var stepsUntil:Triplicate = new Triplicate(-1, -1, -1);

        do
        {
            for (p in pairs)
            {
                computeGravity(moons2[p[0]], moons2[p[1]]);
            }
            for (m in moons2)
            {
                m.updatePosition();
            }
            steps++;

            if (stepsUntil.x == -1 && getStateX(moons2) == getStateX(moonsInitial))
                stepsUntil.x = steps;
            if (stepsUntil.y == -1 && getStateY(moons2) == getStateY(moonsInitial))
                stepsUntil.y = steps;
            if (stepsUntil.z == -1 && getStateZ(moons2) == getStateZ(moonsInitial))
                stepsUntil.z = steps;
        }
        while ((stepsUntil.x == -1 || stepsUntil.y == -1 || stepsUntil.z == -1));

        trace(stepsUntil);
        PlayState.addOutput("Day 12b Answer: " + Functions.lcmMulti([stepsUntil.x, stepsUntil.y, stepsUntil.z]));
    }

    private function getStateX(M:Array<Moon>):String
    {
        return M.map(function(v) return v.position.x).join(",") + "|" + M.map(function(v) return v.velocity.x).join(",");
    }

    private function getStateY(M:Array<Moon>):String
    {
        return M.map(function(v) return v.position.y).join(",") + "|" + M.map(function(v) return v.velocity.y).join(",");
    }

    private function getStateZ(M:Array<Moon>):String
    {
        return M.map(function(v) return v.position.z).join(",") + "|" + M.map(function(v) return v.velocity.z).join(",");
    }

    private function getStates(M:Array<Moon>):String
    {
        return M.map(function(v) return v.state).join(',');
    }

    private function getTotalEnergy(Moons:Array<Moon>):Int
    {
        var t:Int = 0;
        for (m in Moons)
        {
            t += m.totalEnergy;
        }
        return t;
    }

    private function computeGravity(M1:Moon, M2:Moon):Void
    {
        M1.velocity.x += gravityChange(M1.position.x, M2.position.x);

        M1.velocity.y += gravityChange(M1.position.y, M2.position.y);
        M1.velocity.z += gravityChange(M1.position.z, M2.position.z);

        M2.velocity.x += gravityChange(M2.position.x, M1.position.x);
        M2.velocity.y += gravityChange(M2.position.y, M1.position.y);
        M2.velocity.z += gravityChange(M2.position.z, M1.position.z);
    }

    private function gravityChange(A:Int, B:Int):Int
    {
        if (A > B)
            return -1;
        else if (A < B)
            return 1;
        return 0;
    }
}

class Moon
{
    public var id:Int = -1;
    public var position:Triplicate;

    public var velocity:Triplicate;

    public var pot(get, null):Int;
    public var kin(get, null):Int;
    public var totalEnergy(get, null):Int;

    public var state(get, null):String;

    public function new(ID:Int, X:Int, Y:Int, Z:Int)
    {
        id = ID;
        position = new Triplicate(X, Y, Z);
        velocity = new Triplicate();
    }

    public function updatePosition():Void
    {
        position.x += velocity.x;
        position.y += velocity.y;
        position.z += velocity.z;
    }

    private function get_state():String
    {
        return '{$position.x,$position.y,$position.z},{$velocity.x,$velocity.y,$velocity.z}';
    }

    private function get_pot():Int
    {
        return Std.int(Math.abs(position.x) + Math.abs(position.y) + Math.abs(position.z));
    }

    private function get_kin():Int
    {
        return Std.int(Math.abs(velocity.x) + Math.abs(velocity.y) + Math.abs(velocity.z));
    }

    private function get_totalEnergy():Int
    {
        return Std.int(pot * kin);
    }
}

class Triplicate
{
    public var x:Int;
    public var y:Int;
    public var z:Int;

    public function new(?X:Int = 0, ?Y:Int = 0, ?Z:Int = 0)
    {
        x = X;
        y = Y;
        z = Z;
    }
}
