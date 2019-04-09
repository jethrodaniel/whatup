# frozen_string_literal: true

RSpec.describe Whatup do
  it 'has a version number' do
    expect(Whatup::VERSION).not_to be nil
  end

  it '.root' do
    expect(Whatup.root).not_to be nil
  end
end
