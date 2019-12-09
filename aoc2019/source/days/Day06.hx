package days;

import openfl.Assets;

class Day06 extends Day
{
    public var bodies:Map<String, String> = [];
    public var orbits:Int = 0;

    public var steps:Map<String, Map<String, Int>> = [];

    override public function start():Void
    {
        var tmp:Array<String> = Assets.getText("assets/data/day06.txt").split("\r\n");
        var parts:Array<String> = [];
        for (t in tmp)
        {
            parts = t.split(")");
            bodies.set(parts[1], parts[0]);
        }
        for (body => parent in bodies)
        {
            orbits += follow(parent);
        }

        trace('Answer for Day06: $orbits');

        chart("YOU");
        chart("SAN");

        var dist:Int = distance("YOU", "SAN");

        trace('Answer for Day06b: $dist');
    }

    private function distance(BodyA:String, BodyB:String):Int
    {
        var node:String = findClosestMatch(BodyA, BodyB);
        return steps.get(BodyA).get(node) + steps.get(BodyB).get(node);
    }

    private function findClosestMatch(BodyA:String, BodyB:String):String
    {
        var match:String = "";
        var length:Int = -1;
        var a:Map<String, Int> = steps.get(BodyA);
        var b:Map<String, Int> = steps.get(BodyB);
        var f:Int = -1;
        for (id => dist in a)
        {
            if (b.exists(id))
            {
                f = follow(id);
                if (f > length)
                {
                    match = id;
                    length = f;
                }
            }
        }

        return match;
    }

    private function follow(Orbit:String):Int
    {
        if (Orbit == "COM")
        {
            return 1;
        }
        else
        {
            return 1 + follow(bodies.get(Orbit));
        }
    }

    private function chart(Start:String):Void
    {
        var c:Map<String, Int> = [];
        var s:Int = 0;
        var parent:String = bodies.get(Start);
        do
        {
            c.set(parent, s);
            parent = bodies.get(parent);
            s++;
        }
        while (parent != "COM");
        c.set("COM", s);
        steps.set(Start, c);
    }
}
