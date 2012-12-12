module MotherBrain
  module Locks
    # @author Jamie Winsor <jamie@vialstudios.com>
    #
    # A registry of locks obtained against resources on a Chef Server
    class Manager
      include Celluloid
      include MB::Logging

      # @return [Set<ChefMutex>]
      attr_reader :locks

      def initialize
        log.info { "Lock Manager starting..." }
        @locks = Set.new
      end

      # Find a lock of the given name in the list of registered locks
      #
      # @param [#to_s] name
      #
      # @return [ChefMutex, nil]
      def find(name)
        locks.find { |mutex| mutex.name == name.to_s }
      end

      # Register the given lock
      #
      # @param [ChefMutex] mutex
      def register(mutex)
        locks.add(mutex)
      end

      def reset
        self.locks.clear
      end

      # Unregister the given lock
      #
      # @param [ChefMutex] mutex
      def unregister(mutex)
        locks.delete(mutex)
      end

      def finalize
        log.info { "Lock Manager stopping..." }
      end
    end
  end
end
