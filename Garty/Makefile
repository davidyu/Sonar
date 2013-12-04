.PHONY: preprocess test clean

preprocess:
	./preprocess.sh > resource/classpaths.inc

game: preprocess
	haxe compile.hxml
	fdb bin/Engine.swf

check:
	haxe unit.hxml
	neko testbin/check.n

clean:
	rm resource/*.inc testbin/* bin/*
