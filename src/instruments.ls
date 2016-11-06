# Instruments are functions that take a MIDI note number and possibly other
# parameters and returns a signal that represents playing that instrument
# at a given pitch.
# Other utilities that represent domain musical knowledge go here.
# midi number to frequency
midi = (n) -> 440 * Math.pow(2, (n - 69) / 12)

# Instruments:
# midi number -> signal
blip = (base_func) -> (pitch) ->
  base_func vibrato(midi(pitch), midi(pitch+0.1), 7)
  |> envelope adsr(0.008, 1.0, 0.1, 0.3, 0.1, 0.3), _
  |> envelope tremolo(6, 0.5), _
  |> gain_db -10, _

bloop = blip sine
bleep = blip triangle
bzzp = blip square

tsch = ->
  noise()
  |> gain 0.05, _
  |> envelope adsr(0.015, 1.0, 0.15, 0.0, 0.2, 0.0), _

snare = do ->
  snare_triangle = triangle chirp_exp 195, 20, 0.2
  |> envelope adsr(0.003, 1.0, 0.04, 0.1, 0, 0.3), _
  |> gain_db -15, _

  snare_noise = noise()
  |> envelope adsr(0.01, 1.0, 0.1, 0.1, 0, 0.05), _
  |> gain_db -22, _

  memoize plus(snare_triangle, snare_noise)

bass_drum = triangle chirp_exp 80, 15, 0.2
|> envelope adsr(0.001, 1.0, 0.12, 0, 0, 0), _
|> gain_db -5, _

guitar = (note) ->
  triangle solid midi note
  |> envelope adsr(0.002, 1.0, 0.05, 0.3, 0.1, 0.3), _
  |> gain_db -5, _

exports = module.exports = {
  bloop, bleep, bzzp,
  tsch, snare, bass_drum, guitar
};
