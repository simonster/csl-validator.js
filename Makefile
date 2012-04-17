TOP := $(dir $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))
EMSCRIPTEN := /Users/simon/Desktop/Development/FS/emscripten
EXPAT := deps/expat-2.1.0
RNV := deps/rnv-1.7.10
SCHEMA := deps/schema

all: test

clean:
	rm -f csl-validator.js
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

csl-validator.js: $(RNV)/Makefile
	cd $(RNV); "$(EMSCRIPTEN)/emmake" make
	"$(EMSCRIPTEN)/emcc" -O2 -o csl-validator.js \
		$(RNV)/rnv-xcl.o $(RNV)/librnv1.a $(RNV)/librnv2.a $(EXPAT)/.libs/libexpat.a \
		--embed-file $(SCHEMA)/csl-categories.rnc \
		--embed-file $(SCHEMA)/csl-data.rnc \
		--embed-file $(SCHEMA)/csl-relaxed.rnc \
		--embed-file $(SCHEMA)/csl-terms.rnc \
		--embed-file $(SCHEMA)/csl-types.rnc \
		--embed-file $(SCHEMA)/csl-variables.rnc \
		--embed-file $(SCHEMA)/csl.rnc \
		--pre-js pre.js

test: csl-validator.js
	node test.js