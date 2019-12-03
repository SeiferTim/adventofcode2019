package;

import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxState;
import days.Day01;
import days.Day02;
import days.Day03;

class PlayState extends FlxState
{
    public static final DAYS:Int = 3;

    override public function create():Void
    {
        var t:FlxText = new FlxText(10, 10, "Select a Day to Run:");
        add(t);
        for (i in 0...DAYS)
        {
            addDayButton(i);
        }
        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    private function addDayButton(Number:Int):Void
    {
        var b:FlxButton = new FlxButton(10, 10, Std.string(Number + 1), callDay.bind(Number));
        b.x = 10 + ((b.width + 10) * ((Number) % 7));
        b.y = 30 + ((b.height + 10) * Std.int((Number) / 7));
        add(b);
    }

    private function callDay(Number:Int):Void
    {
        var cName:String = "days.Day" + StringTools.lpad(Std.string(Number + 1), "0", 2);
        var day:Day = Type.createInstance(Type.resolveClass(cName), []);
        day.start();
    }
}
