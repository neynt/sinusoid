# LiveScript implementation of Fast Fourier Transform.
# Adopted from JavaScript implementation by Nayuki.
#
# Copyright (c) 2014 Project Nayuki
# https://www.nayuki.io/page/free-small-fft-in-multiple-languages
#
# (MIT License)
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# - The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
# - The Software is provided "as is", without warranty of any kind, express or
#   implied, including but not limited to the warranties of merchantability,
#   fitness for a particular purpose and noninfringement. In no event shall the
#   authors or copyright holders be liable for any claim, damages or other
#   liability, whether in an action of contract, tort or otherwise, arising from,
#   out of or in connection with the Software or the use or other dealings in the
#   Software.

reverseBits = (x, bits) ->
  y = 0
  for i from 0 til bits
    y = (y .<<. 1) .|. (x .&. 1)
    x .>>>.= 1
  y

transform = (real, imag) ->
  if real.length != imag.length
    throw "Mismatched lengths 1 #{real.length}, #{imag.length}"
  n = real.length
  if (n .&. (n - 1)) == 0  # n power of 2
    transformRadix2 real, imag

inverseTransform = (real, imag) ->
  transform imag, real

transformRadix2 = (real, imag) ->
  if real.length != imag.length
    throw "Mismatched lengths 2"
  n = real.length
  if n == 1
    return

  levels = -1

  # levels = log2(n)
  for i from 0 til 32
    if 1 .<<. i == n
      levels = i

  if levels == -1
    throw "Length not a power of 2"

  cosTable = new Float64Array n / 2
  sinTable = new Float64Array n / 2
  for i from 0 til n / 2
    cosTable[i] = Math.cos 2 * Math.PI * i / n
    sinTable[i] = Math.sin 2 * Math.PI * i / n

  # wtf? OOH I UNDERSTAND NOW
  for i from 0 til n
    j = reverseBits i, levels
    if j > i
      temp = real[i]
      real[i] = real[j]
      real[j] = temp
      temp = imag[i]
      imag[i] = imag[j]
      imag[j] = temp

  size = 2
  while size <= n, size *= 2
    halfsize = size / 2
    tablestep = n / size
    for i from 0 til n by size
      k = 0
      for j from i til i + halfsize
        J = j + halfsize
        tpre =  real[J] * cosTable[k] + imag[J] * sinTable[k]
        tpim = -real[J] * sinTable[k] + imag[J] * cosTable[k]
        real[J] = real[j] - tpre
        imag[J] = imag[j] - tpim
        real[j] += tpre
        imag[j] += tpim
        k += tablestep

export fft = (real, imag) ->
  if (n .&. (n - 1)) != 0
    throw "Length not a power of 2"
  transformRadix2(real, imag)
  console.log "using ls-FFT!"

export ifft = (real, imag) ->
  transform imag, real
  for i from 0 til n
    real /= n
    imag /= n

export convolveReal = (x, y, out) ->
  if x.length != y.length || x.length != out.length
    throw "Mismatched lengths 3"
  zeros = new Array x.length
  zeros.fill 0
  convolveComplex x, zeros, y, zeros.slice!, out, zeros.slice!

export convolveComplex = (xr, xi, yr, yi, outr, outi) ->
  if (xr.length != xi.length ||
      xr.length != yr.length ||
      xr.length != yi.length ||
      xr.length != outr.length ||
      xr.length != outi.length)
    throw "Mismatched lengths 4"

  n = xr.length
  xr = xr.slice!
  xi = xi.slice!
  yr = yr.slice!
  yi = yi.slice!

  transform xr, xi
  transform yr, yi

  for i from 0 til n
    temp = xr[i] * yr[i] - xi[i] * yi[i]
    xi[i] = xi[i] * yr[i] + xr[i] * yi[i]
    xr[i] = temp

  inverseTransform xr, xi

  for i from 0 til n
    outr[i] = xr[i] / n
    outi[i] = xi[i] / n
