/**
 * Adds a string to a given array at a given offset, converted to UTF-8
 * @param {String} string The string to convert to UTF-8
 * @param {Array|Uint8Array} array The array to which to add the string
 * @param {Integer} [offset] Offset at which to add the string
 */
function stringToUTF8Array(string, array, offset) {
	if(!offset) offset = 0;
	var n = string.length;
	for(var i=0; i<n; i++) {
		var val = string.charCodeAt(i);
		if(val >= 128) {
			if(val >= 2048) {
				array[offset] = (val >>> 12) | 224;
				array[offset+1] = ((val >>> 6) & 63) | 128;
				array[offset+2] = (val & 63) | 128;
				offset += 3;
			} else {
				array[offset] = ((val >>> 6) | 192);
				array[offset+1] = (val & 63) | 128;
				offset += 2;
			}
		} else {
			array[offset++] = val;
		}
	}
}

/**
 * Gets the byte length of the UTF-8 representation of a given string
 * @param {String} string
 * @return {Integer}
 */
function getStringByteLength(string) {
	var length = 0, n = string.length;
	for(var i=0; i<n; i++) {
		var val = string.charCodeAt(i);
		if(val >= 128) {
			if(val >= 2048) {
				length += 3;
			} else {
				length += 2;
			}
		} else {
			length += 1;
		}
	}
	return length;
}

// Emscripten file system functions
var cslValidatorInput,
	cslValidatorInputLocation,
	cslValidatorOutput;
var Module = {
	"arguments":["csl.rnc"],
	"stdin":function() {
		if(cslValidatorInputLocation < cslValidatorInput.length) {
			return cslValidatorInput[cslValidatorInputLocation++];
		}
		return null;
	},
	"stdout":function(code) {
		cslValidatorOutput += String.fromCharCode(code);
	},
	"stderr":function(code) {
		cslValidatorOutput += String.fromCharCode(code);
	},
	"noInitialRun":true
};
validate = function(string) {
	cslValidatorInput = new Uint8Array(getStringByteLength(string));
	stringToUTF8Array(string, cslValidatorInput);
	cslValidatorInputLocation = 0;
	cslValidatorOutput = "";
	
	FS.streams[0] = FS.streams[1];
	run();
	return cslValidatorOutput;
}
if (typeof window === 'undefined') {
	onmessage = function(event) {
		postMessage(validate(event.data));
	}
}