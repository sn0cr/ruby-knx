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
require "date"
require File.dirname(__FILE__) + '/../spec_helper'
describe KNX::Encode do
  describe "#group_address" do
    it "should encode a groupaddress properly" do
      expect(KNX::Encode.group_address("1/1/1")).to eql(0x901)
      expect(KNX::Encode.group_address("4/4/8")).to eql(0x2408)
    end
  end
  describe "#write" do
    it "should binary-or the value with 0x80 (KNX::Flags::WRITE) if its a bit" do
      expect(KNX::Encode.write(1)).to eql([0, 129])
      expect(KNX::Encode.write(0)).to eql([0, 128])
    end
    it "should prepend the data with [0, 0x80] if its a byte" do
      expect(KNX::Encode.write([1])).to eql([0, 128, 1])
    end
  end

  describe "#time" do
    let(:time) { DateTime.parse(Time.now.to_s) }
    it "should encode a time object properly" do
      expect(KNX::Encode.time(time)).to eql([(time.strftime("%u").to_i)* 32 +
        time.hour, time.minute, time.second])
    end
  end
  describe "#date" do
    let(:date) { DateTime.parse(Time.now.to_s) }
    it "should encode a time object properly" do
      expect(KNX::Encode.date(date)).to eql([date.day, (date.month + 1), (date.year - 2000)])
    end
  end
end
