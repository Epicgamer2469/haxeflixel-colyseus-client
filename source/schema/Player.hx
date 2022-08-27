package schema;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Player extends Schema
{
	@:type("number")
	public var x:Dynamic = 0;

	@:type("number")
	public var y:Dynamic = 0;
}
