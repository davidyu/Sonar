package utils.test;

import flash.utils.ByteArray;

class CheckFlashUtils extends haxe.unit.TestCase {
    public function testByteArray() {
        var ba = new ByteArray();
        ba.writeShort( 140 );
        ba.position = 0;
        assertEquals( ba.readUnsignedShort(), 140 );

        ba.clear();

        ba.writeByte( 2 );
        ba.writeShort( 140 );
        ba.position = 0;
        assertEquals( ba.readUnsignedByte(), 2 );
        assertEquals( ba.readUnsignedShort(), 140 );
    }

    public function testByteArrayToStringRoundTrip() {
        var ba = new ByteArray();
        var bb = new ByteArray();

        ba.writeByte( 2 );
        ba.writeShort( 140 );

        bb.writeUTFBytes( ba.toString() );
        bb.position = 0;
        assertEquals( bb.readUnsignedByte(), 2 );
        assertEquals( bb.readUnsignedShort(), 140 );

        bb.clear();
        ba.clear();
    }
}
