#LiveScript = require 'livescript'
#window.ls = LiveScript
#console.log LiveScript
codemirror = require 'codemirror'
require 'codemirror/mode/javascript/javascript'
require 'codemirror/mode/livescript/livescript'
pako = require 'pako'

window.timeit = (f, name="task") ->
  console.log("started #{name}")
  time_start = performance.now()
  res = f()
  time_end = performance.now()
  time_elapsed_secs = ((time_end - time_start) / 1000)
  #console.log(res)
  console.log("finished #{name} in #{time_elapsed_secs.toFixed(2)} seconds")
  res

window.addEventListener "load", ->
  play_button = document.getElementById('play_button')
  song_textarea = document.getElementById('song_textarea')
  rendering_status = document.getElementById('rendering_status')

  window.stx = song_textarea

  # Bind listeners
  # TODO: Get play button to work

  console.log("Script loaded.")
