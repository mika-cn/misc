;(function(global, undefined){
var Hotkey = function(){
  this.code = function(key){
    return ({
      F1 : 112, '←': 37,
      F2 : 113, '↑': 38,
      F3 : 114, '→': 39,
      F4 : 115, '↓': 40,
      F5 : 116,
      F6 : 117, '*': 106,
      F7 : 118, '+': 107,
      F8 : 119, '-': 109,
      F9 : 120,
      F10: 121,
      F11: 122, esc : 27,
      F12: 123, enter : 13,
    })[key];
  }

  this.actions = {ctrl: {}};
  //desc {:key, :action, :leader}
  this.bind = function(desc){
    if(desc.leader){
      this.actions[desc.leader][this.code(desc.key)] = desc.action;
    }else{
      this.actions[this.code(desc.key)] = desc.action;
    }
    var __hotkey = this;
    return function(){
      //console.log('unbind: '+desc.key)
      __hotkey.bind(
        {
          key: desc.key,
          action: undefined,
          leader: desc.leader
        }
      )
    }
  }

  this.trigger = function(event){
    var keycode = event.keyCode;
    var action = null;
    if(17 != keycode && event.ctrlKey){
      action = this.actions.ctrl[keycode]
    }else{
      action = this.actions[keycode]
    }
    if(action){
      if(false == action()){
        event.preventDefault();
        return false;
      }
    }
    return true
  }
}
global.hotkey = new Hotkey();
})(this);
