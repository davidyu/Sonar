Gibbs
=====

This is the repo for an Entity-System framework that leans on Artemis a bit (Garty). There are two games,
Gibbs (text-based adventure with a top-down map visualizer) and Sonar (2D underwater discovery SHMUP). Both
use Garty.

## State of the repo

The master branch has the Gibbs game code, and the sonar branch has the Sonar game code. Sonar (the game) is branched
from Gibbs, so there are a lot of legacy code and logic specific to Gibbs that should not be in there. See issue 12 for some notes on
the future of these two branches. Right now, they are separate and divergent, and should probably remain that
way. We'll have to git cherry-pick individual commits to the underlying engine that we want to share between
these two.

It may make sense to create a separate branch for Gibbs called gibbs, and cleanup master so it only contains
Garty and generic or useful components and systems.

## VIM Developer tips

* Install vaxe plugin:
  * Bundle 'jdonaldson/vaxe'
* Add haxe ctags syntax regex:
<pre><code>
--langdef=haxe
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
  * run ctags often: `ctags -R *`
