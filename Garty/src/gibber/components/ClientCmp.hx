package gibber.components;
import com.artemisx.Component;

import flash.net.Socket;
import flash.events.Event;

class ClientCmp implements Component
{
    @:isVar public var socket : Socket;

    public function new( host: String, port: UInt ) {
        socket = new Socket( host, port );
        socket.addEventListener( Event.CONNECT, function( event: Event) {
            trace( "Connected to server " + host + ":" + port );
        } );
    }
}
