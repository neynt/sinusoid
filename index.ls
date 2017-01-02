# index.ls
#
# File that is loaded in the main browser tab. Handles UI.
#
# Also exposes the preamble, which will eventually be used
# to provide discoverability features like autocomplete.
#
# See also: worker.ls

require 'codemirror/mode/css/css'
require './src/engine.ls'
require './src/gui.jsx'
require './src/preamble.ls'
