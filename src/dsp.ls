{delay} = signals
{crop} = signals

discretize = (s1) ->
  if (dur s1) > 600
    throw "error: signal is too long to discretize efficiently"

  min_n = (dur s1) * engine.sampleRate * 1.2
  n = 256
  while n < min_n
    n *= 2
  cache = new Float64Array(n)
  for i from 0 til n
    cache[i] = s1 (i / engine.sampleRate)
  cache

play_discrete = (d) ->
  duration = d.length / engine.sampleRate
  (t) ->
    if 0 <= t <= duration then
      d[Math.round(t * engine.sampleRate)]
    else
      0
  |> crop duration

pad_to_pow2 = (arr) ->
  0

sinc = (cutoff) ->
  (i) -> if i == 0 then 2 * cutoff else Math.sin(2 * Math.PI * cutoff * i) / (i * Math.PI)

hamming_window = (M) ->
  (i) -> 0.54 - 0.46 * Math.cos(2 * Math.PI * i / M)

blackman_window = (M) ->
  (i) -> 0.42 - 0.5 * Math.cos(2 * Math.PI * i / M) +
               0.08 * Math.cos(4 * Math.PI * i / M)

lpf_kernel = (cutoff, M) ->
  cutoff_d = cutoff / engine.sampleRate
  my_sinc = sinc cutoff_d
  my_window = blackman_window M
  f = (i) ->
    (my_sinc i - M / 2) * (my_window i)
  for i from 0 til M+1
    f i

hpf_kernel = (cutoff, M) ->
  k = lpf_kernel cutoff, M
  if M % 2 != 0
    throw "M must be even"
  mid = Math.round(M/2)
  for i from 0 til M+1
    k[i]

fft_convolve = (kernel) -> (d1) ->
  n = d1.length

  filter = new Float32Array n
  for ir, i in kernel
    filter[i] = ir

  res = new Float32Array n
  convolveReal d1, filter, res
  res

window.lpf = lpf = (cutoff) -> (s1) ->
  s1
  |> discretize
  |> fft_convolve lpf_kernel cutoff, 1000
  |> -> it.slice 1000
  |> play_discrete

window.hpf = hpf = (cutoff) -> (s1) ->
  s1
  |> discretize
  |> fft_convolve hpf_kernel cutoff, 1000
  |> -> it.slice 1000
  |> play_discrete

exports = module.exports = {
  discretize, play_discrete, fft_convolve
  lpf
}
