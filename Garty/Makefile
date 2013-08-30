.PHONY: preprocess test clean

preprocess:
	./preprocess.sh > resource/classpaths.inc

test: preprocess
	haxe compile.hxml
	fdb bin/Engine.swf

clean:
	rm resource/*.inc
