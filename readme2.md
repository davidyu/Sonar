Go to TODO to see what's left.

Toolchain terminology
=====================

gcc = Gibbs Code Compiler

General Developer Resources
===========================

[From AS3 to Haxe](http://www.grantmathews.com/43): 
Has a good example of algebraic datatypes

VIM Developer tips
==================

* Install vaxe plugin:
** Bundle 'jdonaldson/vaxe'
* Add haxe ctags syntax regex:
<pre><code>    --langdef=haxe
    --langmap=haxe:.hx
    --regex-haxe=/^package[ \t]+([A-Za-z0-9_.]+)/\1/p,package/
    --regex-haxe=/^[ \t]*[(@:macro|private|public|static|override|inline|dynamic)( \t)]*function[ \t]+([A-Za-z0-9_]+)/\1/f,function/
    --regex-haxe=/^[ \t]*([private|public|static|protected|inline][ \t]*)+var[ \t]+([A-Za-z0-9_]+)/\2/v,variable/ 
    --regex-haxe=/^[ \t]*package[ \t]*([A-Za-z0-9_]+)/\1/p,package/
    --regex-haxe=/^[ \t]*(extern[ \t]*|@:native\([^]))*\)[ \t]*)*class[ \t]+([A-Za-z0-9_]+)[ \t]*[^\{}]*/\2/c,class/
    --regex-haxe=/^[ \t]*(extern[ \t]+)?interface[ \t]+([A-Za-z0-9_]+)/\2/i,interface/
    --regex-haxe=/^[ \t]*typedef[ \t]+([A-Za-z0-9_]+)/\1/t,typedef/
    --regex-haxe=/^[ \t]*enum[ \t]+([A-Za-z0-9_]+)/\1/t,typedef/
    --regex-haxe=/^[ \t]*+([A-Za-z0-9_]+)(;|\([^]))*:[^]]*\))/\1/t,enum_field/
</code></pre>
* Crazy how it's just a bunch of complex regex expressions.
* Find a good debugger.

TODO
====
- Optimize to avoid using strings in artemis, Vec2 object pooling