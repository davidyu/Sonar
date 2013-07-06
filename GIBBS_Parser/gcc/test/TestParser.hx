package gcc.test;

class TestParser extends haxe.unit.TestCase {
    //warning: this test is for FLASH TARGET ONLY
    static var input:flash.text.TextField;
    static var output:flash.text.TextField;

    public function testLexer() {


    }

    public function testPipeline() {

    }

    static function main() {

        //set up dynamic text field - not usable.
        input = new flash.text.TextField();
        output = new flash.text.TextField();
        input.width = 600;
        input.height = 40;
        input.x = 20;
        input.y = 400;
        output.width = 600;
        output.height = 300;
        output.x = 20;
        output.y = 20;
        var format = new flash.text.TextFormat("Arial", 12, 0x000000);
        input.defaultTextFormat = format;
        input.text = "Hello World!";
        input.selectable = true;
        input.type = flash.text.TextFieldType.INPUT;
        flash.Lib.current.addChild(input);
        output.defaultTextFormat = format;
        output.text = "~";
        flash.Lib.current.addChild(output);

        testParse("");
    }

    static function testParse(input:String) {
    
    }
}
