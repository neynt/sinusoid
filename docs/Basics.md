# Basics

Note: All code in this documentation will be in [LiveScript](http://livescript.net/), a language that compiles to JavaScript and has many nice features for functional programming. Sinusoid currently supports LiveScript and JavaScript, but it can be extended to support any language that compiles to JavaScript.

## The user interface

- The **side bar** has various links.
- The **language dropdown** lets you choose your coding language.
- The **play button** runs your code and plays it to the speakers.
- The **text area** is where you write your code.
- Two **visualizations** are initally shown as black bars at the top -- the top shows the shape of the waveform, and the bottom shows the frequency spectrum.

## Motivating example

This plays a sine wave at 440 Hz (A4).

```ls
return (t) -> Math.sin 2 * Math.PI * 440 * t
```

To run this, copy/paste the code into Sinusoid and press the Play button or hit Ctrl+Enter.

## Concepts

A **signal** is a function from time (in seconds) to a number between -1 and 1.
