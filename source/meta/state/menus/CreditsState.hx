package meta.state.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
class CreditsState extends MusicBeatState
{
	private var descriptionos:Array<String> = [
		"Art/Animation/Music/Chart",
		"Coder/Artist/composer of yerr",
		"Music/Chart",
		"Vocalist",
		"No Groovin Creator",
		"BG Artist/Promo Artist",
		"Vocals for Encore",
		"Old Charter",
		"Icon Artist",
		"Created Finisher V-Mix, Creator of Voltz",
		"Created Tossler Sprites"
	];
	var creditsLinks:Array<String> = [
		"https://twitter.com/Sapph808",
		"https://twitter.com/STRT23",
		"https://twitter.com/ihave0lifelol1",
		"https://www.youtube.com/channel/UCi4tiqWYqlhxRsxCvS9H_vw",
		"https://www.youtube.com/channel/UCfppDdv-6zTr6afOYAJgExA",
		"https://www.youtube.com/channel/UCekuN8pNWtqxAeDIR-CMM9A",
		"https://www.youtube.com/channel/UCt8OydjfzD8uNgAxxMnAm1w",
		"https://www.youtube.com/channel/UCgbqBg78VNZBkhw2rj-_MRQ",
		"https://twitter.com/Dumbdotjpg",
		"https://twitter.com/MlNlONRED",
		"https://www.youtube.com/c/Tossler"
	];
	var bg:FlxSprite;
	var creditsppl:FlxSprite;
	var creditstxt:FlxSprite;
	var TextBox:FlxText = new FlxText(0, 675, 0, "", 24);
	var curSelected:Int = -1;

    override function create()     
    {
		//FlxG.sound.playMusic(Paths.music('Teamwork'), 0);

		FlxG.sound.music.fadeIn(4, 0, 0.7);
		#if desktop
		// Updating Discord Rich Presence
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/credits/BG'));
		add(bg);
		bg.screenCenter();

		// as sapph once said in finisher, "shut your fuckin' mouth"
		creditsppl = new FlxSprite(150, -225);
		creditsppl.scale.set(0.5, 0.5);
		creditsppl.frames = Paths.getSparrowAtlas('menus/base/credits/creditppl');
		creditsppl.animation.addByPrefix('characters', 'everyone', 0);
		add(creditsppl);
		creditstxt = new FlxSprite(-150, -220);
		creditstxt.scale.set(0.5, 0.5);
		creditstxt.frames = Paths.getSparrowAtlas('menus/base/credits/credittxt');
		creditstxt.animation.addByPrefix('Text', 'name', 0);
		add(creditstxt);
		var divider:FlxSprite = new FlxSprite(500, 0).loadGraphic(Paths.image('menus/base/credits/divider'));
		add(divider);
		var BT:FlxSprite = new FlxSprite(0, -50).makeGraphic(1280, 100, FlxColor.BLACK);
		add(BT);
		var BB:FlxSprite = new FlxSprite(0, 660).makeGraphic(1280, 100, FlxColor.BLACK);
		add(BB);
		TextBox.alignment = CENTER;
		TextBox.fieldWidth = 2500;
		TextBox.wordWrap = false;
		TextBox.autoSize = false;
		TextBox.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		TextBox.screenCenter(X);
		add(TextBox);
    }
	var quitting:Bool = false;
	var holdTime:Float = 0;
    override function update(elapsed:Float) 
    {
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting)
		{
			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftMult = 3;

			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;

			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}

			if (controls.ACCEPT)
			{
				CoolUtil.browserLoad(creditsLinks[curSelected]);
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				//FlxG.sound.music.fadeOut(1, 0);
				Main.switchState(this, new MainMenuState());
				quitting = true;
			}
		}
    }
	var twn:FlxTween;
	var twn2:FlxTween;

	// var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;
		if (curSelected < 0)
			curSelected = 11;
		if (curSelected >= 12)
			curSelected = 0;

		if (curSelected == 11)
		{
			creditsppl.alpha = 0;
			TextBox.text = "OG Psych credits ft. more helpers";
			creditstxt.animation.play('Text', false, false, curSelected);
		}
		else
		{
			creditsppl.alpha = 1;
			creditsppl.animation.play('characters', false, false, curSelected);
			creditstxt.animation.play('Text', false, false, curSelected);
			TextBox.text = descriptionos[curSelected];
		}
		creditsppl.y = creditsppl.y + 25;
		if (twn != null)
			twn.cancel();
		twn = FlxTween.tween(creditsppl, {y: creditsppl.y - 25}, 0.1);
		TextBox.y = TextBox.y + 25;
		if (twn2 != null)
			twn2.cancel();
		twn2 = FlxTween.tween(TextBox, {y: TextBox.y - 25}, 0.1);
		trace(curSelected);
		/*var newColor:Int =  getCurrentBGColor();
			if(newColor != intendedColor) {
				if(colorTween != null) {
					colorTween.cancel();
				}
				intendedColor = newColor;
				colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
				});
			}

			var bullShit:Int = 0;

			for (item in grpOptions.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				if(!unselectableCheck(bullShit-1)) {
					item.alpha = 0.6;
					if (item.targetY == 0) {
						item.alpha = 1;
					}
				}
			}

			descText.text = creditsStuff[curSelected][2];
			descText.y = FlxG.height - descText.height + offsetThing - 60;

			if(moveTween != null) moveTween.cancel();
			moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

			descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
			descBox.updateHitbox();
		 */
	}
}