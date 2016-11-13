# Sinusoid

A sound is just a function from time to [-1, 1].

Sinusoid is an expressive framework to write these functions.

## Notes

Currying with `-->` in LiveScript is slow. Therefore, functions like `gain_db` must be called like `gain_db(-10)(orig_signal)`. Better yet, use the pipe operator `|>`: `orig_signal |> gain_db -10`.
