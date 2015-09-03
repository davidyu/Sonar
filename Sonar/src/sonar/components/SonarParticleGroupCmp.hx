package sonar.components;
import com.artemisx.Component;
import com.artemisx.Entity;

using sonar.Util;

@:rtti
class SonarParticleGroupCmp implements Component
{
    @:isVar public var members : List<Entity>;

    public function new( ) {
        this.members = new List<Entity>();
    }
}
