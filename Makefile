.PHONY: clean debug release test install

DC=$(realpath ./tools/dmd2/linux/bin64/dmd)
DUB=./tools/dmd2/linux/bin64/dub
DFLAGS=

debug: DFLAGS += -debug
debug: build/githash.txt
debug: dmd.a
	$(DUB) build --build=debug --config=executable

release: DC=ldmd2
release: DUB=dub
release: build/release/bin/cogito
	sed -e 's#v\(.*\)#build/cogito-\1#' build/githash.txt | \
		xargs -I '{}' rm -rf '{}'
	sed -e 's#v\(.*\)#build/cogito-\1#' build/githash.txt | \
		xargs -I '{}' cp -a build/release '{}'
	cd build && sed -e 's#v\(.*\)#cogito-\1#' githash.txt | xargs -I '{}' zip -r '{}.zip' '{}'

build/release/bin/cogito: DFLAGS += -release
build/release/bin/cogito: build/githash.txt
build/release/bin/cogito: dmd.a
build/release/bin/cogito:
	$(DUB) build --build=release --config=executable
	mkdir -p build/release/bin
	mv build/cogito build/release/bin

build/githash.txt:
	mkdir -p build
	git describe | tee $@

build/test: dmd.a
	$(DUB) build --build=unittest --config=unittest

test: DFLAGS += -debug
test: build/test
	./build/test -s

%.a: $(wildcard ./tools/dmd2/src/dmd/dmd/*.d ./tools/dmd2/src/dmd/dmd/*/*.d)
	$(DC) $(DFLAGS) -lib \
		-version=MARS -version=NoMain \
		-J=./include -J=./tools/dmd2/src/dmd/dmd/res \
		-I=./tools/dmd2/src/dmd \
		-od=build -of=$@ $^


install: include/VERSION
	cat include/VERSION | \
		sed -e 's#v\(.*\)#http://downloads.dlang.org/releases/2.x/\1/dmd.\1.linux.tar.xz#' | \
		xargs wget -q -O - | \
		tar -C tools -Jxvf -

clean:
	rm -rf build/*
	dub clean
