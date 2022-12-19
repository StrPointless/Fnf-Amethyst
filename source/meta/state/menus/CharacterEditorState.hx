package meta.state.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.state.charting.*;
import meta.state.menus.*;
import meta.subState.*;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class CharacterEditorState extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Float = 0;

	var bg:FlxBackdrop; // the background has been separated for more control
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var TextBox:FlxInputText;

	//var optionShit:Array<String> = ['story_mode', 'freeplay','credits','options'];
	var canSnap:Array<Float> = [];

	var testSprite:Character;
    var animsList:FlxText;
	var camEditor:FlxCamera;
	var camHUD:FlxCamera;
    var bgItems:FlxTypedGroup<FlxSprite>;
    var singTest:Bool;
    var curCharacter:String = 'dad';
    var curAnimation:String;
    var curNumber:Int;
    var testNumber:Int;
	var array:Array<String>;
	var typing:Bool;
	var positioning:Bool = false;
	var ghostAlive = false;
	var ghostLayer:FlxTypedGroup<Character>;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var ghost:Character;

	// the create 'state'
	override function create()
	{
		FlxG.mouse.visible = true;
		super.create();

        camEditor = new FlxCamera();
        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camEditor, camHUD];

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if DISCORD_RPC
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		bgItems = new FlxTypedGroup<FlxSprite>();
		// background
		bg = new FlxBackdrop(Paths.image('menus/base/menuBG'), 1, 1, true, false);
		//bg.loadGraphic(Paths.image('menus/base/menuBG'));
		bg.x = -85;
		bg.scrollFactor.set(0,0.1);
		bg.setGraphicSize(Std.int(bg.width * 2.1));
		bg.updateHitbox();
		bg.cameras = [camEditor];
		bg.screenCenter(Y);
		bg.antialiasing = true;
		bgItems.add(bg);
		magenta = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		magenta.scrollFactor.set(0,0.1);
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
        magenta.cameras = [camEditor];
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		bgItems.add(magenta);
        add(bgItems);
        

		// add the camera
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		// create the menu items themselves
		//var tex = Paths.getSparrowAtlas('menus/base/title/buttons/menu_');
		var scale:Float = 0.75;

		// loop through the menu options

		// set the camera to actually follow the camera object that was created before
		var camLerp = Main.framerateAdjust(0.10);
		camEditor.follow(camFollow, null, camLerp);

		//updateSelection();

		// from the base game lol

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Forever Engine Legacy v" + Main.gameVersion, 12);
		versionShit.scrollFactor.set();
        versionShit.cameras = [camHUD];
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		//Cool Shit
		ghostLayer = new FlxTypedGroup<Character>();
		add(ghostLayer);

        testSprite = new Character().setCharacter(-100,400,'dad');
        //testSprite.screenCenter();
        testSprite.debugMode = true;
        testSprite.scrollFactor.set(0.9,0.9);
        testSprite.cameras = [camEditor];
        add(testSprite);
		var uiBlock2:FlxSprite = new FlxSprite(-195, 0).makeGraphic(505, 305, FlxColor.BLACK);
		uiBlock2.cameras = [camHUD];
		uiBlock2.screenCenter(Y);
		add(uiBlock2);


		var uiBlock:FlxSprite = new FlxSprite(-200, 0).makeGraphic(500, 300, FlxColor.GRAY);
		uiBlock.cameras = [camHUD];
		uiBlock.screenCenter(Y);
		add(uiBlock);
        //coolShit

        animsList = new FlxText(0,300,0,"Anims",22);
        //animsList.screenCenter(Y);
        animsList.cameras = [camHUD];
        add(animsList);
        //FlxG.camera.zoom = 0.8;
        changeAnimation(0);
        FlxTween.tween(camEditor,{zoom:0.85},1,{ease: FlxEase.quadInOut, startDelay: 0.25});
		array = testSprite.animation.getNameList();
		trace(array);
		TextBox = new FlxInputText(0, 50, 450, "dad", 24);
		TextBox.scrollFactor.set(0,0);
		TextBox.screenCenter(X);
		TextBox.alignment = CENTER;
		TextBox.cameras = [camEditor];
		add(TextBox);
		addGhost();
		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
	}

	// var colorTest:Float = 0;
	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;
	var multiplier:Int = 1;
	override function update(elapsed:Float)
	{
		typing = TextBox.hasFocus;
       // camFollow.setPosition(testSprite.x,testSprite.y);
        FlxG.watch.addQuick('singMode',singTest);
		FlxG.watch.addQuick('testNNumb', testNumber);
		FlxG.watch.addQuick('posi-', positioning);
		//FlxG.watch.addQuick('DumbTexts', dumbTexts.members);
        if(FlxG.keys.justPressed.SPACE)
            singTest = !singTest;
		if(FlxG.keys.justPressed.FIVE)
			positioning = !positioning;
		if(FlxG.keys.justPressed.SIX)
			changeCharacter(TextBox.text);
		if(FlxG.keys.justPressed.FOUR)
			saveOffsets();
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);
        if(FlxG.keys.pressed.Q)
            FlxG.camera.zoom -= 0.1 * elapsed;
		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += 0.1 * elapsed;
		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if ((controlArray.contains(true)) && (!selectedSomethin))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up is 2 and down is 3
						// paaaaaiiiiiiinnnnn
						if (i == 2)
							curSelected--;
						else if (i == 3)
							curSelected++;

						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					/* idk something about it isn't working yet I'll rewrite it later
						else
						{
							// paaaaaaaiiiiiiiinnnn
							var curDir:Int = 0;
							if (i == 0)
								curDir = -1;
							else if (i == 1)
								curDir = 1;

							if (counterControl < 2)
								counterControl += 0.05;

							if (counterControl >= 1)
							{
								curSelected += (curDir * (counterControl / 24));
								if (curSelected % 1 == 0)
									FlxG.sound.play(Paths.sound('scrollMenu'));
							}
					}*/

					//if (curSelected < 0)
					//	curSelected = optionShit.length - 1;
					//else if (curSelected >= optionShit.length)
					//	curSelected = 0;
				}
				//
			}
		}
		else
		{
			// reset variables
			counterControl = 0;
		}
        if(FlxG.keys.justPressed.UP && !positioning)
            changeAnimation(1);
        if(FlxG.keys.justPressed.DOWN && !positioning)
            changeAnimation(-1);
        if(singTest && !typing && !positioning)
        {
			if ((controls.LEFT))
				testSprite.playAnim('singLEFT', true);
			if ((controls.RIGHT))
				testSprite.playAnim('singRIGHT', true);
			if ((controls.UP))
				testSprite.playAnim('singUP', true);
			if ((controls.DOWN))
				testSprite.playAnim('singDOWN', true);
        }
        else if(!singTest && !typing && !positioning)
        {
			if (FlxG.keys.pressed.J)
				camFollow.x -= 250 * elapsed;
			if (FlxG.keys.pressed.L)
				camFollow.x += 250 * elapsed;
			if (FlxG.keys.pressed.I)
				camFollow.y -= 250 * elapsed;
			if (FlxG.keys.pressed.K)
				camFollow.y += 250 * elapsed;
        }
		if(positioning)
		{
			if(FlxG.keys.pressed.SHIFT)
				multiplier = 5;
			else
				multiplier = 1;
			if(FlxG.keys.justPressed.LEFT)
				offset(1 * multiplier,0);
			if (FlxG.keys.justPressed.RIGHT)
				offset(-1 * multiplier, 0);
			if (FlxG.keys.justPressed.UP)
				offset(0, 1 * multiplier);
			if (FlxG.keys.justPressed.DOWN)
				offset(0, -1 * multiplier);
		}
		/*if ((controls.ACCEPT) && (!selectedSomethin))
		{
			//
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			//FlxFlicker.flicker(magenta, 0.8, 0.1, false);
			FlxTween.tween(bg, {x: -1000}, 1.25, {ease: FlxEase.backIn});
		}
        */
		if (controls.BACK && !typing)
		{
			Main.switchState(this, new MainMenuState());
			FlxG.mouse.visible = false;
		}
		super.update(elapsed);
	}
    public function changeAnimation(huh:Int)
    {
        curNumber += huh;
        testNumber += huh;
		if(array != null)
		{
        	if(curNumber >= array.length)
            	curNumber = 0;
        	if(curNumber < 0)
            	curNumber = array.length - 1;
			testSprite.playAnim(array[curNumber], true);
			updateTexts();
			genBoyOffsets(false);
			animsList.text = testSprite.animation.curAnim.name + ' : ' + testSprite.animOffsets[array[curNumber]];
		}
    }
	public function changeCharacter(name:String)
	{
		remove(testSprite);
		testSprite = new Character().setCharacter(-100, 400, name);
		// testSprite.screenCenter();
		if(testSprite == null)
			testSprite = new Character().setCharacter(-100, 400, 'bf');
		testSprite.debugMode = true;
		testSprite.scrollFactor.set(0.9, 0.9);
		testSprite.cameras = [camEditor];
		array = testSprite.animation.getNameList();
		trace(array);
		changeAnimation(0);
		add(testSprite);
		addGhost();
	}
	public function addGhost()
	{
		ghost = new Character().setCharacter(-100,400,testSprite.curCharacter);
		ghost.debugMode = true;
		ghost.scrollFactor.set(0.9, 0.9);
		ghost.cameras = [camEditor];
		if (ghostAlive)
			ghostLayer.remove(ghost);
		ghost.alpha = 0.5;
		if(array.contains('danceRight'))
			ghost.playAnim('danceRight');
		else
			ghost.playAnim('idle');
		ghostLayer.add(ghost);
	}
	public function saveOffsets()
	{
		if (OpenFlAssets.exists(Paths.offsetTxt(TextBox.text + 'Offsets')))
		{
			var getShit = "";
			for (i in dumbTexts.members)
			{
				getShit += i.text + "\n";
			}
			//var newArray:String = haxe.Json.stringify(array);
			var thingy = StringTools.replace(getShit, "[", "");
			thingy = StringTools.replace(thingy, "]", "");
			thingy = StringTools.replace(thingy, ": ", " ");
			thingy = StringTools.replace(thingy, ",", " ");
			trace(getShit);
			
			sys.io.File.saveContent(Paths.offsetTxt(TextBox.text + 'Offsets'), thingy);
		}
	}
	public function offset(x:Int, y:Int)
	{
		if(array != null)
			testSprite.offset.set(testSprite.offset.x + x ,testSprite.offset.y + y);
		testSprite.addOffset(array[curNumber],testSprite.offset.x,testSprite.offset.y);
		animsList.text = testSprite.animation.curAnim.name + ' : ' + testSprite.animOffsets[array[curNumber]];
		updateTexts();
		genBoyOffsets(false);
		testSprite.playAnim(animList[curNumber]);
	}
	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in testSprite.animOffsets)
		{
			var text:FlxText = new FlxText(100, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = 0xFF30DFFF;
			text.setBorderStyle(OUTLINE, 0xFF000000, 2, 1);
			text.cameras = [camHUD];
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}
	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}
}
