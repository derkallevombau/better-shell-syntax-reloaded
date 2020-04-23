# Author: derkallevombau
# Created 2020-04-23 10:48:15

require('logger')

# Creates a stdlib `Logger` with the provided arguments.
#
# Implements the standard logging methods which all take just a block
# and call the respective method on the logger, passing the block
# and providing `caller[0]` for the `progname` parameter.<br>
# Provides a formatter that uses that to print the file and method name.
#
# We use the block form because the contents of the block are evaluated only if
# the message will actually be logged.
class LoggerWrapper
	# @param args [Array] See `Logger#new`.
	# @param kwargs [Hash] See `Logger#new`.\
	# If you specify a `:datetime_format`, it will not be passed to the `Logger`
	# ctor, but instead used within out formatter.\
	# Don't specify a `:formatter` since we have our own formatter.
	def initialize(*args, **kwargs)
		dateTimeFormat =
			if kwargs&.values_at(:datetime_format)
				'%Y-%m-%d %H:%M:%S.%L'
			else
				kwargs.delete(:datetime_format)
			end

		@logger = Logger.new(*args, **kwargs)

		# @param severity [String]
		# @param datetime [Time]
		# @param progname [String]
		# @param msg [String]
		@logger.formatter = ->(severity, datetime, progname, msg) do
			progname.match(/(?<=\/)([^\/]+?)(?=:).+(?<=`)([^']+?)(?=')/) do
				"#{datetime.strftime(dateTimeFormat)} [#{severity}] #{$1}: #{$2}: #{msg}\n"
			end
		end

		ObjectSpace.define_finalizer(self, method(:finalize)) # Define a dtor method.
	end

	def finalize(_object_id)
		@logger.debug { 'Closing global logger.' }

		@logger.close
	end

	def debug(&block)   @logger.debug(caller[0],   &block) end
	def info(&block)    @logger.info(caller[0],    &block) end
	def warn(&block)    @logger.warn(caller[0],    &block) end
	def error(&block)   @logger.error(caller[0],   &block) end
	def fatal(&block)   @logger.fatal(caller[0],   &block) end
	def unknown(&block) @logger.unknown(caller[0], &block) end
end
