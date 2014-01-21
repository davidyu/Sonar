package ;

import sys.net.Host;
import sys.net.Socket;

class ServerMain 
{
    static function main()
    {
        // entry point
        var server = new Socket();
        server.bind( new Host( "127.0.0.1" ), 5000 );
        server.listen( 1 );
        trace( "Starting server" );
        while( true ) {
            var conn : Socket = server.accept(); //blocking
            trace( "Client connected" );
            conn.write( "hello " + conn.peer().host.toString() + "\n" );
            var opcode = conn.input.readByte();
            while ( opcode != 0  ) {
                switch ( opcode ) {
                    case 1: //movement
                        var up   : Bool = conn.input.readByte() > 0,
                            down : Bool = conn.input.readByte() > 0,
                            left : Bool = conn.input.readByte() > 0,
                            right: Bool = conn.input.readByte() > 0;

                        trace( conn.peer().host.toString() + "   " +
                               ( up    ? "up "   : "" ) +
                               ( down  ? "down " : "" ) +
                               ( left  ? "left " : "" ) +
                               ( right ? "right" : "" ) );
                    default: trace( "unknown opcode: " + opcode );
                }
                opcode = conn.input.readByte();
            }
            trace( "Client connection closed." );
            conn.close();
        }
    }
}
