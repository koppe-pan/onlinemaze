// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"
import "./uploader.js"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

//タッチイベントが利用可能かの判別

const supportTouch = 'ontouchend' in document;

// イベント名

const TOUCHSTART = supportTouch ? 'touchstart' : 'mousedown';
const TOUCHMOVE = supportTouch ? 'touchmove' : 'mousemove';
const TOUCHEND = supportTouch ? 'touchend' : 'mouseup';

/***** 位置情報が取得できない場合 *****/
function errorCallback(error) {
  console.log(error)
}

const options = {
  enableHighAccuracy: true, //GPS機能を利用
  timeout: 5000, //取得タイムアウトまでの時間（ミリ秒）
  maximumAge: 0 //常に新しい情報に更新
};


let Hooks = {}
Hooks.Prepare = {
  mounted(){
    this.el.addEventListener('click', () => {
      const name = document.querySelector('input[name="name"]').value;
      /***** ユーザーの現在の位置情報を取得 *****/
      var successCallback = (position) => {
        if(!isNaN(position.coords.latitude)&& !isNaN(position.coords.longitude))
        this.pushEvent("set-location", {loc: {x: position.coords.latitude, y: position.coords.longitude}, name: name});
      }
      navigator.geolocation.getCurrentPosition(successCallback, errorCallback, options);
    })
  }
}
Hooks.SetPosition = {
  mounted(){
    this.el.addEventListener('click', () => {
      var successCallback = (position) => {
        if(!isNaN(position.coords.latitude)&& !isNaN(position.coords.longitude))
        this.pushEvent("set-location", {loc: {x: position.coords.latitude, y: position.coords.longitude}});
      }
      navigator.geolocation.getCurrentPosition(successCallback, errorCallback, options);
    })
  }
}
Hooks.Can = {
  mounted(){
    this.pushEvent("set-window", {win: {x: window.innerWidth, y: window.innerHeight}});
  },
  updated(){
    /***** ユーザーの現在の位置情報を取得 *****/
    var successCallback = (position) => {
        if(!isNaN(position.coords.latitude)&& !isNaN(position.coords.longitude))
      this.pushEvent("put-location", {loc: {x: position.coords.latitude, y: position.coords.longitude}});
    }
    navigator.geolocation.getCurrentPosition(successCallback, errorCallback, options);
  }
}
Hooks.Canvas = {
  mounted(){
    this.pushEvent("set-window", {win: {x: window.innerWidth, y: window.innerHeight}});
    this.el.addEventListener(TOUCHSTART, e => {
      this.pushEvent("touchstart", {x: Math.round(e.clientX-this.el.getBoundingClientRect().left), y: Math.round(e.clientY-this.el.getBoundingClientRect().top)})
    });
    this.el.addEventListener(TOUCHMOVE, e => {
      this.pushEvent("touchmove", {x: Math.round(e.clientX-this.el.getBoundingClientRect().left), y: Math.round(e.clientY-this.el.getBoundingClientRect().top)})
    });
    this.el.addEventListener(TOUCHEND, e => {
      this.pushEvent("touchend", {})
    });
  }
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
