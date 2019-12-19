package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
    public function new()
    {
        super();
        addChild(new FlxGame(720, 450, PlayState, 2, 240, 240));
    }
}
