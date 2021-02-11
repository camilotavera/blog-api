# frozen_string_literal: true

require 'securerandom'

class TokenCreatorService
  def self.generate
    SecureRandom.hex
  end
end
