package ;

import sys.net.Host;
import sys.net.Socket;

class ServerMain 
{
    static function main()
    {
        // entry point
        var server = new Socket();
        server.bind( new Host( "localhost" ), 5000 );
        server.listen( 1 );
        trace( "Starting server" );
        while( true ) {
            var conn : Socket = server.accept(); //blocking
            trace( "Client connected" );
            conn.write( "hello\n" );
            conn.write( "your IP is " + conn.peer().host.toString() + "\n" );
            var stdin = Sys.stdin();
            var input = stdin.readLine();
            while ( input != "exit"  ) {
                conn.write( input + "\n" );
                input = stdin.readLine();
            }
            trace( "Client connection closed." );
            conn.close();
        }
    }
}
