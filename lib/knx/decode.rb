# Copyright (c) 2013 - 2014 C.Wahl

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
module KNX::Decode

  module_function

  def group_address(address)
    "#{(address >> 11) & 0xf}/#{(address >> 8) & 0x7}/#{address & 0xff}"
  end
  def physical_address(address)
    "#{(address >> 12) & 0x0f}.#{(address >> 8) & 0x0f}.#{address & 0xff}"
  end

  # return whether the bit is set or not
  def bit(data)
    if data[1]
      (data[1] & 0x01) > 0
    else
      nil
    end
  end

  def float(data)
    # lambdas
    # convert string to bit representation
    to_bit = ->(string) { string.to_i(2) }

    # shortcuts for bytes
    b1, b2 = bytes 2..3, from: data
    # correct byte 2
    # subtract byte 2 from 256 to get the positive representation of that byte if it's negative
    b2 = 256 + b2 if b2 < 0

    # convert to bit array with full byte ( 8 bits ) length
    byte_string = KNX::EncodeUtilities.to_binary_string(b1, 8) << KNX::EncodeUtilities.to_binary_string(b2, 8)

    bit_array = byte_string.split("").map(&to_bit)
    exponent = to_integer bit_array[1..4]

    # if the first bit is set and no other mantissa bits it -2048 (1 00000000000)
    # else the first bit isn't set for the mantissa
    mantissa = bit_array[5..15]

    # if all least mantissa bits are set to 0 and it's negative then it's -2048
    value = to_integer( if mantissa.reduce(&:+) == 0 && bit_array[0] == 1
          exponent = 15
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        elsif mantissa.reduce(&:+) == 11 && bit_array[0] == 1
          exponent = 15
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        else
          mantissa
        end
      )
    # value = to_integer mantissa
    # make it negative if the first bit is set
    value = - value if bit_array[0] == 1
    # float value after the equation from the standard (FloatValue = (0,01*M)*2^(E))
    (0.01*value)*2**exponent
  end

  def two_byte_int(data)
    # shortcuts for bytes
    b1, b2 = bytes 2..3, from: data

    # correct byte 2
    # subtract byte 2 from 256 to get the positive representation of that byte if it's negative
    b2 = 256 + b2 if b2 < 0

    # convert to bit array with full byte ( 8 bits ) length
    byte_string = KNX::EncodeUtilities.to_binary_string(b1, 8) << KNX::EncodeUtilities.to_binary_string(b2, 8)
     byte_string.to_i 2
  end

  def byte_int(data)
    # shortcuts for bytes
    b1 = bytes(2..2, from: data).first
    b1 = 256 + b1 if b1 < 0
    b1
  end


  private_class_method

  def bytes(range, opts={from: []})
    get_value = ->(value) { opts[:from][value] }
    range.to_a.map(&get_value)
  end

  def to_integer(bit_array)
    bit_array.join.to_i(2)
  end

end
