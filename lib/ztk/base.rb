require 'ostruct'

module ZTK

  # Base Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class BaseError < Error; end

  # Base Class
  #
  # This is the base class inherited by most of the other classes in this
  # library.  It provides a standard set of features to control STDOUT, STDERR
  # and STDIN, a configuration mechanism and logging mechanism.
  #
  # You should never interact with this class directly; you should inherit it
  # and extend functionality as appropriate.
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Base

    class << self

      # @param [Hash] configuration Configuration options hash.
      # @option config [ZTK::UI] :ui Instance of ZTK:UI to be used for
      #   console IO and logging.
      def build_config(configuration={})
        if configuration.is_a?(OpenStruct)
          configuration = configuration.send(:table)
        end

        # FIXME: this needs to be refactored into the UI class
        config = OpenStruct.new({
          :ui => ::ZTK::UI.new
        }.merge(configuration))

        config
      end

      # Removes all key-value pairs which are not core so values do not bleed
      # into classes they are not meant for.
      #
      # This method will leave :stdout, :stderr, :stdin and :logger key-values
      # intact, while removing all other key-value pairs.
      def sanitize_config(configuration={})
        if configuration.is_a?(OpenStruct)
          configuration = configuration.send(:table)
        end

        config = configuration.reject do |key,value|
          !(%w(stdout stderr stdin logger).map(&:to_sym).include?(key))
        end

        config
      end

      # Logs an exception and then raises it.
      #
      # @param [Logger] logger An instance of a class based off the Ruby
      #   *Logger* class.
      # @param [Exception] exception The exception class to raise.
      # @param [String] message The message to display with the exception.
      # @param [Integer] shift (1) How many places to shift the caller stack in
      #   the log statement.
      def log_and_raise(logger, exception, message, shift=1)
        if logger.is_a?(ZTK::Logger)
          logger.shift(:fatal, shift) { "EXCEPTION: #{exception.inspect} - #{message.inspect}" }
        else
          logger.fatal { "EXCEPTION: #{exception.inspect} - #{message.inspect}" }
        end
        raise exception, message
      end

    end

    # @param [Hash] config Configuration options hash.
    # @option config [IO] :stdout Instance of IO to be used for STDOUT.
    # @option config [IO] :stderr Instance of IO to be used for STDERR.
    # @option config [IO] :stdin Instance of IO to be used for STDIN.
    # @option config [Logger] :logger Instance of Logger to be used for logging.
    def initialize(config={})
      @config = Base.build_config(config)
    end

    # Configuration OpenStruct accessor method.
    #
    # If no block is given, the method will return the configuration OpenStruct
    # object.  If a block is given, the block is yielded with the configuration
    # OpenStruct object.
    #
    # @yieldparam [OpenStruct] config The configuration OpenStruct object.
    # @return [OpenStruct] The configuration OpenStruct object.
    def config(&block)
      if block_given?
        block.call(@config)
      else
        @config
      end
    end

    # Logs an exception and then raises it.
    #
    # @see Base.log_and_raise
    #
    # @param [Exception] exception The exception class to raise.
    # @param [String] message The message to display with the exception.
    # @param [Integer] shift (2) How many places to shift the caller stack in
    #   the log statement.
    def log_and_raise(exception, message, shift=2)
      Base.log_and_raise(config.ui.logger, exception, message, shift)
    end

    # Direct logging method.
    #
    # This method provides direct writing of data to the current log device.
    # This is mainly used for pushing STDOUT and STDERR into the log file in
    # ZTK::SSH and ZTK::Command, but could easily be used by other classes.
    #
    # The value returned in the block is passed down to the logger specified in
    # the classes configuration.
    #
    # @param [Symbol] log_level This should be any one of [:debug, :info, :warn, :error, :fatal].
    # @yield No value is passed to the block.
    # @yieldreturn [String] The message to log.
    def direct_log(log_level, &blocK)
      @config.ui.logger.nil? and raise BaseError, "You must supply a logger for direct logging support!"

      if !block_given?
        log_and_raise(BaseError, "You must supply a block to the log method!")
      elsif (@config.ui.logger.level <= ZTK::Logger.const_get(log_level.to_s.upcase))
        if @config.ui.logger.respond_to?(:logdev)
          @config.ui.logger.logdev.write(ZTK::ANSI.uncolor(yield))
          @config.ui.logger.logdev.respond_to?(:flush) and @config.ui.logger.logdev.flush
        else
          @config.ui.logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).write(ZTK::ANSI.uncolor(yield))
          @config.ui.logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).respond_to?(:flush) and @config.ui.logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).flush
        end
      end
    end

  end

end
