package gibber;
import com.artemisx.Entity;
import gibber.components.PosCmp;
import haxe.ds.GenericStack;
import utils.Vec2;

class Util
{
    public static function init( g : God ) {
        god = g;
    }
    
    public static function relativeCoords( e : Entity, anchor : Entity ) : Vec2 {
        var posCmp = e.getComponent( PosCmp );
        var sec = posCmp.regionStack.head;
        var pos = posCmp.pos;
        var hitAnchor = false;
        while ( !hitAnchor ) {
            if ( sec == null ) {
                throw "Invalid anchor for entity";
            }
            pos = pos.add( sec.elt.getComponent( PosCmp ).pos );
            if ( sec.elt == anchor) {
                hitAnchor = true;
            }
            sec = sec.next;
        }
        
        return pos;
    }
    
    public static function localCoords( pos : Vec2, e : Entity, local : Entity, anchor : Entity ) : Vec2 {
        var posCmp = e.getComponent( PosCmp );
        var sec = posCmp.regionStack.head;
        
        while ( sec != null && sec.elt != local ) {
            sec = sec.next;
        }
        
        while ( sec.elt != anchor ) {
            pos = pos.sub( sec.elt.getComponent( PosCmp ).pos );
            sec = sec.next;
            
            if ( sec == null ) {
                throw "Invalid anchor";
            }
        }
        
        return pos;
    }
    
    public static function peek( s : GenericStack<Entity> ) : Entity {
        return s.head.elt;
    }
    
    public static function base( s : GenericStack<Entity> ) : Entity {
        var st = s.head;
        var ret = null;
        
        while ( st != null ) {
            ret = st.elt;
            st = st.next;
        }
        return ret;
    }
    
    public static function clear( s : GenericStack<Entity> ) : Void {
        while ( !s.isEmpty() ) {
            s.pop();
        }
    }
    
    static var god : God;
    
}