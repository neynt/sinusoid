button_press = ->
  song = eval(document.getElementById('song_textarea').value)
  good_dur = if dur(song) > 60 then 2 else dur(song)
  play(delay(song, -0.0), good_dur)

window.onload = ->
  console.log("Script loaded.")
  document.getElementById('play_button').addEventListener("click", button_press)
