# coding: utf-8
#
require 'spec_helper'

describe 'Query::Combinations' do

  before(:each) do
    @combinations_ary = stub :combinations_ary
    
    type = stub :type, :result_type => :some_type
    
    @combinations = Query::Combinations.new type, @combinations_ary
  end
  
  describe "pack_into_allocation" do
    it "return an Allocation" do
      @combinations.pack_into_allocation.should be_kind_of(Query::Allocation)
    end
    it "returns an Allocation with specific result_type" do
      @combinations.pack_into_allocation.result_type.should == :some_type
    end
  end
  
  describe "to_result" do
    before(:each) do
      @combination1 = stub :combination1, :to_result => :result1
      @combination2 = stub :combination2, :to_result => :result2
      
      @combinations_ary = [@combination1, @combination2]
      
      @combinations = Query::Combinations.new :some_type, @combinations_ary
    end
    it "resultifies the combinations" do
      @combinations.to_result.should == [:result1, :result2]
    end
  end
  
  describe "add_score" do
    it "uses the weights' score method" do
      weights = stub :weights
      weights.should_receive(:score).once.with @combinations_ary
      
      @combinations.add_score weights
    end
  end
  
  describe "sum_score" do
    before(:each) do
      @combination1 = stub :combination1, :weight => 3.14
      @combination2 = stub :combination2, :weight => 2.76
      
      @combinations_ary = [@combination1, @combination2]
      
      @combinations = Query::Combinations.new :some_type, @combinations_ary
    end
    it "sums the scores" do
      @combinations.sum_score.should == 5.90
    end
  end
  
  describe "calculate_score" do
    before(:each) do
      @combinations.stub! :sum_score => 0
      @combinations.stub! :add_score => 0
    end
    it "first sums, then weighs" do
      @combinations.should_receive(:sum_score).once.ordered.and_return 0
      @combinations.should_receive(:add_score).once.ordered.and_return 0
      
      @combinations.calculate_score :anything
    end
    it "calls sum_score" do
      @combinations.should_receive(:sum_score).once.with.and_return 0
      
      @combinations.calculate_score :anything
    end
    it "calls sum_score" do
      @combinations.should_receive(:add_score).once.with(:weights).and_return 0
      
      @combinations.calculate_score :weights
    end
  end
  
  describe 'hash' do
    it "delegates to the combinations array" do
      @combinations_ary.should_receive(:hash).once.with
      
      @combinations.hash
    end
  end
  
  describe 'remove' do
    before(:each) do
      @combination1 = stub :combination1, :in? => false
      @combination2 = stub :combination2, :in? => true
      @combination3 = stub :combination3, :in? => true

      @combinations = Query::Combinations.new :some_type, [@combination1, @combination2, @combination3]
    end
    it 'should remove the combinations' do
      @combinations.remove([:any]).should == [@combination1]
    end
  end

  describe 'keep' do
    before(:each) do
      @combination1 = stub :combination1, :in? => false
      @combination2 = stub :combination2, :in? => true
      @combination3 = stub :combination3, :in? => true

      @combinations = Query::Combinations.new :some_type, [@combination1, @combination2, @combination3]
    end
    it 'should filter the combinations' do
      @combinations.keep([:any]).should == [@combination2, @combination3]
    end
  end

  describe "ids" do
    before(:each) do
      @combination1 = stub :combination1
      @combination2 = stub :combination2
      @combination3 = stub :combination3
      @combinations = Query::Combinations.new :some_type, [@combination1, @combination2, @combination3]
    end
    it "should intersect correctly" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      @combinations.ids.should == (1..10).to_a
    end
    it "should intersect correctly when intermediate intersect result is empty" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (11..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      @combinations.ids.should == []
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @combinations.ids }.should < 0.004
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @combinations.ids }.should < 0.00015
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
      @combination2.should_receive(:ids).once.with.and_return (901..1000).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @combinations.ids }.should < 0.0001
    end
  end

end