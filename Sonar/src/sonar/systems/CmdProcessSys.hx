package sonar.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import sonar.commands.Command;
import sonar.components.CmdQueue;

class CmdProcessSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [CmdQueue] ) );
    }
    
    override public function initialize() : Void {
        queueMapper = world.getMapper( CmdQueue );
    }
    
    override public function processEntities( entities : Bag<Entity> ) : Void {
        var e : Entity;
        var cq : CmdQueue;
        var cmd : Command;
        
        for ( i in 0...entities.size ) {
            e = entities.get( i );
            cq = queueMapper.get( e );
            cmd = cq.first();
            
            if ( cmd == null ) {
                continue;
            }
            
            switch ( cmd.state ) {
                case TCmdRes.NEW:
                    cmd.state = TCmdRes.PENDING;
                    cmd.onStart();
                    cmd.Execute();
                case TCmdRes.PENDING:
                    cmd.Execute();
                case TCmdRes.PASS:
                    cmd.onFinished();
                    cq.dequeue();
                default:
                    
            }
        }
    }
    
    var queueMapper : ComponentMapper<CmdQueue>;
    
}
