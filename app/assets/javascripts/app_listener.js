class AppListener{
  constructor(name, params){
    this.name     = name
    this.params   = params

    this.response = {}
  }

  init_call(){
    const event = new CustomEvent(this.name, {'detail': this.params});
    event.initEvent(this.name, true, true);
    document.dispatchEvent(event);

    let that = this
    return new Promise((success, error)=>{
      window.setTimeout(()=>{ success(that.response); }, 300); //wait a few second just in case
    });
  }

  run(e, callback){
    const _e = Object.assign(e, { set_key: (key, value)=>{ this.set(key, value) } })
    callback(_e);
  }

  set(key, value){
    this.response[key] = value;
  }
}

var LISTENERS = {}

AppListenTo = (event_name, callback={}) => {
  const listener_fnc = (e)=>{
    try{
      LISTENERS[`${event_name}.object`].run(e, callback);
    }catch(e){
      console.error(e);
      console.error(`Undefined AppListener : ${event_name}.object`);
    }
  }

  document.addEventListener(event_name, listener_fnc, false);
}

AppEmit = (event_name, params=null) => {
  LISTENERS[`${event_name}.object`] = new AppListener(event_name, params);

  return LISTENERS[`${event_name}.object`].init_call()
}