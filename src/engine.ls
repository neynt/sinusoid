# The engine is the interface between the dreamland of (t) -> [-1,1]
# and the real world.

audioCtx = new (window.AudioContext || window.webkitAudioContext)
sampleRate = audioCtx.sampleRate

window.analyser = analyser = audioCtx.createAnalyser()
bufferLength = analyser.frequencyBinCount
window.dataArray = dataArray = new Float32Array bufferLength
analyser.connect audioCtx.destination

class SongEngine
  @colors = [
    'rgba(249, 38, 81, 1.0)'
    'rgba(0, 192, 255, 0.2)'
    'rgba(128, 128, 0, 0.2)'
  ]
  ->
    @listeners =
      rendering_done: []
      rendering_status: []
      error: []
    @channels = []

    # Callbacks to get various data from the components.
    # TODO: do these in a better way
    @get-song-src = -> ''
    @get-lang = -> ''

    self = this
    @worker = new Worker "worker.entry.js"
    @worker.onmessage = (msg) ->
      switch msg.data.action
      case \update_song_done
        num-channels = msg.data.num-channels
        duration = msg.data.duration
        frameCount = sampleRate * duration
        self.audio-buffer = audioCtx.createBuffer(num-channels, frameCount, sampleRate)
        self.channels = [new Float32Array(self.audio-buffer.length) for c from 0 til num-channels]
        self.worker.postMessage \
          action: \render_song, sampleRate: sampleRate, channels: self.channels,
          [channel.buffer for channel in self.channels]
      case \status
        self.notify \rendering_status, msg.data.status
      case \render_song_done
        self.channels = msg.data.channels
        for c, i in self.channels
          if self.audio-buffer.copy-to-channel
            self.audio-buffer.copy-to-channel c, i
        source = audioCtx.createBufferSource()
        source.buffer = self.audio-buffer
        source.connect analyser
        source.start()
        self.notify \rendering_status, "rendering done"
        self.notify \rendering_done

  render-song: ->
    song_src = @get-song-src()
    lang = @get-lang()
    try
      compiled = match lang
      | 'livescript' => livescript.compile song_src
      | 'javascript' => song_src
      | _ => song_src
    catch err
      @notify \error, "Compile error: #{err.message}"
      throw err

    @worker.postMessage action: \update_song, code: compiled

  add-listener: (topic, f) ->
    @listeners[topic].push f

  notify: (topic, message) ->
    for f in @listeners[topic]
      f(message)

  redraw-canvas: (canvas) ->
    const width = canvas.width = canvas.offsetWidth
    const height = canvas.height = canvas.offsetHeight
    const ctx = canvas.getContext '2d'
    ctx.fillStyle = '#000'
    ctx.fillRect 0, 0, width, height
    if !@channels?
      return
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

  redraw-freq-canvas: (canvas) ->
    const ctx = canvas.getContext '2d'
    const width = canvas.width = canvas.offsetWidth
    const height = canvas.height = canvas.offsetHeight
    ctx.fillStyle = '#000'
    ctx.fillRect 0, 0, width, height
    const num_freqs = dataArray.length
    analyser.getFloatFrequencyData dataArray
    ctx.fillStyle = '#f00'
    for f from 0 til num_freqs
      const bar_width = width / num_freqs
      const concentration = (Math.max dataArray[f] + 100, 0) / 100
      const bar_height = concentration * height
      const bar_x = f * bar_width
      ctx.globalAlpha = concentration
      ctx.fillRect bar_x, height - bar_height, bar_width, bar_height

window.engine =
  sampleRate: sampleRate

window.SongEngine = SongEngine
