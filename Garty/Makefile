.PHONY: preprocess test clean

preprocess:
	./preprocess.sh > resource/classpaths.inc

game: preprocess
	haxe compile.hxml
	fdb bin/Engine.swf

check:
	haxe unit.hxml
	neko check.n

clean:
	rm resource/*.inc test.n
