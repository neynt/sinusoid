console.log("Script started at #{performance.now()}")

###
  Miscellaneous utility functions.
###
extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

# things: 3-tuples of (begin, end, object)
# allows for querying of "which intervals contain
# this point" in log(n) time
segments = (things) ->
  objects_at = {}
  for [begin, end, _] in things
    objects_at[begin] = []
    objects_at[end] = []
  
  # JavaScript: The Bad Parts
  endpoints = Object.keys(objects_at).map((x) -> Number(x)).sort((a,b) -> a-b)
  console.log(objects_at)
  console.log(endpoints)
  window.wtf = endpoints
  for [begin, end, thing] in things
    #console.log(begin)
    for point in endpoints
      if begin <= point < end
        objects_at[point].push(thing)
  {
    find: (point) ->
      min = 0
      max = endpoints.length - 1
      while min < max
        #console.log(min, mid, max)
        mid = Math.ceil((min + max) / 2)
        if endpoints[mid] > point
          max = mid - 1
        else
          min = mid
      objects_at[endpoints[min]]
  }

###
  The engine is the interface between the dreamland of (t) -> Float
  and the real world.
###

# Plays the first (duration) seconds of (song).
# song: time -> [0.0, 1.0]
# duration: time
window.play = (song, duration) ->
  time_start = performance.now()
  console.log("Rendering began at #{time_start}")
  audioCtx = new (window.AudioContext || window.webkitAudioContext)()

  channels = 2
  sampleRate = audioCtx.sampleRate
  frameCount = sampleRate * duration
  myArrayBuffer = audioCtx.createBuffer(channels, frameCount, sampleRate)

  for channel in [0 ... channels]
    nowBuffering = myArrayBuffer.getChannelData(channel)
    for i in [0 ... frameCount]
      nowBuffering[i] = song(i / sampleRate)

  source = audioCtx.createBufferSource()
  source.buffer = myArrayBuffer
  source.connect(audioCtx.destination)
  source.start()

  time_end = performance.now()
  console.log("Rendering ended at #{time_end}")
  console.log("Rendering #{duration} seconds of audio took #{(time_end - time_start) / 1000.0} seconds")

###
  Signals are functions of the signature (t: time) -> [0.0, 1.0].
  They often represent raw waveforms. However, they can also be other
  things.

  These functions return signals.
###
sine = (freq) -> (t) -> Math.sin(2 * Math.PI * freq * t)
noise = () -> (t) -> Math.random() * 2 - 1

# ADSR envelope
# params are [attack, delay, sustain, release] x [level, time]
# crop for efficiency
adsr = (at, al, dt, sl, st, rt) ->
  crop(
    (t) ->
      if t <= at
        return t / at * al
      t -= at
      if t <= dt
        return (((dt - t) * al) + (t * sl)) / dt
      t -= dt
      if t <= st
        return sl
      t -= st
      if t <= rt
        return (((rt - t) * sl)) / rt
      else
        return 0
    at + dt + st + rt)

###
  Processors act on one or more input signals to produce an output signal.

  These functions return processors.
###
  
# increase/decrease volume
gain = (s1, mult) -> (t) -> s1(t) * mult

# delay the start point
delay = (s1, delay) ->
  crop(
    (t) -> if t >= delay then s1(t - delay) else 0
    Math.max(dur(s1) + delay, 0))

# limit the duration
crop = (s1, duration) ->
  res = (t) -> if t >= duration then 0 else s1(t)
  res.duration = duration
  res

dur = (s1) -> s1.duration ? Infinity

# sum two signals
plus = (s1, s2) ->
  crop(
    (t) -> s1(t) + s2(t)
    Math.max(dur(s1), dur(s2)))

# pointwise multiply a signal with another signal
envelope = (s1, s2) ->
  crop(
    (t) -> s1(t) * s2(t)
    Math.min(dur(s1), dur(s2)))

# For efficiency, we should keep track of the end time of
# a signal in the signal itself. This is done through the
# "duration" property.

###
  Other utilities that represent domain musical knowledge go here.
###
# midi number to frequency
midi = (n) -> 440 * Math.pow(2, (n - 69) / 12)

window.lol = adsr(2.0, 1.0, 1.0, 0.5, 1.5, 0.5)

# Instruments:
# midi number -> signal
bleep = (pitch) ->
  envelope(
    envelope(
      gain(
        sine(midi pitch)
        0.1)
      adsr(0.015, 1.0, 0.1, 0.3, 0.1, 0.2))
    sine(6))

tsch = () ->
  envelope(
    gain(noise(), 0.1)
    adsr(0.015, 1.0, 0.15, 0.0, 0.2, 0.0))

# Melody
# combines collection of (offset, signal) pairs
# to a single signal
melody = (notes) ->
  seg = segments([ofs, ofs + dur(s), [ofs, s]] for [ofs, s] in notes)
  maxtime = Math.max.apply(null, ofs + dur(s) for [ofs, s] in notes)
  crop(
    (t) ->
      accum = 0.0
      for [ofs, s] in seg.find(t)
        accum += delay(s, ofs)(t)
      accum
    maxtime)

measure1 = melody ([ofs * 0.24, s] for [ofs, s] in [
  [0, bleep 77]
  [1, bleep 81]
  [2, bleep 83]
])

# muh drums
drums = melody ([ofs * 0.24, s] for [ofs, s] in [
  [0.0, tsch()]
  [1.0, tsch()]
  [1.5, tsch()]
  [2.0, tsch()]
  [3.0, tsch()]
])

drumline = melody ([ofs * 0.24, s] for [ofs, s] in [
  [0, drums]
  [4, drums]
  [8, drums]
  [12, drums]
  [16, drums]
  [20, drums]
])

# Saria's Song
song = melody ([ofs * 0.24, s] for [ofs, s] in [
  [0, drumline]
  [32, drumline]

  [0, measure1]
  [4, measure1]
  [8, measure1]
  [11, bleep 88]
  [12, bleep 86]

  [14, bleep 83]
  [15, bleep 84]
  [16, bleep 83]
  [17, bleep 79]
  [18, bleep 76]

  [23, bleep 74]
  [24, bleep 76]
  [25, bleep 79]
  [26, bleep 76]

  [32, measure1]
  [36, measure1]
  [40, measure1]
  [43, bleep 88]
  [44, bleep 86]

  [46, bleep 83]
  [47, bleep 84]
  [48, bleep 88]
  [49, bleep 84]
  [50, bleep 79]

  [55, bleep 83]
  [56, bleep 79]
  [57, bleep 74]
  [58, bleep 76]
])

#song = (t) -> (0.1 * sine(440)(Math.pow(t+1.0, 4)))

play(delay(song, -0.0), 15.0)
console.log("Script ended at #{performance.now()}")
