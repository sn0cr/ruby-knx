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

class KNX::Encode
  def self.group_address(group_address_string)
   if m = group_address_string.match(/(\d*)\/(\d*)\/(\d*)/)
       a, b, c = m[1].to_i, m[2].to_i, m[3].to_i
       return ((a & 0x01f) << 11) | ((b & 0x07) << 8) | ((c & 0xff))
     end
  end

  # Encode data to be written
  def self.write(value)
    if value.respond_to?(:unshift)
      value.unshift([0,0x80]).flatten
    else
      [0, KNX::Flags::WRITE | value]
    end
  end
  # formate a time to be written to the knx bus
  def self.time(time)
    bytes = Array.new
    weekday = time.strftime("%u").to_i
    bytes[0] = weekday * 32 + time.hour
    bytes[1] = time.minute
    bytes[2] = time.second
    bytes
  end

  # formate date to be written to the knx bus
  def self.date(date)
    bytes = Array.new
    bytes[0] = date.day
    bytes[1] = date.month + 1
    bytes[2] = date.year - 2000
    bytes
  end
end