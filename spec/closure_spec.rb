require File.dirname(__FILE__) + '/spec_helper'

describe Closure do
  it "should bind params 1, 2 => a, b" do
    Closure.new(nil, [Param.new(:a, nil, false), Param.new(:b, nil, false)]).
      bind_params([1, 2]).
      should == { :a => 1, :b => 2 }
  end

  it "should bind params 1 => a, b" do
    Closure.new(nil, [Param.new(:a, nil, false), Param.new(:b, nil, false)]).
      bind_params([1]).
      should == { :a => 1, :b => nil }
  end

  it "should bind params 1 => a, b=2" do
    Closure.new(nil, [Param.new(:a, nil, false), Param.new(:b, 2, false)]).
      bind_params([1]).
      should == { :a => 1, :b => 2 }
  end

  it "should bind params 1, 2 => *a" do
    Closure.new(nil, [Param.new(:a, nil, true)]).
      bind_params([1, 2]).
      should == { :a => Min::Array.new([1, 2]) }
  end
end