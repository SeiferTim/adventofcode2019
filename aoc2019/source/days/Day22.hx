package days;

import flixel.util.FlxSort;
import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import haxe.Int64;
import openfl.Assets;
import flixel.math.FlxMath;

using StringTools;

class Day22 extends Day
{
    override public function start():Void
    {
        // var deck:Array<Int> = [for (i in 0...10007) i]; // deck of 10007
        // var inst:Array<String> = Assets.getText("assets/data/day22.txt").split("\r\n");
        // for (i in inst)
        // {
        //     if (i.startsWith("cut"))
        //     {
        //         deck = cut(deck, Std.parseInt(i.substr(i.lastIndexOf(" "))));
        //     }
        //     else if (i.startsWith("deal with"))
        //     {
        //         deck = dealWithInc(deck, Std.parseInt(i.substr(i.lastIndexOf(" "))));
        //     }
        //     else if (i.startsWith("deal into"))
        //     {
        //         deck = dealIntoNewStack(deck);
        //     }
        // }

        // PlayState.addOutput("Position of Card 2019: " + deck.indexOf(2019));

        // part 2 COULD work with enough time, but, apparently, they want you to use MATH. AGAIN.

        trace(modularPower(2, 5, 13));

        var numCards:Int64 = Int64.fromFloat(119315717514047);
        var numShuffles:Int64 = Int64.fromFloat(101741582076661);
        var finalPos:Int64 = 2020;

        var a:Int64 = 0;
        var b:Int64 = 0;
        var A:Int64 = 1;
        var B:Int64 = 0;
        var arg:Int64 = 0;

        var inst:Array<String> = Assets.getText("assets/data/day22.txt").split("\r\n");
        for (i in inst)
        {
            if (i.startsWith("cut"))
            {
                arg = Int64.ofInt(Std.parseInt(i.substr(i.lastIndexOf(" "))));
                if (arg < 0)
                    arg += numCards;
                a = 1;
                b = numCards - arg;
            }
            else if (i.startsWith("deal with"))
            {
                a = Std.parseInt(i.substr(i.lastIndexOf(" ")));
                b = 0;
            }
            else if (i.startsWith("deal into"))
            {
                a = -1;
                b = numCards - 1;
            }

            A = (a * A) % numCards;
            B = (a * B + b) % numCards;
        }

        var fullA:Int64 = Int64.fromFloat(7105969895355); // modularPower(A, numShuffles, numCards); // 7105969895355
        var fullB:Int64 = (B * modularDivide(fullA - 1, A - 1, numCards)) % numCards;

        trace(A, B, fullA, fullB);

        var startPos:Int64 = (modularDivide((finalPos - fullB) % numCards, fullA, numCards)) % numCards;

        PlayState.addOutput('The card at index $finalPos after $numShuffles shuffles is: $startPos');
    }

    private function mod(a:Int64, b:Int64):Int64
    {
        return (a >= 0) ? a % b : b + a % b;
    }

    private function gcdExtended(a:Int64, b:Int64, x:Int64, y:Int64):Array<Int64>
    {
        if (a == 0)
        {
            x = 0;
            y = 1;
            return [b, x, y];
        }
        var gxy:Array<Int64> = gcdExtended(b % a, a, 0, 0);
        x = gxy[2] - (b / a) * gxy[1];
        y = gxy[1];
        return [gxy[0], x, y];
    }

    private function modularInverse(b:Int64, n:Int64):Int64
    {
        var gxy:Array<Int64> = gcdExtended(b, n, 0, 0);
        if (gxy[0] != 1)
            return 0;
        else
        {
            var res:Int64 = (gxy[1] % n + n) % n;
            return res;
        }
    }

    private function modularDivide(a:Int64, b:Int64, n:Int64):Int64
    {
        a %= n;
        var inv = modularInverse(b, n);
        return inv == -1 ? 0 : (a * inv) % n;
    }

    private function modularPower(base:Int64, exponent:Int64, n:Int64):Int64
    {
        trace(base, exponent, n);
        var res:Int64 = 1;
        base = base % n;
        while (exponent > 0)
        {
            if ((exponent & 1) == 1)
            {
                res = (res * base) % n;
            }
            exponent = exponent >> 1;
            base = (base * base) % n;
        }

        trace(res);
        return res;
    }
}

class Deck extends StringMap<Int64>
{
    public var length(get, null):Int64;

    private function get_length():Int64
    {
        var l:Int64 = 0;
        for (k in keys())
            l++;
        return l;
    }

    public function dealIntoNewStack():Void
    {
        var oldDeck:Deck = copy();

        var m:Int64 = 0;
        var maxLength:Int64 = length;
        while (m < maxLength)
        {
            this.set(Int64.toStr(maxLength - m - 1), oldDeck.get(Int64.toStr(m)));
            m++;
        }
    }

    override public function copy():Deck
    {
        var newDeck:Deck = new Deck();
        for (k in keys())
            newDeck.set(k, get(k));

        return newDeck;
    }

    public function cut(Amount:Int64):Void
    {
        var oldDeck:Deck = copy();
        var oldPos:Int64;
        var newPos:Int64;
        var oldLength:Int64 = oldDeck.length;
        var offset:Int64 = Amount < 0 ? oldDeck.length + Amount : Amount;

        oldPos = offset;
        newPos = 0;

        do
        {
            set(Int64.toStr(newPos), oldDeck.get(Int64.toStr(oldPos)));
            oldLength = oldDeck.length;
            oldPos++;

            if (oldPos > oldLength - 1)
            {
                oldPos = 0;
            }
            if (oldPos >= offset)
                newPos = oldPos - offset;
            else
                newPos = oldLength - (offset - oldPos);
        }
        while (oldPos != offset);
    }

    public function dealWithInc(Inc:Int64):Void
    {
        var oldDeck:Deck = copy();
        var oldPos:Int64 = 0;
        var newPos:Int64 = 0;
        while (oldPos < oldDeck.length)
        {
            set(Int64.toStr(newPos), oldDeck.get(Int64.toStr(oldPos)));
            oldPos++;
            newPos += Inc;
            while (newPos >= oldDeck.length)
                newPos -= oldDeck.length;
        }
    }

    override public function toString():String
    {
        var s = new StringBuf();
        s.add("{");
        var it = [for (k in keys()) k];
        it.sort(function(A, B) return FlxSort.byValues(FlxSort.ASCENDING, Std.parseFloat(A), Std.parseFloat(B)));
        var itt = it.iterator();
        for (i in itt)
        {
            s.add(Std.string(i));
            s.add(" => ");
            s.add(Std.string(get(i)));
            if (itt.hasNext())
                s.add(", ");
        }
        s.add("}");
        return s.toString();
    }

    public function getKeyOf(Value:Int64):String
    {
        for (k => v in this)
            if (v == Value)
                return k;
        return null;
    }
}
