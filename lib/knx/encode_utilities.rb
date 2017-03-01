# Copyright (c) 2014 - 2017 C.Wahl

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
module KNX::EncodeUtilities

  module_function

  def to_binary_string(byte, length)
    # make the byte absolute
    byte = byte.abs
    max_size_of_bits_per_length = 2**length-1
    if byte == 0 || byte > max_size_of_bits_per_length
      "#{"0"*length}"
    else
      "#{"0"*(length-(byte.to_s(2)).length)}#{byte.to_s(2)}"
    end
  end


  # from stackoverflow: http://stackoverflow.com/questions/5294955
  #        (b-a)(x - min)
  # f(x) = --------------  + a
  #           max - min
  def scale(value, opts={from: 0.0..100.0, to: 0.0..255.0})
    opts[:from] ||= 0.0..100.0
    opts[:to] ||= 0.0..255.0
    from, to = opts[:from], opts[:to]
    numerator = (to.max-to.min)*(value-from.min)
    denominator = from.max - from.min
    result = (numerator / denominator) + to.min
    if value.is_a? Integer
      result.to_i
    else
      result
    end
  end
end
