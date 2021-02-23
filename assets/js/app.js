// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

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

let Hooks = {}
Hooks.Prepare = {
  mounted(){
    this.el.addEventListener('click', () => {
      const name = document.querySelector('input[name="name"]').value;
      console.log(name)
      /***** ユーザーの現在の位置情報を取得 *****/
      var successCallback = (position) => {
        this.pushEvent("set-location", {loc: {x: position.coords.latitude, y: position.coords.longitude}, name: name});
      }

      /***** 位置情報が取得できない場合 *****/
      function errorCallback(error) {
        console.log(error)
      }

      var options = {
        enableHighAccuracy: true, //GPS機能を利用
        timeout: 5000, //取得タイムアウトまでの時間（ミリ秒）
        maximumAge: 0 //常に新しい情報に更新
      };
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
      this.pushEvent("put-location", {loc: {x: position.coords.latitude, y: position.coords.longitude}});
    }

    /***** 位置情報が取得できない場合 *****/
    function errorCallback(error) {
      console.log(error)
    }

    var options = {
      enableHighAccuracy: true, //GPS機能を利用
      timeout: 5000, //取得タイムアウトまでの時間（ミリ秒）
      maximumAge: 0 //常に新しい情報に更新
    };
    navigator.geolocation.getCurrentPosition(successCallback, errorCallback, options);
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