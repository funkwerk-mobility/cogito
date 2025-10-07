.PHONY: clean debug release test install

DC=ldmd2
DUB=dub
DFLAGS=

debug: DFLAGS += -debug
debug: build/githash.txt
	$(DUB) build --build=debug --config=executable

release: build/release/bin/cogito
	sed -e 's#v\(.*\)#build/cogito-\1#' build/githash.txt | \
		xargs -I '{}' rm -rf '{}'
	sed -e 's#v\(.*\)#build/cogito-\1#' build/githash.txt | \
		xargs -I '{}' cp -a build/release '{}'
	cd build && sed -e 's#v\(.*\)#cogito-\1#' githash.txt | xargs -I '{}' zip -r '{}.zip' '{}'

build/release/bin/cogito: DFLAGS += -release
build/release/bin/cogito: build/githash.txt
	$(DUB) build --build=release --config=executable
	mkdir -p build/release/bin
	mv build/cogito build/release/bin

build/githash.txt:
	mkdir -p build
	git describe | tee $@

build/test: src/**/*.d
	$(DUB) build --build=unittest --config=unittest

test: DFLAGS += -debug
test: build/test
	./build/test -s

clean:
	rm -rf build/*
	dub clean
