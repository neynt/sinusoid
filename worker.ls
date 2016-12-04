this.window = this
self.window = self
window.engine =
  sampleRate: 44100

window.prelude = require 'prelude-ls'
require './src/util.ls'
require './src/fft.js'
window.signals = require './src/signals.ls'
window.dsp = require './src/dsp.ls'
window.instruments = require './src/instruments.ls'
window.music = require './src/music.ls'

eval-code = (code) ->
  start-time = performance.now()
  try
    song = eval code
  catch err
    self.postMessage type: \status, content: "Error while running: #{err.message}"
  end-time = performance.now()
  elapsed-time = ((end-time - start-time) / 1000.0).toFixed 2
  console.log "Running script took #{elapsed-time} seconds"

  if Array.isArray song then song else [song]

self.onmessage = (msg) ->
  switch msg.data.action
  case \update_song
    code = msg.data.code
    self.postMessage action: \status, status: "running code..."
    self.song = eval-code code
    self.num-channels = song.length
    self.song-duration = song.reduce(((acc, cur) -> Math.max(acc, dur(cur))), 0)
    self.duration = if song-duration <= 600 then song-duration else 2
    self.postMessage action: \update_song_done, num-channels: num-channels, duration: duration
  case \render_song
    window.engine.sampleRate = msg.data.sampleRate
    self.channels = msg.data.channels
    self.postMessage action: \status, status: "rendering"
    for c from 0 til self.num-channels
      for i from 0 til self.channels[c].length
        time = i / engine.sampleRate
        sample = song[c](time)
        if !isFinite(sample)
          sample = 0
          console.log "Warning: non-finite sample at time #{time}"
        self.channels[c][i] = sample
    console.log "done rendering"
    self.postMessage action: \render_song_done, channels: self.channels,
      [channel.buffer for channel in self.channels]
