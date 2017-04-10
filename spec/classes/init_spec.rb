# frozen_string_literal: true

require 'spec_helper'
describe 'newsyslog' do
  context 'with defaults for all parameters' do
    it { should contain_class('newsyslog') }
  end
end
