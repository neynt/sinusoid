# Sinusoid

Any sound can be expressed as a function from time to [-1, 1].

Sinusoid is an expressive framework to write these functions.

## File overview

- `index.ls`: The entry point for the web app.
- `worker.ls`: The entry point for the worker, which executes user code in the background.
- `src/engine.ls`: Interfaces with Web Audio API and worker
- `src/signals.ls`: Raw waveforms and basic operations such as adding, cropping, delaying
- `src/instruments.ls`: Some basic fully-synthesized instruments
- `src/util.ls`: Mainly data structures for performance
- `src/music.ls`: Higher-level abstractions from music theory
- `src/fft.js`: Fast fourier transform, basically copied from Nayuki
- `src/dsp.ls`: Convolution, digital filters
- `src/gui_components/*`: React components

## Notes

Currying with `-->` in LiveScript is slow. Therefore, functions like `gain_db` must be called like `gain_db(-10)(orig_signal)`. Better yet, use the pipe operator: `orig_signal |> gain_db -10`.
