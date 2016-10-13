# Melody
# combines collection of (offset, signal) pairs
# to a single signal
window.melody = (bpm, notes) ->
  notes = [[ofs * 60 / bpm, s] for [ofs, s] in notes]
  seg_find = util.segment_finder([[ofs, ofs + dur(s), [ofs, s]] for [ofs, s] in notes])
  maxtime = Math.max.apply(null, [ofs + dur(s) for [ofs, s] in notes])
  console.log(maxtime)
  crop(
    (t) ->
      accum = 0.0
      for [ofs, s] in seg_find(t)
        accum += delay(s, ofs)(t)
      accum
    maxtime)
