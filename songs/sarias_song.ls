bpm = 280

measure1 = memoize render_notes(bpm, [
  [0, bloop 77]
  [1, bloop 81]
  [2, bloop 83]
])

sch = tsch() |> gain(0.3, _)
drums = memoize render_notes(bpm, [
  [0.0, sch]
  [1.0, sch]
  [1.5, sch]
  [2.0, sch]
  [3.0, sch]
])

drumline = memoize render_notes(bpm, [
  [0, drums]
  [4, drums]
  [8, drums]
  [12, drums]
  [16, drums]
  [20, drums]
  [24, drums]
  [28, drums]
])

ocarina = memoize render_notes(bpm, [
  [0, measure1]
  [4, measure1]
  [8, measure1]
  [11, bloop 88]
  [12, bloop 86]

  [14, bloop 83]
  [15, bloop 84]
  [16, bloop 83]
  [17, bloop 79]
  [18, bloop 76]

  [23, bloop 74]
  [24, bloop 76]
  [25, bloop 79]
  [26, bloop 76]

  [32, measure1]
  [36, measure1]
  [40, measure1]
  [43, bloop 88]
  [44, bloop 86]

  [46, bloop 83]
  [47, bloop 84]
  [48, bloop 88]
  [49, bloop 84]
  [50, bloop 79]

  [55, bloop 83]
  [56, bloop 79]
  [57, bloop 74]
  [58, bloop 76]
])

return memoize render_notes(bpm, [
  [0, drumline]
  [32, drumline]
  [0, ocarina]
])
