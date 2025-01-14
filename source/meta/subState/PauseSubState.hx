package meta.subState;

import flixel.FlxG;
import meta.data.Song.SwagSong;
import meta.data.Song;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.font.Alphabet;
import meta.state.*;
import meta.state.menus.*;

class PauseSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	public static var PlayStateLastState:Bool = false;
    
	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song','Change Difficulty', 'Options', 'Exit to menu'];
	var Diffs:Array<String> = ['Easy', 'Normal', 'Hard'];
	var curSelected:Int = 0;
	var Diff = PlayState.storyDifficulty;
	var pauseMusic:FlxSound;

	
	public function new(x:Float, y:Float)
	{

		menuItems = menuItemsOG;
		super();
		#if debug
		// trace('pause call');
		#end

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		#if debug
		// trace('pause background');
		#end

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		#if debug
		// trace('pause info');
		#end

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		#if debug
		// trace('change selection');
		#end

		changeSelection();

		#if debug
		// trace('cameras');
		#end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if debug
		// trace('cameras done');
		#end
	}

	override function update(elapsed:Float)
	{
	
		#if debug
		// trace('call event');
		#end

		super.update(elapsed);

		#if debug
		// trace('updated event');
		#end
		var daSelected:String = menuItems[curSelected];
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var back = controls.BACK;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var name:String = PlayState.SONG.song;



			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					Main.switchState(this, new PlayState());
				case "Change Difficulty":
					menuItems = Diffs;
					daSelected = "Easy";
					regenMenu();
				case "Easy":
					PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase() + "-easy", PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = 0;
					Main.switchState(this, new PlayState());	
				case "Normal":
					PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase(), PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = 1;
					Main.switchState(this, new PlayState());	
				case "Hard":
					PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase() + "-hard", PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = 2;
					Main.switchState(this, new PlayState());	
				case "Options":
					PlayState.resetMusic();
					PlayStateLastState = true;
					Main.switchState(this, new OptionsMenuState());
				case "Exit to menu":
					PlayState.resetMusic();

					if (PlayState.isStoryMode)
						Main.switchState(this, new StoryMenuState());
					else
						Main.switchState(this, new FreeplayState());
			}
			if (back)
			{
				switch (daSelected)
				{
					case "Easy", "Normal", "Hard":
						menuItems = menuItemsOG;
						regenMenu();
				}
			}
			/*switch (DescriptTxt) 
			{
                  case "Restart":
					  DescriptTxt = 'Restarts the Song from the beginning';
			}*/
		}
		if (back)
		{
			switch (daSelected)
			{
				case "Easy", "Normal", "Hard":
					menuItems = menuItemsOG;
					daSelected = "Resume";
					regenMenu();
			}
		}



		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		#if debug
		// trace('music volume increased');
		#end

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		#if debug
		// trace('mid selection');
		#end

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		#if debug
		// trace('finished selection');
		#end
		//
	}
	function regenMenu():Void {
    for (i in 0...grpMenuShit.members.length) {
    var obj = grpMenuShit.members[0];
    obj.kill();
    grpMenuShit.remove(obj, true);
    obj.destroy();

	}

	for (i in 0...menuItems.length) {
		var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
		item.isMenuItem = true;
		item.targetY = i;
		grpMenuShit.add(item);
	}
}
}