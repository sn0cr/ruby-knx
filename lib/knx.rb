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
class KNX
  require File.expand_path(File.join(File.dirname(__FILE__), "..", "vendor/EIBConnection"))
  base = File.expand_path File.dirname(__FILE__)
  require File.join(base, "knx/encode")
  require File.join(base, "knx/decode")

  module Flags
    READ = 0x00
    RESP = 0x40
    WRITE = 0x80
  end

  def initialize(path="ip:127.0.0.1")
    @knx_connection = EIBConnection.new()
    @knx_connection.EIBSocketURL(path)
  end



  def read_from(group_address)
    source = EIBAddr.new
    buffer = EIBBuffer.new
    group_address_encoded = Encode.group_address group_address
    # -1 means read failed
    _return_value = @knx_connection.EIBOpenT_Group( group_address_encoded, 0)
    if _return_value == -1
      # puts("KNX client: error setting socket mode")
      @knx_connection.EIBReset
      return [source, buffer] # if a error ocurred return empty values
    else
      # Standard data to read (in the c-examples)
      _data = [ 0,0 ]
      if @knx_connection.EIBSendAPDU([ 0,0 ]) == -1
        # puts("KNX client: error setting socket mode")
        @knx_connection.EIBReset
        return [source, buffer] # if a error ocurred return empty values
      else
        values = read_polling_loop
        @knx_connection.EIBReset
        return values
      end
    end
  end

  def write_to(group_address, value)
    group_address_encoded = Encode.group_address group_address

    return_value = if @knx_connection.EIBOpenT_Group(group_address_encoded, 1) == -1
      # puts("KNX client: error setting socket mode")
      # exit(1)
      false
    else
      data = [0, Flags::WRITE | value]
      @knx_connection.EIBSendAPDU(data)
      true
    end
    @knx_connection.EIBReset
    return_value
  end

private

  def read_polling_loop
    src = EIBAddr.new
    buf = EIBBuffer.new
    loop do
      begin
        if @knx_connection.EIB_Poll_FD() == -1
          # puts "select failed"
          break
        end
        if (len = @knx_connection.EIB_Poll_Complete) == -1
          # puts "read failed"
          break
        elsif len == 0
          # let them time to receive the message
          sleep 0.00000001
          next
        end
        len = @knx_connection.EIBGetAPDU_Src(buf, src)
        if len == -1
          # puts "read failed"
          break
        elsif len < 2
          # puts "invalid packet"
          break
        end
        # puts src.inspect
        # puts buf.inspect
        # sum of the data buffer should be != 0, if some data was captured
        break if buf.buffer.inject(:+) != 0
      rescue Errno::EAGAIN => e
        next
      end
    end
    return [src, buf]
  end
end
