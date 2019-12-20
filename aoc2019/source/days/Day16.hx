package days;

import openfl.Assets;

class Day16 extends Day
{
    override public function start():Void
    {
        // var answer:String = processSignal(Assets.getText("assets/data/day16.txt"), 1, 0);
        // var s:String = 'Day 16 Answer: $answer';
        // PlayState.addOutput(s);

        var i:String = Assets.getText("assets/data/day16b.txt");
        var answerB:String = processSignal(i, 1000, Std.parseInt(i.substr(0, 7)));
        var s:String = 'Day 16b Answer: $answerB';
        PlayState.addOutput(s);
    }

    private function processSignal(Data:String, ?Times:Int = 1, ?Offset:Int = 0):String
    {
        var data:Array<Int> = Data.split("").map(function(v) return Std.parseInt(v));

        // trace(data.length, Offset);
        var size:Int = (10000 * data.length) - Offset;
        var input:Array<Int> = [];

        for (i in 0...size)
        {
            // trace(i, data.length, (Offset + i) % data.length, data[(Offset + i) % data.length]);
            input.push(data[(Offset + i) % data.length]);
        }

        // trace(size, data, input);

        for (phase in 0...100)
        {
            for (i in 0...size - 1)
            {
                input[size - 2 - i] = (input[size - 2 - i] + input[size - 1 - i]) % 10;
            }
        }

        // trace(input);

        return input.splice(0, 8).join("");
    }
}
