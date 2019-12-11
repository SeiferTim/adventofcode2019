package days;

import haxe.Int64;
import intcode.Computer;
import openfl.Assets;

class Day07 extends Day
{
    private var iterations:Array<Int> = [0, 1, 2, 3, 4];
    private var iterationsB:Array<Int> = [5, 6, 7, 8, 9];
    private var highest:Int = 0;
    private var program:String = Assets.getText("assets/data/day07.txt");

    override public function start():Void
    {
        var perms:Perm = new Perm(iterations);
        var outSig:Int = 0;
        var comp:Computer = new Computer(program);

        for (p in perms.compute())
        {
            outSig = 0;
            while (p.length > 0)
            {
                comp.reset();
                comp.start([p.shift(), outSig]);

                if (comp.state == Computer.STATE_FINISHED)
                    outSig = Int64.toInt(comp.outputs[0]);

                if (outSig > highest)
                    highest = outSig;
            }
        }
        PlayState.addOutput('Day 07 Answer: $highest');

        var ampComps:Array<Computer> = [];
        var curComp:Int = 0;

        perms = new Perm(iterationsB);

        highest = 0;
        for (p in perms.compute())
        {
            ampComps = [];
            ampComps.push(new Computer(program)); // A
            ampComps.push(new Computer(program)); // B
            ampComps.push(new Computer(program)); // C
            ampComps.push(new Computer(program)); // D
            ampComps.push(new Computer(program)); // E
            curComp = 0;
            outSig = 0;

            for (a in ampComps)
            {
                a.start([p.shift()]);
            }

            do
            {
                if (ampComps[curComp].state == Computer.STATE_WAITING || ampComps[curComp].state == Computer.STATE_READY)
                {
                    ampComps[curComp].start([outSig]);

                    if (ampComps[curComp].state == Computer.STATE_WAITING || ampComps[curComp].state == Computer.STATE_FINISHED)
                    {
                        outSig = Int64.toInt(ampComps[curComp].outputs.pop());
                        curComp++;
                        if (curComp >= ampComps.length)
                            curComp = 0;
                    }
                }
                else
                {
                    break;
                }
            }
            while (ampComps[4].state != Computer.STATE_FINISHED);
            if (outSig > highest)
                highest = outSig;
        }

        PlayState.addOutput('Day 07b Answer: $highest');
    }
}
