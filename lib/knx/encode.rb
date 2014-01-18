# Copyright (c) 2013 C.Wahl

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

module KNX::Encode
  module_function

  def group_address(group_address_string)
   if m = group_address_string.match(/(\d*)\/(\d*)\/(\d*)/)
       a, b, c = m[1].to_i, m[2].to_i, m[3].to_i
       return ((a & 0x01f) << 11) | ((b & 0x07) << 8) | ((c & 0xff))
     end
  end

  # Encode data to be written
  def write(value)
    if value.respond_to?(:unshift)
      # Prepend array with [0, 0x80]
      value.unshift([0,0x80]).flatten
    else
      [0, KNX::Flags::WRITE | value]
    end
  end
  # formate a time to be written to the knx bus
  def time(time)
    bytes = Array.new
    weekday = time.strftime("%u").to_i
    bytes[0] = weekday * 32 + time.hour
    bytes[1] = time.minute
    bytes[2] = time.second
    bytes
  end

  # formate date to be written to the knx bus
  def date(date)
    bytes = Array.new
    bytes[0] = date.day
    bytes[1] = date.month + 1
    bytes[2] = date.year - 2000
    bytes
  end

  def float(value)
    # get if value is negative
    negative_bit = negative?(value) ? (1 << 15) : 0

    # calculate mantissa
    exponent, mantissa = calculate_exponent_and_mantissa(value)
    # set to special encoding
    if negative_bit == (1<<15) && exponent == 16
      mantissa = 0
      exponent = 15
    end

    # build number
    num = negative_bit | (exponent << 11) | (mantissa.to_i & 0x07ff)

    # transform into binary string
    num_string = KNX::EncodeUtilities.to_binary_string num, 16

    # return first 8 bits and then the other 8 bits
    if num == 0xFFFF # all bits are set to 1
      [128, 0] # 1000000000000000
    else
      [num_string[0..7].to_i(2), num_string[8..15].to_i(2)]
    end
  end

  private_class_method

  def negative?(value)
    value < 0 && value != 0
  end

  def calculate_exponent_and_mantissa(value)
    #  make it all positive and calculate mantissa
    mantissa = value.abs * 100
    exponent = 0
    while (mantissa > 2047) or (mantissa < -2048)
      exponent += 1
      mantissa = mantissa.to_i >> 1
    end
    [exponent, mantissa]
  end

end
