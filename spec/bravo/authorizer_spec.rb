require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Authorizer" do
  it "should read credentials on initialize" do
    authorizer = Bravo::Authorizer.new
    expect(authorizer.pkey).to eq 'spec/fixtures/pkey'
    expect(authorizer.cert).to eq 'spec/fixtures/cert.crt'
  end
end
