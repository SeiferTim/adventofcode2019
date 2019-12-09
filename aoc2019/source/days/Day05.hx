package days;

import intcode.Computer;
import openfl.Assets;

class Day05 extends Day
{
    override public function start():Void
    {
        var computer:Computer = new Computer(Assets.getText("assets/data/day05.txt"));
        computer.start([1]);
        if (computer.state == Computer.STATE_FINISHED)
            trace("Day 05 Computer Output: " + computer.outputs);

        // trace("Day 05 Computer Output: " + Computer.process(Assets.getText("assets/data/day05.txt"), 1));
        // trace("Day 05b Computer Output: " + Computer.start(Assets.getText("assets/data/day05.txt"), [5]));

        // trace("Day 05test Computer Output: " + Computer.process(Assets.getText("assets/data/Day05test.txt"), [5]));
    }
}
