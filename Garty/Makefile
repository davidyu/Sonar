.PHONY: preprocess game check clean

preprocess:
	./preprocess.sh > resource/classpaths.inc

fdb: game
	fdb bin/Engine.swf

game: preprocess
	haxe compile.hxml

check:
	haxe unit.hxml
	neko testbin/check.n

clean:
	rm resource/*.inc testbin/* bin/*
