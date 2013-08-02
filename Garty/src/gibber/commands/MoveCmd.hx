package gibber.commands;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import gibber.CmdFactory;
import gibber.components.PosCmp;
import gibber.God;
import utils.Vec2;

using gibber.Util;

class MoveCmd implements Command
{
    @:isVar public var dest : Vec2;
    @:isVar public var sector : Entity;
    @:isVar public var e : Entity;
    @:isVar public var state : Command.TCmdRes;

    
    function new( cf : CmdFactory, e : Entity, dest : Vec2, sector : Entity ) {
        this.state = Command.TCmdRes.NEW;
        this.cf = cf;
        this.e = e;
        this.dest = dest;
        this.sector = sector;
        
        this.posMapper = cf.god.world.getMapper( PosCmp );
    }
    
    public function onStart() : Void {
        state = Command.TCmdRes.PENDING;
    }
    
    public function Execute() : Array<Dynamic>  {
        var posCmp = posMapper.get( e );
        var destT = dest.sectorCoords( sector, posCmp.sector );
        var delta = destT.sub( posCmp.pos );
        var scale = delta.lengthsq() > 4 ? 2.0 / delta.length() : 1.0;
        
        posCmp.dp = delta.mul( scale );
        
        if ( delta.lengthsq() < 0.1 ) {
            state = Command.TCmdRes.PASS;
        }
        
        return null;
    }
    
    public function onFinished() : Void {
        
    }
    
    var posMapper : ComponentMapper<PosCmp>;
    var cf : CmdFactory;
}