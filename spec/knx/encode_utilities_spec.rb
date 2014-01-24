# Copyright (c) 2014 C.Wahl

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

describe KNX::EncodeUtilities do
  describe "#to_binary_string" do
    it "encodes a number as bit string" do
      expect(KNX::EncodeUtilities.to_binary_string(0, 8)).to eql("0"*8)
      expect(KNX::EncodeUtilities.to_binary_string(255, 8)).to eql(255.to_s(2))
      expect(KNX::EncodeUtilities.to_binary_string(65535, 16)).to eql(65535.to_s(2))
    end
    it "returns 0's if the value is to big to fit into the given length" do
      expect(KNX::EncodeUtilities.to_binary_string(256, 8)).to eql("0"*8)
      expect(KNX::EncodeUtilities.to_binary_string(65536, 16)).to eql("0"*16)
    end
    it "encodes a negative number as positive bit string" do
      expect(KNX::EncodeUtilities.to_binary_string(0, 8)).to eql("0"*8)
      expect(KNX::EncodeUtilities.to_binary_string(-255, 8)).to eql(255.to_s(2))
      expect(KNX::EncodeUtilities.to_binary_string(-100, 7)).to eql(100.to_s(2))
    end
  end
  describe "#scale" do
    it "scales without value from 0..100 to 0..255" do
      expect(KNX::EncodeUtilities.scale(0)).to eql(0)
      expect(KNX::EncodeUtilities.scale(100)).to eql(255)
      expect(KNX::EncodeUtilities.scale(50.0)).to eql(127.5)
    end
    it "should return integer if input was integer" do
      expect(KNX::EncodeUtilities.scale(0)).to eql(0)
      expect(KNX::EncodeUtilities.scale(100)).to eql(255)
      expect(KNX::EncodeUtilities.scale(50)).to eql(127)
    end
    it "should scale in different ranges" do
      expect(KNX::EncodeUtilities.scale(1, from: 0..10)).to eql(25)
      expect(KNX::EncodeUtilities.scale(1.0, from: 0..1000)).to eql(0.255)
      expect(KNX::EncodeUtilities.scale(10, to: 0..1000)).to eql(100)
      expect(KNX::EncodeUtilities.scale(10.0, to: 0..1000)).to eql(100.0)

      expect(KNX::EncodeUtilities.scale(1, to: 0..1000, from: 0..10)).to eql(100)
      expect(KNX::EncodeUtilities.scale(1.0, to: 0..1000,from: 0..1000)).to eql(1.0)
      expect(KNX::EncodeUtilities.scale(1, to: 0..1000,from: 0..1000)).to eql(1)

  end
end
