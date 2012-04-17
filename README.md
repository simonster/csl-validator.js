# csl-validator.js

A CSL validator for JavaScript, based on rnv and emscripten. To use, include
csl-validator.js and call:

```javascript
var output = validate("string");
```

```output``` will be the output of the rnv command-line tool.

To compile:

1. Get emscripten and node.js
2. ```git clone --recursive git://github.com/simonster/csl-validator.js.git```
3. Edit the Makefile to set the path to emscripten
4. ```make```