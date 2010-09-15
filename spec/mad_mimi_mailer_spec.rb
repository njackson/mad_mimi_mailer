require 'spec_helper'

describe MadMimiMailer do
  it "inherits from ActionMailer::Base" do
    MadMimiMailer.superclass.should == ActionMailer::Base
  end
  it "uses :madmimi for the delivery_method" do
    MadMimiMailer.delivery_method.should == :madmimi
  end
end
