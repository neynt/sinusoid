# src/preamble.ls
#
# The sinusoid "standard library" of everything from oscillators and instruments
# to higher-level music theory concepts.

window.prelude = require 'prelude-ls'
require './util.ls'
require './fft.js'
window.signals = require './signals.ls'
window.dsp = require './dsp.ls'
window.instruments = require './instruments.ls'
window.music = require './music.ls'

# Helper function for putting everything in the global namespace.
# Useful for live coding or composing if you're familiar with most things
# by name already.
window.import_all = ->
  for module in [window.signals, window.dsp, window.instruments, window.music]
    for object of module
      window[object] = module[object]
