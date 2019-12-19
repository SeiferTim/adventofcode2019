package days;

import haxe.Int64;
import flixel.util.FlxSort;
import flixel.math.FlxMath;
import openfl.Assets;

class Day14 extends Day
{
    // private var ALLOW_DRILL:Bool = true;
    // private var oreCollected:Int64 = 0;
    private var formulas:Map<String, Formula> = [];
    // private var stockpile:Map<String, Int64> = [];
    private var formulasByDepth:Array<Formula> = [];

    private var used:Array<Int64>;
    private var depth:Int = 0;

    override public function start():Void
    {
        buildFormulas();

        var costOfOne:Int64 = costOfFuel(1);

        PlayState.addOutput("Day 14 Answer: 1 FUEL => " + costOfOne + " ORE");

        var amount:Int64 = searchForAmount(Int64.fromFloat(1000000000000), costOfOne);

        PlayState.addOutput("Day 14b Answer: 1000000000000 ORE => " + amount + " FUEL");
    }

    private function searchForAmount(Amount:Int64, CostOfOne:Int64):Int64
    {
        var solution:Int64 = 0;
        var low:Int64 = Amount / CostOfOne;
        var high:Int64 = low * 2;
        var mid:Int64 = 0;
        var cost:Int64 = 0;
        while (low + 1 < high)
        {
            mid = (low + high) / 2;
            cost = costOfFuel(mid);
            if (cost > Amount)
            {
                high = mid;
            }
            else if (cost < Amount)
            {
                low = mid;
            }
            else
            {
                solution = mid;
                return solution;
            }
        }
        var n:Int64 = high;
        if (costOfFuel(n) > Amount)
        {
            --n;
        }
        solution = n;
        return solution;
    }

    private function buildFormulas():Void
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
        formulas.set("ORE", new Formula([], new FormulaPart(1, "ORE"), 9999));

        setDepths("FUEL");
        formulasByDepth = Lambda.array(formulas);
        formulasByDepth.sort(sortByDepth);

        for (i in 0...formulasByDepth.length)
        {
            formulasByDepth[i].depth = i;
            formulas.set(formulasByDepth[i].output.compound, formulasByDepth[i]);
        }
    }

    private function costOfFuel(Amount:Int64):Int64
    {
        used = [for (i in 0...formulasByDepth.length) 0];
        used[0] = Amount;

        var multiple:Int64 = 0;
        var f:Formula;

        for (i in 0...formulasByDepth.length)
        {
            if (used[i] == 0)
                continue;
            multiple = (used[i] + formulasByDepth[i].output.amount - 1) / formulasByDepth[i].output.amount;
            for (ingredient in formulasByDepth[i].inputs)
            {
                f = formulas.get(ingredient.compound);
                used[f.depth] += ingredient.amount * multiple;
            }
        }
        return used.pop();
    }

    private function sortByDepth(A:Formula, B:Formula):Int
    {
        return FlxSort.byValues(FlxSort.ASCENDING, A.depth, B.depth);
    }

    private function setDepths(Compound:String):Void
    {
        var formula:Formula = formulas.get(Compound);

        if (depth > formula.depth)
        {
            formula.depth = depth;
            ++depth;
            formulas.set(Compound, formula);
        }

        for (i in formula.inputs)
        {
            if (i.compound == "ORE")
                continue;

            setDepths(i.compound);
        }
    }
}

class FormulaPart
{
    public var amount:Int64;
    public var compound:String;

    public function new(Amount:Int64, Compound:String):Void
    {
        amount = Amount;
        compound = Compound;
    }
}

class Formula
{
    public var inputs:Array<FormulaPart>;
    public var output:FormulaPart;

    public var depth:Int = -1;

    public function new(Inputs:Array<FormulaPart>, Output:FormulaPart, ?Depth:Int = -1):Void
    {
        inputs = Inputs.copy();
        output = Output;
        depth = Depth;
    }
}
