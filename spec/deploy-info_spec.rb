require 'spec_helper'

describe DeployInfo do
  it 'has a version number' do
    expect(DeployInfo::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
