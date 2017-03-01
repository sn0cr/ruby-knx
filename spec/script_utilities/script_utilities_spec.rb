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

require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/script_utilities/script_utilities'

describe KNX::ScriptUtilities do
  let(:base_path) { File.expand_path(File.join(File.dirname(__FILE__), "../.." )) }

  describe "#knx_base" do
    it "should return the base path" do
      expect(KNX::ScriptUtilities.knx_base).to eql(base_path)
    end
  end

  describe "#require_relative" do
    it "should call Kernel#require with 'base_path/class_name'" do
      KNX::ScriptUtilities.stub(:require)
      KNX::ScriptUtilities.should_receive(:require).with File.join base_path, "class_name"
      KNX::ScriptUtilities.require_relative_to_base "class_name"
    end
  end

  describe "#read_yaml" do
    before do
      KNX::ScriptUtilities.instance_eval do
        module KNX::ScriptUtilities::YAML
          module_function
            def load_file(path)
            end
        end
      end
    end
    it "should call Kernel#require with 'yaml'" do
      KNX::ScriptUtilities.stub(:require)
      KNX::ScriptUtilities.should_receive(:require).with "yaml"
      KNX::ScriptUtilities.read_yaml "file"
    end
    it "should call load_file on YAML" do
      KNX::ScriptUtilities::YAML.stub(:load_file)
      KNX::ScriptUtilities::YAML.should_receive(:load_file).with "file"
      KNX::ScriptUtilities.read_yaml "file"
    end
  end

  describe "#relative_to_base" do
    it "should should return base/file" do
      expect(KNX::ScriptUtilities.relative_to_base("file")).to eql(File.join base_path, "file")
    end
  end
end
