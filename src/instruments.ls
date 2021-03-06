# Instruments are functions that take a MIDI note number and possibly other
# parameters and returns a signal that represents playing that instrument
# at a given pitch.
# i.e.
# Instrument :: (MidiNumber, ...?) => Signal

{memoize} = util
{sine, triangle, saw, square, noise, plus} = signals
{envelope, solid, vibrato, chirp_exp, adsr, tremolo, gain_db} = signals

# Other utilities that represent domain musical knowledge go here.
# midi number to frequency
export midi = (n) -> 440 * Math.pow(2, (n - 69) / 12)

# Instruments:
# midi number -> signal
export blip = (base_func) -> (pitch, duration = 0.1) ->
  base_func vibrato (midi pitch), (midi pitch + 0.1), 7
  |> envelope adsr(0.008, 1.0, 0.1, 0.3, duration, 0.3)
  #|> envelope tremolo(6, 0.5)
  |> gain_db -10

export bloop = blip sine
export bleep = blip triangle
export bliip = blip saw
export bzzp = blip square

export tsch = ->
  noise()
  |> gain 0.05
  |> envelope adsr 0.015, 1.0, 0.15, 0.0, 0.2, 0.0

export snare = do ->
  snare_triangle = triangle chirp_exp 195, 20, 0.2
  |> envelope adsr 0.003, 1.0, 0.04, 0.1, 0, 0.3
  |> gain_db -15

  snare_noise = noise()
  |> envelope adsr 0.01, 1.0, 0.1, 0.1, 0, 0.05
  |> gain_db -22

  memoize plus snare_triangle, snare_noise

export kick = triangle chirp_exp 80, 15, 0.2
|> envelope adsr 0.001, 1.0, 0.12, 0, 0, 0
|> gain_db -5

export guitar = (note) ->
  triangle solid midi note
  |> envelope adsr 0.002, 1.0, 0.05, 0.3, 0.1, 0.3
  |> gain_db -5
