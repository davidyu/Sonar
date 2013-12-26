import utils.test.CheckMath2;

import gibber.systems.test.CheckSonarSys;

class Check
{
    static function main() {
        var runner = new haxe.unit.TestRunner();

        // utils
        runner.add( new CheckMath2() );

        // systems
        runner.add( new CheckSonarSys() );
        runner.run();
    }
}