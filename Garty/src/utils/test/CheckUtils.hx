package utils.test;

class CheckUtils
{
    static function main() {
        var runner = new haxe.unit.TestRunner();
        runner.add( new CheckMath2() );
        runner.run();
    }
}
