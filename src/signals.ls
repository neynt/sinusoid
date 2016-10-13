# Contains all logic that generates and processes signals.
# Signals are functions from time to [-1,1].

# Pure tones
window.sine = (freq) -> (t) -> Math.sin(2 * Math.PI * freq * t)
window.cosine = (freq) -> (t) -> Math.cos(2 * Math.PI * freq * t)

# Chirps: Pure tones that change frequency smoothly
window.chirp_linear = (freq1, freq2, T) -> crop(
  (t) -> Math.sin(2 * Math.PI * (freq1 * t + (freq2 - freq1) / (2 * T) * t * t))
  T)
window.chirp_exp = (freq1, freq2, T) -> crop(
  (t) -> Math.sin(2 * Math.PI * freq1 * T *
           Math.pow(freq2 / freq1, t / T) / (Math.log(freq2 / freq1)))
  T)

# Pure tone with vibrato
window.sine_vibrato = (freq1, freq2, freqV) ->
  freq_mid = (freq1 + freq2) / 2
  Vcos = cosine(freqV)
  Vamp = Math.abs(freq_mid - freq1)
  (t) -> Math.sin(2 * Math.PI * freq_mid * t + Vamp * Vcos(t))

# White noise
window.noise = -> (t) -> Math.random() * 2 - 1

# ADSR envelope
# params are [attack, delay, sustain, release] x [level, time]
# crop for efficiency
window.adsr = (at, al, dt, sl, st, rt) ->
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

# Processors act on one or more input signals to produce an output signal.
# These functions return processors.

# increase/decrease volume
window.gain = (s1, mult) -> (t) -> s1(t) * mult

# delay the start point
window.delay = (s1, delay) ->
  crop(
    (t) -> if t >= delay then s1(t - delay) else 0
    Math.max(dur(s1) + delay, 0))

# limit the duration
window.crop = (s1, duration) ->
  res = (t) -> if t >= duration then 0 else s1(t)
  res.duration = duration
  res

# sum two signals
window.plus = (s1, s2) ->
  crop(
    (t) -> s1(t) + s2(t)
    Math.max(dur(s1), dur(s2)))

# pointwise multiply a signal with another signal
window.envelope = (s1, s2) ->
  crop(
    (t) -> s1(t) * s2(t)
    Math.min(dur(s1), dur(s2)))
