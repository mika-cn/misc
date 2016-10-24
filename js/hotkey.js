;(function(global, undefined){
var Hotkey = function(){
  this.code = function(key){
    return ({
      num1: 49,  f1: 112,
      num2: 50,  f2: 113,
      num3: 51,  f3: 114,
      num4: 52, enter: 13,
      num5: 53,
      num6: 54,
      num7: 55,
      num8: 56,
      num9: 57,
    })[key];
  }
  this.transform = function(key){
    var rules = {
      97:  49,
      98:  50,
      99:  51,
      100: 52,
      101: 53,
      102: 54,
      103: 55,
      104: 56,
      105: 57,
    }
    return (rules[key] ? rules[key] : key);
  }

  //desc {:key, :action, :leader, :priority}
  this.bind = function(desc){
    var priority = desc.priority || this.priority_default;
    if(desc.leader){
      this.actions[priority][desc.leader][this.code(desc.key)] = desc.action;
    }else{
      this.actions[priority][this.code(desc.key)] = desc.action;
    }
    return function(){
      //console.log('unbind: '+desc.key)
      hotkey.bind(
        {
          priority: priority,
          key: desc.key,
          action: undefined,
          leader: desc.leader
        }
      )
    }
  }

  this.trigger = function(event){
    var keycode = this.transform(event.keyCode);
    var i = this.priority_num;
    for(;i>0;i--){
      var priority = this.actions[i];
      var action = null;
      if(17 != keycode && event.ctrlKey){
        action = priority.ctrl[keycode]
      }else{
        action = priority[keycode]
      }
      if(action){
        if(false == action()){
          return;
        }
      }
    }
  }

  // priority: { keycode:, ctrl: { keycode }}
  this.init = function(){
    this.priority_num = 7;
    this.priority_default = 2;
    this.actions = {
      7: {ctrl: {}},
      6: {ctrl: {}},
      5: {ctrl: {}},
      4: {ctrl: {}},
      3: {ctrl: {}},
      2: {ctrl: {}},
      1: {ctrl: {}}
    }
  }
  this.init()
}

var hotkey = new Hotkey();
})(window);
