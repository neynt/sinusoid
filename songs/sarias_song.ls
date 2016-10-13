bpm = 280

measure1 = memoize melody(bpm, [
  [0, bleep 77]
  [1, bleep 81]
  [2, bleep 83]
])

drums = melody(bpm, [
  [0.0, tsch()]
  [1.0, tsch()]
  [1.5, tsch()]
  [2.0, tsch()]
  [3.0, tsch()]
])

drumline = melody(bpm, [
  [0, drums]
  [4, drums]
  [8, drums]
  [12, drums]
  [16, drums]
  [20, drums]
  [24, drums]
  [28, drums]
])

window.sarias_song = memoize melody(bpm, [
  [0, drumline]
  [32, drumline]

  [0, measure1]
  [4, measure1]
  [8, measure1]
  [11, bleep 88]
  [12, bleep 86]

  [14, bleep 83]
  [15, bleep 84]
  [16, bleep 83]
  [17, bleep 79]
  [18, bleep 76]

  [23, bleep 74]
  [24, bleep 76]
  [25, bleep 79]
  [26, bleep 76]

  [32, measure1]
  [36, measure1]
  [40, measure1]
  [43, bleep 88]
  [44, bleep 86]

  [46, bleep 83]
  [47, bleep 84]
  [48, bleep 88]
  [49, bleep 84]
  [50, bleep 79]

  [55, bleep 83]
  [56, bleep 79]
  [57, bleep 74]
  [58, bleep 76]
])
