package sonar.components;
import com.artemisx.Component;
import com.artemisx.Entity;

class InventoryCmp implements Component
{
    @:isVar public var holderEntityRef : Entity; //to be used for later; attaches inventory to the character responsible
    public function new() {
    }
}
