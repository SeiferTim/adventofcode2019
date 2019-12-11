package;

import openfl.text.TextFieldType;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.text.TextFormat;
import openfl.text.TextField;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxState;
import days.Day01;
import days.Day02;
import days.Day03;
import days.Day04;
import days.Day05;
import days.Day06;
import days.Day07;
import days.Day08;
import days.Day09;
import days.Day10;

class PlayState extends FlxState
{
    public static final DAYS:Int = 10;

    private static var txtField:TextField;

    override public function create():Void
    {
        var t:FlxText = new FlxText(10, 10, "Select a Day to Run:");
        add(t);
        for (i in 0...DAYS)
        {
            addDayButton(i);
        }

        var tSX:Float = FlxG.game.width / FlxG.width;
        var tSY:Float = FlxG.game.height / FlxG.height;

        txtField = new TextField();

        txtField.embedFonts = true;
        txtField.defaultTextFormat = new TextFormat(t.font, Std.int(8 * tSY), FlxColor.WHITE);
        txtField.x = 10 * tSX;
        txtField.y = FlxG.height - (210 * tSY);
        txtField.width = FlxG.width - (20 * tSX);
        txtField.height = 200 * tSY;
        txtField.type = TextFieldType.DYNAMIC;
        txtField.multiline = true;
        txtField.wordWrap = true;
        txtField.border = true;
        txtField.borderColor = FlxColor.GRAY;
        txtField.backgroundColor = FlxColor.BLACK;
        txtField.selectable = true;
        FlxG.addChildBelowMouse(txtField);

        txtField.scrollV = txtField.maxScrollV;
    }

    public static function addOutput(Message:String = ""):Void
    {
        txtField.text += '$Message\n';
        txtField.scrollV = txtField.maxScrollV;
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
