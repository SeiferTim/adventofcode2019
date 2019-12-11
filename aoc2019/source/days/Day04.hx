package days;

class Day04 extends Day
{
    private static inline final RANGE_START:String = "193651";
    private static inline final RANGE_END:String = "649729";

    private var matches:Array<String> = [];

    override public function start():Void
    {
        var checkValue:String = RANGE_START;
        do
        {
            findMatch(checkValue);
            checkValue = Std.string(Std.parseInt(checkValue) + 1);
        }
        while (Std.parseInt(checkValue) <= Std.parseInt(RANGE_END));

        PlayState.addOutput("Day 4 Answer: " + Std.string(matches.length));

        // PlayState.addOutput(matches);
    }

    private function findMatch(Value:String):Void
    {
        var hasDouble:Bool = false;
        var isGood:Bool = true;
        var chars:Array<String> = Value.split("");
        var doubleChar:String = "";
        for (i in 1...chars.length)
        {
            if (chars[i - 1] > chars[i])
            {
                isGood = false;
                break;
            }
        }
        if (isGood)
        {
            for (i in 1...chars.length)
            {
                if (chars[i - 1] == chars[i])
                {
                    if (doubleChar == chars[i])
                    {
                        hasDouble = false;
                    }
                    else
                    {
                        hasDouble = true;
                        doubleChar = chars[i];
                    }
                }
                else
                {
                    if (hasDouble)
                        break;
                    else
                        doubleChar = "";
                }
            }
            if (hasDouble)
                matches.push(Value);
        }
    }
}
