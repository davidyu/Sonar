net = require( 'net' );

var clients = [];

var socket = net.createServer( function ( socket ) {
  socket.name = socket.remoteAddress + ":" + socket.remotePort;
  clients.push( socket );
  console.log( "connected to client " + socket.name );

  var opcode = new Buffer( [ 255 ] );
  socket.write( opcode );
  socket.write( "hello " + socket.name );
  relay( socket.name + " joined the game." );

  socket.on( 'data', function( data ) {
    opcode = new Buffer( [ 100 ] );
    relay( socket.name + ">" + data, socket );
  } );

  function relay( data, sender ) {
    clients.forEach( function( client ) {
      if ( client == sender ) return;
      client.write( data );
    } );
  }
} ).listen( 5000 );
