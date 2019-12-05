package days;

import intcode.Computer;
import openfl.Assets;

class Day05 extends Day
{
    override public function start():Void
    {
        // trace("Day 05 Computer Output: " + Computer.process(Assets.getText("assets/data/day05.txt"), 1));
        trace("Day 05b Computer Output: " + Computer.process(Assets.getText("assets/data/day05.txt"), 5));

        trace("Day 05test Computer Output: " + Computer.process(Assets.getText("assets/data/Day05test.txt"), 5));
    }
}
