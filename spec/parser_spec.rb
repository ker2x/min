require File.dirname(__FILE__) + "/spec_helper"

describe Min::Parser do
  N = Min::Nodes
  
  before do
    @parser = Min::Parser.new
  end
  
  def self.it_should_parse(code, options)
    it "should parse #{code}" do
      @parser.parse(code).nodes.should == options[:as]
    end
  end
  
  # Literals
  it_should_parse %{1}, :as => [N::Number.new(1)]
  it_should_parse %{"ohaie"}, :as => [N::String.new("ohaie")]
  it_should_parse %{true}, :as => [N::True.new("true")]
  
  # Assign
  it_should_parse %{x = 1}, :as => [N::Assign.new("x", N::Number.new(1))]
  
  # Call
  it_should_parse %{x}, :as => [N::Call.new("x", [], nil)]
  it_should_parse %{x()}, :as => [N::Call.new("x", [], nil)]
  it_should_parse %{x 1}, :as => [N::Call.new("x", [N::Number.new(1)], nil)]
  it_should_parse %{x(1)}, :as => [N::Call.new("x", [N::Number.new(1)], nil)]
  it_should_parse %{x(1, "1")}, :as => [N::Call.new("x", [N::Number.new(1), N::String.new("1")], nil)]
  it_should_parse %{x 1, "1"}, :as => [N::Call.new("x", [N::Number.new(1), N::String.new("1")], nil)]
end