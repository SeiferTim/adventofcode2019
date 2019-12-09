package;

class Perm
{
    // 最終的に返すもの（組み合わせのパターン）
    private var patterns:Array<Array<Int>>;
    // 入力数字列
    private var in_ary:Array<Int>;

    /**
     * コンストラクタ
     * @param	in_ary　入力数字列
     */
    public function new(in_ary:Array<Int>)
    {
        this.in_ary = in_ary;
        patterns = [];
    }

    /**
     * 順列を計算して戻す
     * @return 順列の配列
     */
    public function compute():Array<Array<Int>>
    {
        search(in_ary, []);
        return patterns;
    }

    // 深さ優先探索
    private function search(remain:Array<Int>, stack:Array<Int>):Void
    {
        // もうないのでおしまい
        if (remain.length == 0)
        {
            // 非破壊的メソッドがほしいなぁ
            var stack_r = stack.copy();
            stack_r.reverse();
            patterns.push(stack_r);
            return;
        }

        // 子供に対して探索
        for (i in remain)
        {
            var next:Array<Int> = remain.copy();
            next.remove(i);

            var visited = stack.copy();
            visited.unshift(i);
            search(next, visited);
        }
    }
}
