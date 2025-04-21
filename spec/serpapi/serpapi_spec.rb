require 'spec_helper'

describe 'SerpApi::Version' do

  it 'check version' do
    expect(SerpApi::VERSION).not_to be_nil
  end

end
