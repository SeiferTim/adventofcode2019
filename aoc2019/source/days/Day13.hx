package days;

import flixel.util.FlxGradient;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import haxe.Int64;
import openfl.Assets;
import intcode.Computer;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Day13 extends Day
{
    private var game:Computer;

    override public function start():Void
    {
        game = new Computer(Assets.getText("assets/data/day13.txt"));

        game.start();
        // var data:Array<Triplicate> = [];
        var i:Int = 0;
        var highestX:Int = 0;
        var highestY:Int = 0;
        var countBlocks:Int = 0;
        while (i < game.outputs.length)
        {
            // data.push(new Triplicate(Int64.toInt(game.outputs[i]), Int64.toInt(game.outputs[i + 1]), Int64.toInt(game.outputs[i + 2])));
            if (game.outputs[i + 2] == 2)
                countBlocks++;
            if (Int64.toInt(game.outputs[i]) > highestX)
                highestX = Int64.toInt(game.outputs[i]);
            if (Int64.toInt(game.outputs[i + 1]) > highestY)
                highestY = Int64.toInt(game.outputs[i + 1]);
            i += 3;
        }
        highestX++;
        highestY++;

        PlayState.addOutput("Day 13 Answer: " + countBlocks);

        FlxG.state.openSubState(new ShowState(Assets.getText("assets/data/day13.txt"), highestX, highestY));
    }
}

class ShowState extends FlxSubState
{
    private var score:FlxText;
    
    private var map:FlxSprite;
    private var game:Computer;
    private var closeButton:FlxSpriteButton;

    private var back:FlxSprite;
    private var w:Int;
    private var h:Int;
    private var stop:Bool = false;
    private var throttle:Float = 0;
    private var ballX:Int = -1;
    private var paddleX:Int = -1;
    private var blocksLeft:Int = -1;

    private var wallColors:Array<FlxColor> = [FlxColor.GREEN, FlxColor.LIME];
    private var ballColors:Array<FlxColor> = [FlxColor.WHITE, FlxColor.YELLOW];
    private var paddleColors:Array<FlxColor> = [FlxColor.CYAN, FlxColor.BLUE];

    private var blocksColors:Array<FlxColor>;

    public function new(Program:String, Width:Int, Height:Int)
    {
        super();

        blocksColors = FlxGradient.createGradientArray(1,16,[FlxColor.RED, FlxColor.YELLOW, FlxColor.GREEN, FlxColor.CYAN,FlxColor.BLUE, FlxColor.MAGENTA],1,90);

        game = new Computer(Program);
        map = new FlxSprite();
        map.makeGraphic(Width, Height, FlxColor.BLACK);
        w = Width;
        h = Height;
    }

    override public function create():Void
    {
        back = new FlxSprite();
        back.makeGraphic(Std.int((map.width * 16) + 2), Std.int((map.height * 16) + 2), FlxColor.WHITE);
        back.screenCenter(FlxAxes.XY);

        map.scale.set(16, 16);
        map.origin.set(0, 0);
        map.x = (back.x + 1);
        map.y = (back.y + 1);

        closeButton = new FlxSpriteButton(0, 0, null, close);
        closeButton.loadGraphic("assets/images/close.png");
        closeButton.x = back.x + back.width;
        closeButton.y = back.y - closeButton.height;

        score = new FlxText();
        score.text = "0";
        score.screenCenter(FlxAxes.X);
        score.y = back.y  - score.height - 2;

        add(back);
        add(map);
        add(closeButton);
        add(score);

        game.setValue(0, 2);
        game.start();

        drawScreen();

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!stop)
        {
            //throttle += elapsed;
            //if (throttle >= .001)
            //{
            //   throttle -= .001;
            if (game.state == Computer.STATE_WAITING)
            {
                drawScreen();
                if (blocksLeft > 0)
                {
                    var dir:Int = 0;
                    if (ballX < paddleX)
                        dir = -1;
                    else if (ballX > paddleX)
                        dir = 1;
                    game.start([dir]); // joystick direction
                }
                else
                    stop = true;
            }
            else if (game.state == Computer.STATE_FINISHED)
            {
                drawScreen();
                stop = true;
            }
        //}
        }
    }

    private function drawScreen():Void
    {
        map.pixels.lock();
        //clearScreen();

        var p:Int = 0;
        blocksLeft = 0;
        while (p < game.outputs.length)
        {
            if (game.outputs[p] == -1 && game.outputs[p + 1] == 0)
            {
                score.text = Std.string(game.outputs[p + 2]);
                score.screenCenter(FlxAxes.X);
            }
            else
            {
                // map.setTile(Int64.toInt(game.outputs[p]), Int64.toInt(game.outputs[p + 1]), Int64.toInt(game.outputs[p + 2]));
                map.pixels.setPixel(Int64.toInt(game.outputs[p]), Int64.toInt(game.outputs[p + 1]),
                    getPixelColor(Int64.toInt(game.outputs[p + 1]), Int64.toInt(game.outputs[p + 2])));
                if (game.outputs[p + 2] == 4)
                    ballX = Int64.toInt(game.outputs[p]);
                else if (game.outputs[p + 2] == 3)
                    paddleX = Int64.toInt(game.outputs[p]);
                else if (game.outputs[p + 2] == 2)
                    blocksLeft++;
            }
            p += 3;
        }
        map.pixels.unlock();
        map.dirty = true;
    }

    private function getPixelColor(Y:Int, Type:Int):Int
    {
        var c:Int = FlxColor.BLACK;
        switch (Type)
        {
            case 0: // Back
                c = FlxColor.BLACK;
            case 1: // Wall
                c =  wallColors[Std.int((FlxG.game.ticks / 200) % wallColors.length)];
            case 2: // Block
                c = blocksColors[Y-2];
            case 3: // Paddle
                c =  paddleColors[Std.int((FlxG.game.ticks / 200) % paddleColors.length)];
            case 4: // Ball
                c =  ballColors[Std.int((FlxG.game.ticks / 200) % ballColors.length)];
            default:
                c = FlxColor.BLACK;
        }
        return c;
    }

    private function clearScreen():Void
    {
        map.pixels.fillRect(map.pixels.rect, FlxColor.BLACK);
    }
}
