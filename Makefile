EMSCRIPTEN := /Users/simon/Desktop/Development/FS/emscripten
EXPAT := deps/expat-2.1.0
RNV := deps/rnv-1.7.10
SCHEMA := deps/schema
TOP := $(dir $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))

all: test

clean:
	rm -f csl-validator.js csl-validator.tmp.js
	cd $(EXPAT); make clean
	cd $(RNV); make clean
	rm $(EXPAT)/Makefile
	rm $(RNV)/Makefile

$(EXPAT)/Makefile: $(EXPAT)/configure
	cd $(EXPAT); "$(EMSCRIPTEN)/emconfigure" ./configure

$(EXPAT)/libexpat.la: $(EXPAT)/Makefile
	cd $(EXPAT); "$(EMSCRIPTEN)/emmake" make

$(RNV)/Makefile: $(EXPAT)/libexpat.la
	export CPPFLAGS='-L$(TOP)$(EXPAT) -I$(TOP)$(EXPAT)/lib'; cd $(RNV); \
		"$(EMSCRIPTEN)/emconfigure" ./configure

csl-validator.tmp.js: $(RNV)/Makefile pre.js deps/schema/csl.rnc
	cd $(RNV); "$(EMSCRIPTEN)/emmake" make
	cd $(SCHEMA); "$(EMSCRIPTEN)/emcc" -Os \
		-o "$(TOP)csl-validator.tmp.js" \
		"$(TOP)$(RNV)/rnv-xcl.o" \
		"$(TOP)$(RNV)/librnv1.a" \
		"$(TOP)$(RNV)/librnv2.a" \
		"$(TOP)$(EXPAT)/.libs/libexpat.a" \
		--embed-file csl-categories.rnc \
		--embed-file csl-data.rnc \
		--embed-file csl-terms.rnc \
		--embed-file csl-types.rnc \
		--embed-file csl-variables.rnc \
		--embed-file csl.rnc \
		--pre-js "$(TOP)/pre.js" \
		--closure 1

csl-validator.js: csl-validator.tmp.js
	printf '/*\n' > csl-validator.js
	cat $(RNV)/COPYING >> csl-validator.js
	printf '\n' >> csl-validator.js
	cat $(EXPAT)/COPYING >> csl-validator.js
	printf '*/\n' >> csl-validator.js
	cat csl-validator.tmp.js >> csl-validator.js

test: csl-validator.js
	node test.js