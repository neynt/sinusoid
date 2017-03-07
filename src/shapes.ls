# Piecewise function.
export pwf = (pieces) ->
  segments = window.util.segment_finder pieces

export bump = (amplitude, t_peak, t_end) ->
  pwf [
    * 0, t_peak, (t) -> amplitude * t / t_peak
    * t_peak, t_end, (t) -> amplitude * (1 - (t - t_peak) / t_end)
  ]
