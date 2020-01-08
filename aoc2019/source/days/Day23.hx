package days;

import haxe.Int64;
import openfl.Assets;
import intcode.Computer;

class Day23 extends Day
{
    override public function start():Void
    {
        var program:String = Assets.getText("assets/data/day23.txt");
        var computers:Array<Computer> = [for (i in 0...50) new Computer(program)];
        var queue:Array<Array<Array<Int64>>> = [for (i in 0...50) []];

        for (i in 0...50)
        {
            computers[i].start();
            // trace(computers[i].outputs);
            computers[i].start([Int64.ofInt(i)]);
        }

        var done:Bool = false;
        var answer:Int64 = -1;
        var output:Array<Int64> = [];
        var packet:Array<Int64> = [];
        var o:Int = 0;
        var idle:Bool = false;
        var lastNATY:Int64 = -1;

        var nat:Array<Int64> = [];
        var idleTime:Int = 0;

        while (!done)
        {
            idle = true;
            for (i in 0...50)
            {
                if (computers[i].state == Computer.STATE_WAITING)
                {
                    output = computers[i].outputs.copy();

                    // trace(output);
                    if (output.length > 0)
                    {
                        idle = false;
                    }
                    if (output.length >= 3)
                    {
                        o = 0;
                        while (o < output.length - 2)
                        {
                            if (Int64.toInt(output[o]) == 255)
                            {
                                nat = [output[o + 1], output[o + 2]];
                            }
                            else
                                queue[Int64.toInt(output[o])].push([output[o + 1], output[o + 2]]);

                            o += 3;
                        }
                    }
                    if (queue[i].length == 0)
                    {
                        computers[i].start([-1]);
                    }
                    else
                    {
                        idle = false;
                        packet = [];
                        while (queue[i].length > 0)
                        {
                            packet = packet.concat(queue[i].shift());
                        }
                        computers[i].start(packet);
                    }
                }
            }

            // trace(queue);
            if (idle)
            {
                idleTime++;
            }
            else
            {
                idleTime = 0;
            }

            if (idleTime > 10 && nat.length > 0)
            {
                if (lastNATY == nat[1])
                {
                    done = true;
                    answer = nat[1];
                    break;
                }
                else
                {
                    lastNATY = nat[1];
                    computers[0].start(nat.copy());
                    idleTime = 0;
                    idle = false;
                }
            }
            if (idle)
                trace("Idle: " + idleTime + ", NAT: " + nat);
            else
                trace("Not Idle." + " NAT: " + nat);
        }

        PlayState.addOutput('Day 23 Answer: $answer');
    }
}
