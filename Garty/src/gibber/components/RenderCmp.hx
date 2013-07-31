package gibber.components;

import com.artemisx.Component;
import flash.display.Sprite;

class RenderCmp implements Component
{
    @:isVar public var sprite : Sprite;
    @:isVar public var colour : Int;
    
    public function new( colour : Int = 0xffffff ) {
        this.colour = colour;
    }
    
    
    
}