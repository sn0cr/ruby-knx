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
      puts data_true.length
      expect(KNX::Decode.bit(data_true)).to eql( true)
      expect(KNX::Decode.bit(data_false)).to eql false
      expect(KNX::Decode.bit(data_empty)).to eql nil
    end
  end
end

