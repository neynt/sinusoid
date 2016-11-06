# Sinusoid

A sound is just a function from time to [-1, 1].

Sinusoid is an expressive framework to write these functions.

## Notes

We currently use `|> gain(0.5, _)` instead of currying `gain` and using `|> gain 0.5` because currying in LiveScript is slow.
