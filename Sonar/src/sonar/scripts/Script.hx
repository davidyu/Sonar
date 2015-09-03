package sonar.scripts;

enum ExeRes
{
    PASS;
    FAIL;
}

typedef ScriptRunInfo = 
{
    var output : String;
    var res : ExeRes;
}

interface Script
{

}
