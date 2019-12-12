package;

class Functions
{
    public static function lcm(A:Int, B:Int):Int
    {
        var c:Int = gcd(A, B);
        return c == 0 ? 0 : Std.int(A / c * B);
    }

    public static function gcd(A:Int, B:Int):Int
    {
        if (B == 0)
            return A;
        return gcd(B, A % B);
    }

    public static function lcmMulti(N:Array<Int>):Int
    {
        var ans:Int = N[0];

        for (i in 1...N.length)
        {
            ans = Std.int((N[i] * ans) / (gcd(N[i], ans)));
        }

        return ans;
    }

    public static function gcdMulti(N:Array<Int>):Int
    {
        var result = N[0];
        for (i in N)
        {
            result = gcd(i, result);
            if (result == 1)
                return 1;
        }
        return result;
    }
}
