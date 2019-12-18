package days;

import haxe.macro.Expr.Field;
import openfl.Assets;

class Day14 extends Day
{
    private var formulas:Map<String, Formula> = [];
    // private var leftovers:Map<String, Int> = [];
    private var amounts:Map<String, Float> = [];

    override public function start():Void
    {
        var data:String = Assets.getText("assets/data/day14.txt");
        var pattern = ~/([0-9]+)(?:\s)([A-Z]+)/g;
        var inputs:Array<String> = data.split("\n");
        var tmp:Array<FormulaPart> = [];

        var t:FormulaPart;
        for (i in inputs)
        {
            tmp = [];
            while (pattern.match(i))
            {
                tmp.push(new FormulaPart(Std.parseInt(pattern.matched(1)), pattern.matched(2)));
                i = pattern.matchedRight();
            }
            t = tmp.pop();
            formulas.set(t.compound, new Formula(tmp, t));
        }

        var amount:Float = 0;
        amount = getAmounts();
        PlayState.addOutput("Day 14 answer: " + amount);
    }

    private function getAmounts():Int
    {
        var amt:Float = 0;
        var f:Formula;
        var onlyOre:Bool = false;
        var thisOre:Bool = false;
        var ore:Int = 0;
        var amount:Float = 0;

        amounts.set("FUEL", 1);

        while (!onlyOre)
        {
            onlyOre = true;
            for (c => a in amounts)
            {
                if (c != "ORE")
                {
                    amt = a;
                    f = formulas.get(c);
                    amounts.remove(c);
                    thisOre = false;
                    for (i in f.inputs)
                    {
                        if (i.compound == "ORE")
                        {
                            thisOre = true;
                            amounts.set(c, amt);
                        }
                        else
                        {
                            amount = Math.ceil(amt / f.output.amount) * i.amount; // if I don't `ceiling` this, my values are off from the example values by a TON.
                            if (amounts.exists(i.compound))
                                amount += amounts.get(i.compound);
                            trace(amt, c, i.amount, i.compound, amount);
                            amounts.set(i.compound, amount);
                        }
                    }
                    if (!thisOre)
                    {
                        onlyOre = false;
                    }
                }
            }

            trace(amounts);
        }

        for (c => a in amounts)
        {
            f = formulas.get(c);
            trace(a, f.output.amount, f.inputs[0].amount, Math.ceil((a / f.output.amount)) * f.inputs[0].amount);
            ore += Math.ceil((Math.ceil(a) / f.output.amount)) * f.inputs[0].amount;
        }

        return ore;
    }
}

class FormulaPart
{
    public var amount:Int;
    public var compound:String;

    public function new(Amount:Int, Compound:String):Void
    {
        amount = Amount;
        compound = Compound;
    }
}

class Formula
{
    public var inputs:Array<FormulaPart>;
    public var output:FormulaPart;

    public function new(Inputs:Array<FormulaPart>, Output:FormulaPart):Void
    {
        inputs = Inputs.copy();
        output = Output;
    }
}
