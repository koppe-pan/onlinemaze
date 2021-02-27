// "upload_file" という ID 属性のエレメントを取得する
var input_file = document.getElementById("upload_file");
if(input_file!=null){
  var upload_bytestring = document.getElementById("upload_bytestring");

  // --------------------------------------------
  // 値が変化した時に実行されるイベント
  // ------------------------------------------------------------
  input_file.onchange = function (){

    // ファイルが選択されたか
    if(!(input_file.value)) return;

    // FileReader クラスに対応しているか
    if(!(window.FileReader)) return;

    // ------------------------------------------------------------
    // File オブジェクトを取得（HTML5 世代）
    // ----------------------------------------------------
    // ファイルリストを取得
    var file_list = input_file.files;
    if(!file_list) return;

    // 0 番目の File オブジェクトを取得
    var file = file_list[0];
    if(!file) return;

    // ------------------------------------------------------------
    // FileReader オブジェクトを生成
    // ------------------------------------------------------------
    var file_reader = new FileReader();

    // ------------------------------------------------------------
    // 読み込み成功時に実行されるイベント
    // ------------------------------------------------------------
    file_reader.onload = function(e){


      // 出力テスト
      console.log(file_reader.result);
        upload_bytestring.value = file_reader.result
    };

    // ------------------------------------------------------------
    // 読み込みを開始する（ArrayBuffer オブジェクトを得る---------------------------------------------------
    file_reader.readAsBinaryString(file);
  };

}
