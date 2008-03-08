module ISSN
  class Validations  
    def self.clean(issn)
      issn.upcase.gsub(/[^0-9X]/, '')
    end

    def self.looks_valid?(issn)
      return /^\d{7}[0-9X]$/.match(issn)
    end

    def self.is_valid?(issn)
      issn = clean(issn)
      return false unless looks_valid?(issn)

      bits = issn.split(//).collect { |b| b.to_i }
      checksum = bits[7] == 'X' ? 10 : bits[7]

      sum = 0
      8.downto(2) do |pos|
        sum += pos * bits.shift
      end

      return checksum == (11 - (sum % 11)) % 10
    end 
  end
end

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_as_issn(*attr_names)
        configuration = {
          :message  => 'is not a valid ISSN'
        }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless ISSN::Validations.is_valid?(value)
            record.errors.add(attr_name, configuration[:message])
          end
        end
      end
    end
  end
end
