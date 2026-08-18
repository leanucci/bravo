require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Authorizer" do
  it "should read credentials on initialize" do
    Bravo.pkey = '/path/to/pkey'
    Bravo.cert = '/path/to/cert'

    authorizer = Bravo::Authorizer.new

    authorizer.pkey.should == '/path/to/pkey'
    authorizer.cert.should == '/path/to/cert'
  end
end
