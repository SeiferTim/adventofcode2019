package days;

import openfl.Assets;
import intcode.Computer;

class Day09 extends Day
{
    override public function start():Void
    {
        var c:Computer = new Computer(Assets.getText("assets/data/day09.txt"));
        c.start([1]);
        PlayState.addOutput("Test 1 Output: " + c.outputs.join(","));

        c.reset();
        c.start([2]);
        PlayState.addOutput("Test 1b Output: " + c.outputs.join(","));
    }
}
