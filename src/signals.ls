# Contains all logic that generates and processes signals.
# Signals are functions from time to [-1,1] with an optional duration.

# Pure tones.
sine = (f) ->
  (t) -> Math.sin(2 * Math.PI * f(t))
  |> crop dur(f)

cosine = (f) ->
  (t) -> Math.cos(2 * Math.PI * f(t))
  |> crop dur(f)

triangle = (f) ->
  (t) ->
    phase = ((f(t) % 1 + 1) % 1)
    if phase < 0.25 then phase * 4
    else if phase < 0.75 then 2 - phase * 4
    else phase * 4 - 4
  |> crop dur(f)

square = (f) ->
  (t) -> if ((f(t) % 1 + 1) % 1) < 0.5 then -1 else 1
  |> crop dur(f)

solid = (freq) ->
  (t) -> freq * t

vibrato = (freq1, freq2, freqV) ->
  freq_mid = (freq1 + freq2) / 2
  Vcos = sine(solid(freqV))
  Vamp = -(freq_mid - freq1) / (freqV * Math.PI * 2)
  (t) -> freq_mid * t + Vamp*Vcos(t)

# Chirps: Pure tones that change frequency smoothly
chirp_lin = (freq1, freq2, T) ->
  (t) -> (freq1 * t + (freq2 - freq1) / (2 * T) * t * t)
  |> crop T

chirp_exp = (freq1, freq2, T) ->
  (t) ->
    freq1 * T * Math.pow(freq2/freq1, t/T)/(Math.log(freq2/freq1))
  |> crop T

# White noise
noise = -> (t) -> Math.random() * 2 - 1

fade_in = (T) ->
  (t) ->
    t / T
  |> crop T

fade_out = (T) ->
  (t) ->
    1 - t / T
  |> crop T

# ADSR envelope
# params are [attack, delay, sustain, release] x [level, time]
# crop for efficiency
adsr = (at, al, dt, sl, st, rt) ->
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
  |> crop at + dt + st + rt

soft_edges = (s1, soften_time=0.01) ->
  adsr(soften_time, 1, 0, 1, dur(s1) - 2*soften_time, soften_time)
  |> envelope s1

tremolo = (freq, amp) ->
  baseline = 1 - amp/2
  Vcos = cosine(solid(freq))
  (t) -> baseline + Vcos(t) * amp/2

# Processors act on one or more input signals to produce an output signal.
# These functions return processors.

# increase/decrease volume
gain = (mult) -> (s1) ->
  (t) -> mult * s1(t)
  |> crop dur(s1)

gain_db = (db) ->
  gain Math.pow(10, db/20)

# delay the start point
delay = (delay) -> (s1) ->
  (t) -> if t >= delay then s1(t - delay) else 0
  |> crop Math.max (dur s1) + delay, 0

# limit the duration
crop = (duration) -> (s1) ->
  res = (t) -> if t >= duration then 0 else s1(t)
  res.duration = duration
  res

# sum two signals
plus = (s1, s2) ->
  (t) -> s1(t) + s2(t)
  |> crop Math.max (dur s1), (dur s2)

pluses = (ss) ->
  (t) ->
    accum = 0
    for s in ss
      accum += s(t)
    accum
  |> crop Math.max.apply(null, [dur(s) for s in ss])

# pointwise multiply a signal with another signal
envelope = (s1) -> (s2) ->
  (t) -> s1(t) * s2(t)
  |> crop Math.min(dur(s1), dur(s2))

# muh convolutions
# good for filters and reverb
convolve = (sc) -> (s1) ->
  (t) ->
    accum = 0
    for x, i in sc
      accum += x * s1(t - i / engine.sampleRate)
    accum
  |> crop dur s1

average_window = (T) ->
  num_samples = Math.floor(T * engine.sampleRate)
  [1 / num_samples] * num_samples

exports = module.exports = {
  sine, cosine, triangle, square, solid,
  vibrato, chirp_lin, chirp_exp, noise,
  fade_in, fade_out,
  adsr, soft_edges, tremolo, gain, gain_db,
  delay, crop, plus, pluses, envelope,
  convolve, average_window
}
