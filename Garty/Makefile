.PHONY: preprocess game check clean

preprocess:
	./preprocess.sh > resource/classpaths.inc

fdb: preprocess
	haxe debug.hxml
	fdb bin/Engine_debug.swf

local: preprocess
	haxe local.hxml
	open bin/Engine_local.swf

game: preprocess
	haxe compile.hxml
	cp bin/Engine.swf ../relay/

check:
	haxe unit.hxml
	open testbin/Check.swf

clean:
	rm resource/*.inc testbin/* bin/*
