# worker.ls
#
# The web worker.
# Compiles, runs, and renders songs.
#
# Compile: Transform user input string to JavaScript string.
#
# Run: Eval that string to get a signal or array of signals.
#      (a signal is a function from time to [-1, 1])
#
# Render: Samples each signal to a Float32Array for playback.
#
# Exposes the preamble (all musical things).
#
# See also: index.ls

# Make window a global object
this.window = this
self.window = self

# Phony engine that exposes the sampleRate.
# TODO: Allow passing in a custom sample rate.
window.engine =
  sampleRate: 44100

require './src/preamble.ls'

eval-code = (code) ->
  start-time = performance.now()
  song = eval code
  end-time = performance.now()
  elapsed-time = ((end-time - start-time) / 1000.0).toFixed 2
  console.log "Running script took #{elapsed-time} seconds"
  if Array.isArray song
    song
  else if typeof song == \function
    [song]
  else
    throw message: "code did not return a function"

self.onmessage = (msg) ->
  switch msg.data.action
  case \update_song
    code = msg.data.code
    self.postMessage action: \status, status: "running code..."
    try
      self.song = eval-code code
    catch err
      console.log "Error while running: #{err.message}"
      self.postMessage action: \status, status: "Error while running: #{err.message}"
      throw err

    self.num-channels = song.length
    self.song-duration = song.reduce ((acc, cur) -> Math.max acc, util.dur cur), 0
    self.duration = if song-duration <= 600 then song-duration else 2
    self.postMessage action: \update_song_done, num-channels: num-channels, duration: duration
  case \render_song
    window.engine.sampleRate = msg.data.sampleRate
    self.channels = msg.data.channels
    self.postMessage action: \status, status: "rendering"

    num-samples = self.channels[0].length
    total-samples = self.num-channels * num-samples
    num-chunks = Math.ceil(100 / self.num-channels)
    chunk-size = total-samples / num-chunks
    for c from 0 til self.num-channels
      for n from 0 til num-chunks
        start = Math.round(n * chunk-size)
        end = Math.min Math.round((n + 1) * chunk-size), num-samples
        for i from start til end
          time = i / engine.sampleRate
          sample = song[c](time)
          if !isFinite(sample)
            sample = 0
            console.log "Warning: non-finite sample at time #{time}"
          self.channels[c][i] = sample

        completion = ((c * num-samples + end) / total-samples * 100).toFixed(0)
        self.postMessage action: \status, status: "rendering #{completion}%"
    console.log "done rendering"
    self.postMessage action: \render_song_done, channels: self.channels,
      [channel.buffer for channel in self.channels]
