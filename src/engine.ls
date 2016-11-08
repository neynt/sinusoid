# The engine is the interface between the dreamland of (t) -> [-1,1]
# and the real world.

audioCtx = (new (window.AudioContext || window.webkitAudioContext))
sampleRate = audioCtx.sampleRate

class SongEngine
  @colors = [
    'rgba(255, 128, 0, 0.5)'
    'rgba(0, 192, 255, 0.5)'
    'rgba(128, 128, 0, 0.5)'
  ]
  ->
    window.addEventListener "load", ->
      rendering_status = document.getElementById('rendering_status')
    @listeners = []
    @channels = []

  render_song: (song, duration) ->
    time_start = performance.now()

    if Array.isArray(song)
      num_channels = song.length
    else
      num_channels = 1
      song = [song]

    frameCount = sampleRate * duration
    myArrayBuffer = audioCtx.createBuffer(num_channels, frameCount, sampleRate)
    chunkSize = Math.round(sampleRate)

    var cur_buffering

    @channels = [myArrayBuffer.getChannelData(c) for c from 0 til num_channels]
    window.ch = @channels # TODO remove

    self = this
    render_from = (start, cur_channel) ->
      end = Math.min(start + chunkSize, frameCount)
      for i from start til end
        self.channels[cur_channel][i] = song[cur_channel](i / sampleRate)

      completion =
        (start + cur_channel * frameCount) / (num_channels * frameCount)
      rendering_status.innerHTML = "#{(completion*100).toFixed(0)}%"

      if end == frameCount and cur_channel + 1 < num_channels
        setTimeout(-> render_from(0, cur_channel + 1))
      else if end < frameCount
        setTimeout(-> render_from(start + chunkSize, cur_channel))
      else
        # TODO: Get this outta here!
        rendering_status.innerHTML = "100%"
        source = audioCtx.createBufferSource()
        window.buf = source.buffer = myArrayBuffer
        source.connect(audioCtx.destination)
        source.start()
        time_end = performance.now()
        console.log("rendering #{duration} seconds of audio took #{((time_end - time_start) / 1000.0).toFixed(2)} seconds")
        for f in self.listeners
          f()

    render_from(0, 0)

  add_listener: (f) ->
    @listeners.push f

  redraw_canvas: (canvas) ->
    const width = canvas.width = canvas.offsetWidth
    const height = canvas.height = canvas.offsetHeight
    const ctx = canvas.getContext '2d'
    ctx.fillStyle = '#000'
    ctx.fillRect 0, 0, width, height
    const num_samples = Math.max.apply(null, @channels.map (.length))
    for c from 0 til @channels.length
      ctx.strokeStyle = @@colors[c % @@colors.length]
      ctx.beginPath()
      ctx.moveTo @channels[c][0], height / 2
      for i from 1 til @channels[c].length
        x = i / num_samples * width
        y = height * 1/2 * (1 - @channels[c][i])
        ctx.lineTo x, y
      ctx.stroke()

window.engine =
  sample_rate: sampleRate

window.SongEngine = SongEngine
