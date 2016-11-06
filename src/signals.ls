# Contains all logic that generates and processes signals.
# Signals are functions from time to [-1,1] with an optional duration.

# Pure tones.
window.sine = (f) ->
  (t) -> Math.sin(2 * Math.PI * f(t))
  |> crop dur(f), _

window.cosine = (f) ->
  (t) -> Math.cos(2 * Math.PI * f(t))
  |> crop dur(f), _

window.triangle = (f) ->
  (t) ->
    phase = ((f(t) % 1 + 1) % 1)
    if phase < 0.5 then phase * 4 - 1 else 3 - phase * 4
  |> crop dur(f), _

window.square = (f) ->
  (t) -> if ((f(t) % 1 + 1) % 1) < 0.5 then -1 else 1
  |> crop dur(f), _

window.solid = (freq) ->
  (t) -> freq * t

window.vibrato = (freq1, freq2, freqV) ->
  freq_mid = (freq1 + freq2) / 2
  Vcos = sine(solid(freqV))
  Vamp = -(freq_mid - freq1) / (freqV * Math.PI * 2)
  (t) -> freq_mid * t + Vamp*Vcos(t)

# Chirps: Pure tones that change frequency smoothly
window.chirp_lin = (freq1, freq2, T) ->
  (t) -> (freq1 * t + (freq2 - freq1) / (2 * T) * t * t)
  |> crop T, _

window.chirp_exp = (freq1, freq2, T) ->
  (t) ->
    freq1 * T * Math.pow(freq2/freq1, t/T)/(Math.log(freq2/freq1))
  |> crop T, _

# White noise
window.noise = -> (t) -> Math.random() * 2 - 1

# Violet noise
window.noise_violet = ->
  white = memoize noise()
  (t) -> (white(t + 1 / 44100) - white(t)) / 2

# ADSR envelope
# params are [attack, delay, sustain, release] x [level, time]
# crop for efficiency
window.adsr = (at, al, dt, sl, st, rt) ->
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
  |> crop(at + dt + st + rt, _)

window.soft_edges = (s1, soften_time=0.01) ->
  envelope(
    adsr(soften_time, 1, 0, 1, dur(s1) - 2*soften_time, soften_time)
    s1)

window.tremolo = (freq, amp) ->
  baseline = 1 - amp/2
  Vcos = cosine(solid(freq))
  (t) -> baseline + Vcos(t) * amp/2

# Processors act on one or more input signals to produce an output signal.
# These functions return processors.

# increase/decrease volume
window.gain = (mult, s1) ->
  (t) -> mult * s1(t)
  |> crop(dur(s1), _)

window.gain_db = (db, s1) ->
  gain(Math.pow(10, db/20), s1)

# delay the start point
window.delay = (delay, s1) ->
  (t) -> if t >= delay then s1(t - delay) else 0
  |> crop(Math.max(dur(s1) + delay, 0), _)

# limit the duration
window.crop = (duration, s1) ->
  res = (t) -> if t >= duration then 0 else s1(t)
  res.duration = duration
  res

# sum two signals
window.plus = (s1, s2) ->
  (t) -> s1(t) + s2(t)
  |> crop(Math.max(dur(s1), dur(s2)), _)

window.pluses = (ss) ->
  (t) ->
    accum = 0
    for s in ss
      accum += s(t)
    accum
  |> crop(Math.max.apply(null, [dur(s) for s in ss]), _)

# pointwise multiply a signal with another signal
window.envelope = (s1, s2) ->
  (t) -> s1(t) * s2(t)
  |> crop(Math.min(dur(s1), dur(s2)), _)
