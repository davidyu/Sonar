.PHONY: preprocess game check clean

preprocess:
	./preprocess.sh > resource/classpaths.inc

fdb: preprocess
	haxe debug.hxml
	fdb bin/Engine_debug.swf

game: preprocess
	haxe compile.hxml
	open bin/Engine.swf

check:
	haxe unit.hxml
	open testbin/Check.swf

clean:
	rm resource/*.inc testbin/* bin/*
