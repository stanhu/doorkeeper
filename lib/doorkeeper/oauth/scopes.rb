# frozen_string_literal: true

module Doorkeeper
  module OAuth
    class Scopes
      include Enumerable
      include Comparable

      DYNAMIC_SCOPE_SUFFIX = ":*"

      def self.from_string(string)
        string ||= ""
        new.tap do |scope|
          scope.add(*string.split)
        end
      end

      def self.from_array(array)
        new.tap do |scope|
          scope.add(*array)
        end
      end

      delegate :each, :empty?, to: :@scopes

      def initialize
        @scopes = []
      end

      def exists?(scope)
        scope = scope.to_s

        @scopes.any? do |candidate|
          if candidate.end_with?(DYNAMIC_SCOPE_SUFFIX) && scope.include?(':')
            prefix = strip_dynamic_scope_suffix(candidate)
            scope.start_with?("#{prefix}:")
          else
            candidate == scope
          end
        end
      end

      def add(*scopes)
        @scopes.push(*scopes.map(&:to_s))
        @scopes.uniq!
      end

      def all
        @scopes
      end

      def to_s
        @scopes.join(" ")
      end

      def scopes?(scopes)
        scopes.all? { |scope| exists?(scope) }
      end

      alias has_scopes? scopes?

      def +(other)
        self.class.from_array(all + to_array(other))
      end

      def <=>(other)
        if other.respond_to?(:map)
          map(&:to_s).sort <=> other.map(&:to_s).sort
        else
          super
        end
      end

      def &(other)
        self.class.from_array(all & to_array(other))
      end

      private

      def strip_dynamic_scope_suffix(scope)
        return scope unless scope.end_with?(DYNAMIC_SCOPE_SUFFIX)

        scope[0..scope.length - 1 - DYNAMIC_SCOPE_SUFFIX.length]
      end

      def to_array(other)
        case other
        when Scopes
          other.all
        else
          other.to_a
        end
      end
    end
  end
end
