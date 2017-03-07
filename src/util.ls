# Utilities.
export dur = (s1) -> s1.duration ? Infinity

# Given a list of intervals and associated objects,
# returns a function that allows querying of
# "give me all objects whose intervals contains this point" in log(n) time.
# things: 3-tuples of [begin, end, object]
export segment_finder = (things) ->
  objects_at = {}
  for [begin, end, _] in things
    objects_at[begin] = []
    objects_at[end] = []

  # JavaScript: The Bad Parts
  endpoints = Object.keys(objects_at).map((x) -> Number(x)).sort((a,b) -> a - b)
  window.wtf = endpoints
  for [begin, end, thing] in things
    for point in endpoints
      if begin <= point < end
        objects_at[point].push(thing)
  (point) ->
    min = 0
    max = endpoints.length - 1
    while min < max
      mid = Math.ceil((min + max) / 2)
      if endpoints[mid] > point
        max = mid - 1
      else
        min = mid
    objects_at[endpoints[min]]

# Decorator that memoizes functions.
# Use it to cache the result of functions which are:
#   - pure
#   - often called with the same parameters
#   - expensive to compute
export memo_fn = (f) ->
  memo = {}
  ->
    args = JSON.stringify(Array.prototype.slice.call arguments)
    if not memo[args]?
      memo[args] = f.apply this, arguments
    memo[args]

# Decorator that memoizes a signal using a Float64Array by rounding time to the
# nearest sample.
# f: (t) -> [-1,1]
export memoize = (f) ->
  if dur(f) > 60
    f
  else
    num_samples = dur(f) * engine.sampleRate + 1
    memo = new Float64Array(num_samples)
    memo.fill(Infinity)
    res = (t) ->
      idx = Math.round(t * engine.sampleRate)
      t_real = idx / engine.sampleRate
      if memo[idx] == Infinity
        memo[idx] := f(t_real)
      memo[idx]
    res.duration = dur(f)
    res
