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

require File.dirname(__FILE__) + '/../spec_helper'
describe KNX::Decode do
  describe "#group_address" do
    it "should decode a physical address properly" do
      expect(KNX::Decode.physical_address(4358)).to eql("1.1.6")
      expect(KNX::Decode.physical_address(7990)).to eql("1.15.54")
      expect(KNX::Decode.physical_address(-1)).to eql("15.15.255")
    end
    it "should decode a groupaddress properly" do
      expect(KNX::Decode.group_address(4358)).to eql("2/1/6")
      expect(KNX::Decode.group_address(4409)).to eql("2/1/57")
    end
  end

  describe "#bit" do
    let(:data_true) { [ 0 , 65 ] }
    let(:data_false) { [ 0 , 64 ] }
    let(:data_empty) { [ 0 ] }


    it "should decode a bit properly" do
      expect(KNX::Decode.bit(data_true)).to eql( true)
      expect(KNX::Decode.bit(data_false)).to eql false
      expect(KNX::Decode.bit(data_empty)).to eql nil
    end
  end

  describe "#float" do
    to_bit = ->(val) {val.to_i(2)}
    let(:high_max) { 670760.96 }
    let(:low_max) { -671088.64 }
    let(:zero) { 0 }

    def create_data_array(bit_string)
      b1 = bit_string [0..7]
      b2 = bit_string [8..15]
      [0,0, b1.to_i(2), b2.to_i(2)]
    end

    let(:data_high_max) do
      create_data_array "0111111111111111"
    end

    let(:data_low_max) do
      create_data_array "1111100000000000"
    end

    let(:data_all_bytes) do
      create_data_array "1111111111111111"
    end

    it "decodes float properly" do
      decode = -> (value) { KNX::Decode.float( value)}
      expect(decode.call(data_high_max)).to eql(high_max)
      expect(decode.call(data_low_max)).to eql(low_max)
      expect(decode.call(data_all_bytes)).to eql(low_max)
    end
  end

  describe "#two_byte_int" do
    let(:high_max) { 65535 }
    let(:low_max) { 0 }

    let(:data_high_max) do
      [0,0, 255, 255]
    end

    let(:data_low_max) do
      [0,0,0,0]
    end

    it "decodes a 2 byte integer properly" do
      expect(KNX::Decode.two_byte_int(data_high_max)).to eql(high_max)
      expect(KNX::Decode.two_byte_int(data_low_max)).to eql(low_max)
    end
  end

  describe "#byte_int" do
    let(:high_max) { 255 }
    let(:low_max) { 0 }

    let(:data_high_max) do
      [0,0,255]
    end

    let(:data_low_max) do
      [0,0,0]
    end

    let(:data_high_invalid_max) do
      [0,0,-1]
    end
    it "decodes a byte integer properly" do
      expect(KNX::Decode.byte_int(data_high_max)).to eql(high_max)
      expect(KNX::Decode.byte_int(data_low_max)).to eql(low_max)
      expect(KNX::Decode.byte_int(data_high_invalid_max)).to eql(high_max)
    end
  end
end

