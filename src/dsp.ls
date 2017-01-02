{delay} = signals
{crop} = signals
{sin, cos, PI} = Math

# Converts a continuous signal to a discrete signal (i.e. array)
# by sampling at a rate of engine.sampleRate.
# signal -> Float64Array
discretize = (s1) ->
  if (dur s1) > 600
    throw message: "error: signal is too long to discretize"

  min_n = (dur s1) * engine.sampleRate * 1.2
  n = 256
  while n < min_n
    n *= 2
  cache = new Float64Array(n)
  for i from 0 til n
    cache[i] = s1 (i / engine.sampleRate)
  cache

# Wraps a discrete signal in a function.
# Float64Array -> signal
play_discrete = (d) ->
  duration = (d.length - 1) / engine.sampleRate
  (t) ->
    if 0 <= t < duration then
      d[Math.round(t * engine.sampleRate)]
    else
      0
  |> crop duration

# Sinc function with a certain cutoff
sinc = (cutoff) -> (i) ->
  if i == 0 then 2 * cutoff else sin(2 * PI * cutoff * i) / (i * PI)

# DSP window functions
# M: the size of the filter.
# Higher M means sharper frequency response but slower.
window =
  hamming: (M) ->
    (i) -> 0.54 - 0.46 * cos(2 * PI * i / M)
  blackman: (M) ->
    (i) -> 0.42 - 0.5 * cos(2 * PI * i / M) +
                 0.08 * cos(4 * PI * i / M)

lpf_kernel = (cutoff, M) ->
  cutoff_d = cutoff / engine.sampleRate
  my_sinc = sinc cutoff_d
  my_window = window.blackman M
  f = (i) ->
    (my_sinc i - M / 2) * (my_window i)
  for i from 0 til M+1
    f i

hpf_kernel = (cutoff, M) ->
  k = lpf_kernel cutoff, M
  if M % 2 != 0
    throw message: "M must be even"
  mid = Math.round(M/2)
  for i from 0 til M+1
    if i == mid then 1 - k[i] else -k[i]

# Returns the convolution of two discrete signals as a discrete signal.
# (Float32Array) -> (Float32Array) -> (Float32Array)
fft_convolve = (kernel) -> (d1) ->
  n = d1.length

  filter = new Float32Array n
  for ir, i in kernel
    filter[i] = ir

  res = new Float32Array n
  convolveReal d1, filter, res
  res

# Low pass filter with given cutoff in Hz
lpf = (cutoff) -> (s1) ->
  s1
  |> discretize
  |> fft_convolve lpf_kernel cutoff, 1000
  |> (.slice 1000)
  |> play_discrete

# High pass filter with given cutoff in Hz
hpf = (cutoff) -> (s1) ->
  s1
  |> discretize
  |> fft_convolve hpf_kernel cutoff, 1000
  |> (.slice 1000)
  |> play_discrete

exports = module.exports = {
  discretize, play_discrete, fft_convolve
  lpf, hpf
}
