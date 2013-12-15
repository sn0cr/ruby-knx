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

require File.dirname(__FILE__) + '/spec_helper'

describe KNX do
  describe "Constants should match" do
    it "Read flag should be 0" do
      expect(KNX::Flags::READ).to eql(0)
    end
    it "Response flag should be 0x40" do
      expect(KNX::Flags::RESP).to eql(0x40)
    end

    it "Write flag should be 0x80" do
      expect(KNX::Flags::WRITE).to eql(0x80)
    end
  end

  before(:each) do
    [:EIBSocketURL, :EIBOpenT_Group,:EIBSendAPDU,:EIBSocketURL].map do |method|
      EIBConnection.any_instance.stub(method).and_return 0
    end
    [:EIB_Poll_FD,:EIB_Poll_Complete, :EIBGetAPDU_Src].map do |method|
      EIBConnection.any_instance.stub(method).and_return -1
    end
  end
  describe "#new" do
    it "should create a connection to eibd" do
      path = "ip:127.0.0.1"
      EIBConnection.any_instance.should_receive(:EIBSocketURL).with(path)
      KNX.new path
    end
  end

  let(:group_address) { "1/1/1" }
  let(:encoded_group_address) { 0x901 }

  describe "#read_from" do
    let(:knx) { KNX.new }

    it "should encode group address" do
      expect(KNX::Encode).to receive(:group_address).with(group_address).and_return(encoded_group_address)
      knx.read_from(group_address)
    end

    it "should open a connection to the groupaddress" do
      EIBConnection.any_instance.should_receive(:EIBOpenT_Group).with(encoded_group_address, 0)
      knx.read_from group_address
    end

    it "should send [0,0] as data " do
      EIBConnection.any_instance.should_receive(:EIBSendAPDU).with([0,0])
      knx.read_from group_address
    end
    it "should reset the connection " do
      EIBConnection.any_instance.should_receive(:EIBReset)
      knx.read_from group_address
    end

    it "returns empty values if a error occurs" do
      pending "think about a solution"
      EIBConnection.any_instance.stub(:EIBSendAPDU).and_return -1
      expect(knx.read_from(group_address)).to eql([])
      EIBConnection.any_instance.stub(:EIBOpenT_Group).and_return -1
    end
  end

  describe "#write_to" do
    let(:knx) { KNX.new }
    let(:value) { 0 }
    it "should encode group address" do
      expect(KNX::Encode).to receive(:group_address).with(group_address).and_return(encoded_group_address)
      knx.write_to(group_address, value)
    end
    it "should open a connection to the groupaddress" do
      EIBConnection.any_instance.should_receive(:EIBOpenT_Group).with(encoded_group_address, 1)
      knx.write_to(group_address, value)
    end
    it "should reset the connection " do
      EIBConnection.any_instance.should_receive(:EIBReset)
      knx.write_to(group_address, value)
    end
    it "should send [0, Flags::WRITE | 0] as data " do
      EIBConnection.any_instance.should_receive(:EIBSendAPDU).with([0, 128])
      knx.write_to(group_address, value)
    end
  end

end
