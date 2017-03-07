# src/preamble.ls
#
# The sinusoid "standard library".

window.prelude = require 'prelude-ls'
window.util = require './util.ls'
#window.fft = require './fft-ls.ls'
window.fft = require './fft.js'
window.shapes = require './shapes.ls'
window.signals = require './signals.ls'
window.dsp = require './dsp.ls'
window.instruments = require './instruments.ls'
window.music = require './music.ls'

# Helper function for putting everything in the global namespace.
# Useful for live coding or composing if you're familiar with most things
# by name already.
window.import_all = ->
  for module in [
    window.util,
    window.shapes,
    window.signals,
    window.dsp,
    window.instruments,
    window.music]
    for object of module
      window[object] = module[object]
