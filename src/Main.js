// module Main

exports.ensureDbg = function(){
  if (global.v8debug){
    global.v8debug.Debug.setBreakOnException();
  }
};
