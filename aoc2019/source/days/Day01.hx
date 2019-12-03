package days;

import openfl.Assets;

class Day01 extends Day
{
    override public function start():Void
    {
        var fuel:Int = 0;
        for (d in Assets.getText(AssetPaths.day01__txt).split("\r\n"))
        {
            fuel += calculateFuel(Std.parseInt(d));
        }
        trace("Day 1 Answer: " + fuel + " Fuel");

        fuel = 0;
        var newFuel:Int = 0;
        for (d in Assets.getText(AssetPaths.day01__txt).split("\r\n"))
        {
            newFuel = Std.parseInt(d);
            do
            {
                newFuel = calculateFuel(newFuel);
                if (newFuel > 0)
                {
                    fuel += newFuel;
                }
            }
            while (newFuel > 0);
        }
        trace("Day 1b Answer: " + fuel + " Fuel");
    }

    private function calculateFuel(Amount:Int):Int
    {
        return Std.int(Amount / 3) - 2;
    }
}
