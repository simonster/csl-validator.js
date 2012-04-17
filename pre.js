var cslValidatorInput = null,
	cslValidatorOutput = "";
var Module = {
	"arguments":["csl.rnc"],
	"stdin":function() {
		if(cslValidatorInput.length > 1) return cslValidatorInput.shift();
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
	cslValidatorInput = Module['intArrayFromString'](string);
	FS.streams[0] = FS.streams[1];
	run();
	return cslValidatorOutput;
}