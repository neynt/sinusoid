# Signals

A signal is a function that takes time (in seconds) and returns a number between -1 and 1.

The end goal of our code is to produce a signal representing the sound we want. Eventually, we will be able to write signals that sound like drums, trumpets, and violins, but it all starts with the sine wave.

## Sine waves

The sine wave is a fundamental signal. It sounds like a pure tone. You might write one like this.

```ls
return (t) -> Math.sin 2 * Math.PI * 440 * t
```

^ This sine wave has a frequency of 440 Hz, meaning the air pressure waves beat our eardrums 440 times per second and we hear a pitch of A4.

What if we want a higher pitch? We need to increase the frequency.

```ls
return (t) -> Math.sin 2 * Math.PI * 660 * t
```

^ This sine wave has a frequency of 660 Hz and a pitch of E5, a perfect fifth above the previous sine wave.

In general, we might want a sine wave of any frequency. We can create a function that returns signals.

```ls
sine_wave = (freq) -> (t) -> Math.sin 2 * Math.PI * freq * t
return sine_wave 440
```

## Noise

This is white noise, a signal that has an equal amount of all frequencies.

```ls
(t) -> Math.random! * 2 - 1
```
