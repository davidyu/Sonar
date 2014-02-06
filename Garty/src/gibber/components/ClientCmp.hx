package gibber.components;
import com.artemisx.Component;

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

class ClientCmp implements Component
{
    @:isVar public var socket : Socket;
    @:isVar public var host : String;
    @:isVar public var port : UInt;
    @:isVar public var id : UInt;
    @:isVar public var verified : Bool;

    public function new( host: String, port: UInt ) {
        this.host = host;
        this.port = port;
        this.verified = false;
        socket = new Socket( host, port );
        socket.addEventListener( Event.CONNECT, function( event: Event) {
            trace( "Connected to server " + host + ":" + port );
        } );
        socket.addEventListener( Event.CLOSE, function( event: Event ) {
            trace( "Disconnected from server" );
        } );

        // rubbish flash events that pause the FDB if we don't handle them
        socket.addEventListener( IOErrorEvent.IO_ERROR, function( event: Event ) {
            // do nothing -- we don't care! This is normal for games (client disconnect)
        } );
        socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, function( event: Event ) {
            trace( event );
        } );
    }
}
