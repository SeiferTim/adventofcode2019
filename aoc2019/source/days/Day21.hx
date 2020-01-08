package days;

import intcode.Computer;
import openfl.Assets;
import haxe.Int64;

class Day21 extends Day
{
    private var computer:Computer = new Computer(Assets.getText("assets/data/day21.txt"));

    override public function start():Void
    {
        // computer.start();
        // PlayState.addOutput(Computer.parseResults(computer.outputs));

        var commands:Array<String> = [];
        // commands = ["NOT C J", "AND D J", "NOT A T", "OR T J"];

        // commands.push("WALK");

        // for (c in commands)
        // {
        //     trace(c);
        //     computer.start(Computer.commands(c));
        // }
        // PlayState.addOutput(Computer.parseResults(computer.outputs));

        // computer.reset();

        computer.start();
        PlayState.addOutput(Computer.parseResults(computer.outputs));

        commands = [
            "NOT C J",
            "AND D J",
            "AND H J",
            "NOT B T",
            "AND D T",
            "OR T J",
            "NOT A T",
            "OR T J"
        ];

        commands.push("RUN");

        for (c in commands)
        {
            trace(c);
            computer.start(Computer.commands(c));
            PlayState.addOutput(Computer.parseResults(computer.outputs));
        }
    }
}
