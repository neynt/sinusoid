# The engine is the interface between the dreamland of (t) -> [-1,1]
# and the real world.

audioCtx = (new (window.AudioContext || window.webkitAudioContext))
sampleRate = audioCtx.sampleRate

# Plays the first (duration) seconds of (song).
# song: time -> [0.0, 1.0]
# duration: time
window.play = (song, duration) ->
  time_start = performance.now()
  console.log("Rendering began at #{time_start}")

  channels = 2
  frameCount = sampleRate * duration
  myArrayBuffer = audioCtx.createBuffer(channels, frameCount, sampleRate)

  for channel from 0 til channels
    nowBuffering = myArrayBuffer.getChannelData(channel)
    for i from 0 til frameCount
      nowBuffering[i] = song(i / sampleRate)

  source = audioCtx.createBufferSource()
  source.buffer = myArrayBuffer
  source.connect(audioCtx.destination)
  source.start()

  time_end = performance.now()
  console.log("Rendering ended at #{time_end}")
  console.log("Rendering #{duration} seconds of audio took #{(time_end - time_start) / 1000.0} seconds")

window.engine =
  sample_rate: sampleRate
  play: play
