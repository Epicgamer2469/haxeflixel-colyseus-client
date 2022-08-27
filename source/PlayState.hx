package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import io.colyseus.Client;
import io.colyseus.Room;
import schema.State;

class PlayState extends FlxState
{
	var client:Client;
	var room:Room<State>;
	var sprites:Map<String, FlxSprite> = new Map();
	var clientPlayer:FlxSprite;

	override public function create()
	{
		super.create();

		FlxG.autoPause = false;

		client = new Client("ws://localhost:2567");
		// client = new Client("wss://server.herokuapp.com");

		client.joinOrCreate("my_room", [], State, function(err, servRoom)
		{
			if (err != null)
			{
				trace("ERROR! " + err);
				return;
			}

			room = servRoom;
			room.state.players.onAdd = function(player, key)
			{
				// Dont add duplicate sprites
				if (sprites.exists(key))
					return;

				trace('PLAYER ADDED AT: $key');
				var spr = new FlxSprite().makeGraphic(16, 16);
				sprites[key] = spr;
				spr.x = player.x;
				spr.y = player.y;
				add(spr);

				// Set the 'client player' for smoother movement on the player's client side
				if (clientPlayer == null && key == room.sessionId)
				{
					clientPlayer = spr;
				}
			}

			room.state.players.onRemove = function(player, key)
			{
				trace('PLAYER REMOVED AT: $key');
				remove(sprites[key]);
			}

			room.onMessage("move", function(message)
			{
				sprites[message.key].x = message.x;
				sprites[message.key].y = message.y;
			});

			room.onError += function(code:Int, message:String)
			{
				trace("ROOM ERROR: " + code + " => " + message);
			};

			room.onLeave += function()
			{
				trace("ROOM LEAVE");
			}
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.pressed.UP)
		{
			room.send("move", {y: -1});
			clientPlayer.y -= 1;
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			room.send("move", {y: 1});
			clientPlayer.y += 1;
		}
		else if (FlxG.keys.pressed.LEFT)
		{
			room.send("move", {x: -1});
			clientPlayer.x -= 1;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			room.send("move", {x: 1});
			clientPlayer.x += 1;
		}
	}
}
