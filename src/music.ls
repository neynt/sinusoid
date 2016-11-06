# Render melody
# combines collection of [offset, signal] pairs
# to a single signal at a particular bpm
window.render_notes = (bpm, notes) ->
  notes = [[ofs * 60 / bpm, s] for [ofs, s] in notes]
  seg_find = util.segment_finder([[ofs, ofs + dur(s), [ofs, s]] for [ofs, s] in notes])
  maxtime = Math.max.apply(null, [ofs + dur(s) for [ofs, s] in notes])
  console.log(maxtime)
  (t) ->
    accum = 0.0
    for [ofs, s] in seg_find(t)
      accum += delay(ofs, s)(t)
    accum
  |> crop maxtime, _

# Converts a note from scientific pitch notation to MIDI integer
window.note = do ->
  note2semis =
    C: 0
    D: 2
    E: 4
    F: 5
    G: 7
    A: 9
    B: 11
  (name) ->
    res = note2semis[name[0]] + 12 * parseInt(name[1]) + 12
    if name.length > 2
      res += if name[2] == '#' then 1 else if name[2] == 'b' then -1 else 0
    res

# A temperament maps note index to fundamental frequency.
# e.g.
# equal temperament: 69 -> 440, 81 -> 880
window.temperament =
  equal: (note) -> 440 * Math.pow(2, (n - 69) / 12)

# A key maps note index relative to the root to an
# absolute note index.
# e.g.
# A4 major: 0 -> 69, 1 -> 71

# TODO: make this faster
mod = (n, m) -> ((n % m) + m) % m
key_from_deltas = (deltas) -> (root) -> (n) ->
  ans = root
  cur_idx = 0
  while cur_idx < n
    ans += deltas[mod(cur_idx, deltas.length)]
    cur_idx += 1
  while cur_idx > n
    cur_idx -= 1
    ans -= deltas[mod(cur_idx, deltas.length)]
  ans
window.key =
  major: key_from_deltas [2 2 1 2 2 2 1]
  natural_minor: key_from_deltas [2 1 2 2 1 2 2]

# A4: 69
window.melody = (instrument, notes) ->
  accum = 0
  res = []
  for [d, n] in notes
    res.push [accum, instrument n]
    accum += d
  res
