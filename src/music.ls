# Render melody
# combines collection of [offset, signal] pairs
# to a single signal at a particular bpm
{crop, delay} = signals

render_notes = (bpm, notes) ->
  notes = [[ofs * 60 / bpm, s] for [ofs, s] in notes]
  seg_find = util.segment_finder([[ofs, ofs + dur(s), [ofs, s |> delay ofs]] for [ofs, s] in notes])
  maxtime = Math.max.apply(null, [ofs + dur(s) for [ofs, s] in notes])
  (t) ->
    accum = 0.0
    for [ofs, s] in seg_find(t)
      accum += s(t)
    accum
  |> crop maxtime

# Converts a note from scientific pitch notation to MIDI integer
note = do ->
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
temperament =
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

key =
  major: key_from_deltas [2 2 1 2 2 2 1]
  natural_minor: key_from_deltas [2 1 2 2 1 2 2]
  harmonic_minor: key_from_deltas [2 1 2 2 1 3 1]
  phrygian_dominant: key_from_deltas [1 3 1 2 1 2 2]
  hungarian_minor: key_from_deltas [2 1 3 1 1 3 1]
  major_pentatonic: key_from_deltas [2 2 3 3 2]
  minor_pentatonic: key_from_deltas [3 2 2 2 3]

# A chord is a function from relative index to
# note in the chord.
# e.g. chord c4 'i'
#   0 -> 60
#   1 -> 

chord_deltas =
  major_triad: [4 3 5]  # III
  minor_triad: [3 4 5]  # iii
  diminished_triad: [3 3 6]  # iiio
  augmented_triad: [4 4 4]  # III+

chord = (root, name) ->
  lower_name = name.toLowerCase()
  if chord_deltas[name]?
    (key_from_deltas chord_deltas[name]) root

diatonic_chords =
  major: <[ I ii iii IV V vi viio ]>
  natural_minor: <[ i iio III iv v VI VII ]>

differences = (a) ->
  for i from 1 til a.length
    a[i] - a[i - 1]

prefix_sums = (a) ->
  res = [0]
  for i from 0 til a.length
    res.push a[i] + res[-1 til][0]
  res

roman_chord = window.rc = do ->
  roman_chord_regex = /^(i|ii|iii|iv|v|vi|vii)([67]?)([+o]?)$/i
  roman_numerals =
    i: 1
    ii: 2
    iii: 3
    iv: 4
    v: 5
    vi: 6
    vii: 7
  from_roman = (roman) ->
    roman_numerals[roman.toLowerCase()]

  (key, name) ->
    groups = roman_chord_regex.exec(name)
    root = (from_roman groups.1) - 1

    var quality, diminished, augmented, seventh
    base_name = groups.1

    if base_name == base_name.toLowerCase()
      quality = \minor
    else
      quality = \major

    for group in groups[2 til]
      match group
      | 'o' => diminished = true
      | '+' => augmented = true
      | '7' => seventh = true

    deltas = match augmented, diminished, quality
    | true, _, _ => chord_deltas.augmented_triad
    | _, true, _ => chord_deltas.diminished_triad
    | _, _, \major => chord_deltas.major_triad
    | _, _, \minor => chord_deltas.minor_triad

    offsets = prefix_sums deltas
    deltas = differences offsets

    (key_from_deltas deltas) (key root)

diatonic_triad = (key, root) ->
  arr = [
    key root
    key root + 2
    key root + 4
    key root + 7
  ]
  deltas = differences arr
  # TODO: detect the actual chord quality
  # and display it somehow?
  (key_from_deltas deltas) (key root)

# A4: 69
melody = (instrument, notes) ->
  accum = 0
  res = []
  for [d, n] in notes
    res.push [accum, instrument n]
    accum += d
  res

drum_machine = (subdiv, beatline, mapping) ->
  res = []
  for c, i in beatline
    if mapping[c]?
      res.push [i * subdiv, mapping[c]]
  res

exports = module.exports = {
  render_notes, note,
  key, key_from_deltas, temperament,
  diatonic_chords,
  chord, roman_chord, diatonic_triad,
  drum_machine
};
