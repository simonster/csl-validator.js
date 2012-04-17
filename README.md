# csl-validator.js

A CSL validator for JavaScript, based on rnv and emscripten. To use, include
csl-validator.js and call:

```javascript
var output = validate("string");
```

```output``` will be the output of the rnv command-line tool.

To compile:

1. Get emscripten and node.js.
2. Edit the Makefile to set the path to emscripten
3. Run ```make```.