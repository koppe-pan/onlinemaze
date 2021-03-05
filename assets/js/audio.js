export var ctx = new (window.AudioContext||window.webkitAudioContext);
var initial_delay_sec = 0;
var scheduled_time = 0;

function playChunk(audio_src, scheduled_time) {
    if (audio_src.start) {
        audio_src.start(scheduled_time);
    } else {
        audio_src.noteOn(scheduled_time);
    }
}

export function playAudioStream(audio_f32) {
    var audio_buf = ctx.createBuffer(1, audio_f32.length, 44100),
        audio_src = ctx.createBufferSource(),
        current_time = ctx.currentTime;

    audio_buf.getChannelData(0).set(audio_f32);

    audio_src.buffer = audio_buf;
    audio_src.connect(ctx.destination);

    if (current_time < scheduled_time) {
        playChunk(audio_src, scheduled_time);
        scheduled_time += audio_buf.duration;
    } else {
        playChunk(audio_src, current_time);
        scheduled_time = current_time + audio_buf.duration + initial_delay_sec;
    }
}
