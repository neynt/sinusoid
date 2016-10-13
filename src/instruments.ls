# Instruments are functions that take a MIDI note number and possibly other
# parameters and returns a signal that represents playing that instrument
# at a given pitch.
# Other utilities that represent domain musical knowledge go here.
# midi number to frequency
window.midi = (n) -> 440 * Math.pow(2, (n - 69) / 12)

# Instruments:
# midi number -> signal
window.bleep = (pitch) ->
  envelope(
    envelope(
      gain(
        sine_vibrato(midi(pitch), midi(pitch+0.02), 7)
        0.1)
      adsr(0.015, 1.0, 0.1, 0.3, 0.1, 0.2))
    sine(6))

window.tsch = ->
  envelope(
    gain(noise(), 0.05)
    adsr(0.015, 1.0, 0.15, 0.0, 0.2, 0.0))
