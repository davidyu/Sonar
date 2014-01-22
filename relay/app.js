net = require( 'net' );

var clients = [];

var socket = net.createServer( function ( socket ) {
  socket.name = socket.remoteAddress + ":" + socket.remotePort;
  clients.push( socket );
  console.log( "connected to client " + socket.name );

  var clientID = new Buffer( [ 255, clients.length - 1 ] );
  socket.write( clientID );
  var clientJoinMsg = new Buffer( [ 254, clients.length - 1 ] );
  relay( clientJoinMsg, socket );

  socket.on( 'data', function( data ) {
    opcode = new Buffer( [ 100 ] );
    console.log( data );
    //relay( socket.name + ">" + data, socket );
  } );

  socket.on( 'close', function() {

  } );

  function relay( data, sender ) {
    clients.forEach( function( client ) {
      if ( client == sender ) return;
      client.write( data );
    } );
  }
} ).listen( 5000 );
