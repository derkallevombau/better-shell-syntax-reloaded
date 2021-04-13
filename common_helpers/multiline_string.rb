require('json')

require_relative('string_generator/ansi_colors')

# Literal multiline strings look really awkward since each line
# after the first one must not be indented.<br>
# Too bad thay Ruby doesn't concatenate string literals in consecutive lines
# automatically as C++ does and concatenation operators before/after line breaks
# work only with line continuation, i. e. placing a backslash at EOL.
#
# This class implements the class method `generate` which does not only allow to
# generate multiline strings in a neatly manner, but also other nifty things like
# automatic line breaks, coloring and evaluation of arbitrary expressions.
class StringGenerator
	include(AnsiColors) # Makes AnsiColor an instance member.

	AnsiSpecifier = AnsiColor.keys.join('|')

	# This method takes a list of strings (and other objects) and returns a string that
	# is the concatenation of the provided strings.<br>
	# Furthermore, it optionally inserts newlines between the provided strings and/or prepends
	# an arbitrary number of newlines to the resulting string.
	# @param args [Array] List of strings to be concatenated.\
	#     \
	#     You may also provide arbitray objects; they will be converted to strings by calling their `inspect` method,\
	#     as well as `Symbol`s representing expressions to be evaluated (see below).
	#     \
	#     An argument of `nil` will cause a line break.
	#     ### Coloring/formatting
	#         You may apply colors and formattings to an item by providing a `Symbol` composed of specifiers
	#         _before_ the respective item:\
	#         \
	#         `:<formatting 1>_..._<formatting N>_<foreground color>_<background color>`\
	#         \
	#         Each specifier is optional.
	#     #### Examples
	#             :bold_blink_light_cyan_on_red
	#             :dim_magenta
	#             :light_white
	#             :bold_white
	#             :bold_light_white
	#             :bold_undl_light_white
	#     #### Available specifiers
	#         - Foreground colors
	#             - black
	#             - red
	#             - green
	#             - yellow
	#             - blue
	#             - magenta
	#             - cyan
	#             - white
	#             - salmon
	#             - redorange
	#             - orange
	#             - lime
	#             - violet
	#             - turquoise
	#         - Bright foreground colors
	#             - light_black
	#             - light_red
	#             - light_green
	#             - light_yellow
	#             - light_blue
	#             - light_magenta
	#             - light_cyan
	#             - light_white
	#             - light_salmon
	#         - Background colors
	#             - on_black
	#             - on_red
	#             - on_green
	#             - on_yellow
	#             - on_blue
	#             - on_magenta
	#             - on_cyan
	#             - on_white
	#             - on_salmon
	#         - Bright background colors
	#             - on_light_black
	#             - on_light_red
	#             - on_light_green
	#             - on_light_yellow
	#             - on_light_blue
	#             - on_light_magenta
	#             - on_light_cyan
	#             - on_light_white
	#             - on_light_salmon
	#         - Formattings
	#             - bold
	#             - dim
	#             - italic
	#             - undl
	#             - blink
	#             - rev
	#             - hidden
	#             - strike
	#             - dundl
	#
	#       ### Expression evaluation
	#       You may generate a string of the form '<prefix><expr>: <value>' by providing `binding`,\
	#       followed by the `Symbol`ised expression, e. g. `:some_variable`,\
	#       or more complex expressions like this: `'foo(some_variable)'.to_sym`.\
	#       \
	#       You may provide as many expressions as you want. They don't need to be passed consecutively,\
	#       and the `binding` needs to be passed only once.\
	#       \
	#       <prefix> defaults to "- ", you may set an arbitrary string via the `evalExprPrefix` parameter.\
	#       \
	#       The format of a `Symbol` to apply coloring/formatting is as follows:\
	#       \
	#       `:<specifiers for expr>__<specifiers for value>`\
	#       \
	#       You may omit `<specifiers for expr>` or `<specifiers for value>`.\
	#       #### Examples
	#       ```
	#       :bold_blink_light_cyan_on_red__light_magenta
	#       :dim_magenta__bold_light_white
	#       :undl_light_white__
	#       :__light_green
	#       ```
	#
	# @param autoNewline [Boolean] Whether to insert newlines between the provided strings.
	#     and to use `nil` to begin a new paragraph.
	# @param precedingNewlines [Boolean] How many newlines to prepend to the resulting string.
	# @param prettyGenerateHashes [Boolean] Whether to use `JSON.pretty_generate`
	#     to convert hashes to strings.
	# @param prettyGenerateArrays [Boolean] Whether to use `JSON.pretty_generate`
	#     to convert arrays to strings.
	# @param evalExprPrefix [String]
	# @param evalExprColor [Symbol] Color specifier for default color of evaluated expression.
	# @param evalExprValueColor [Symbol] Color specifier for default color of value of evaluated expression.
	# @return [String]
	def self.generate(*args, autoNewline: false, precedingNewlines: 0, prettyGenerateHashes: false, prettyGenerateArrays: false, evalExprPrefix: '- ', evalExprColor: nil, evalExprValueColor: nil) # 'self.' is used to define class methods.
		evalExprAnsiCodes      = evalExprColor.nil? ? nil : processSymbol(evalExprColor) # N.B.: No 'StringGenerator.' before private class method invocations.
		evalExprValueAnsiCodes = evalExprValueColor.nil? ? nil : processSymbol(evalExprValueColor)

		## Class variables

		# @type [Hash]
		@@ansiCodes = nil
		@@bind = nil

		# Extract binding from args, if any, for expression evaluation.
		args.delete_if do |arg|
			if arg.is_a?(Binding)
				@@bind = arg

				true
			else
				false
			end
		end

		# Turn nil into "\n" if !autoNewline, else turn nil into ''.
		# Turn non-string objects into strings.
		args.map! do |arg|
			string =
				case arg
					when nil    then autoNewline ? '' : "\n" # We can check for a certain value...
					when String then arg                     # ... as well as for a type. Nice feature!
					when Hash   then hashOrArrayToString(arg, prettyGenerateHashes)
					when Array  then hashOrArrayToString(arg, prettyGenerateArrays)
					when Symbol
						result = processSymbol(arg, prettyGenerateHashes, prettyGenerateArrays, evalExprPrefix, evalExprAnsiCodes, evalExprValueAnsiCodes)

						@@ansiCodes = result if result.is_a?(Hash)

						result
					else arg.inspect
				end

			if @@ansiCodes&.key?(:normal) && string != @@ansiCodes[:normal] # Last arg was a normal color specifier.
				@@ansiCodes = nil

				# Prepend color/formatting codes to string
				# and append code to reset all attributes.
				@@ansiCodes[:normal] + string + AnsiColor['norm']
			else
				string
			end
		end

		args.join(autoNewline ? "\n" : '').prepend("\n" * precedingNewlines)
	end

	## Private class methods

	# Processes a `Symbol` that is either a color specifier or an expression to be evaluated.
	# @param symbol [Symbol]
	# @param prettyGenerateHashes [Boolean]
	# @param prettyGenerateArrays [Boolean]
	# @param evalExprPrefix [String]
	# @param evalExprAnsiCodes [String] Color of evaluated expression.
	# @param evalExprValueAnsiCodes [String] Color of value of evaluated expression.
	# @return [Hash, String] A `Hash` that maps the entities to be colored to the
	#     respective ANSI codes if `symbol` is a color specifier,\
	#     or a string containing the expression and its value if `symbol`
	#     is an expression to be evaluated.
	def self.processSymbol(symbol, prettyGenerateHashes, prettyGenerateArrays, evalExprPrefix, evalExprAnsiCodes, evalExprValueAnsiCodes)
		## First, check if symbol is a color specifier.
		ansiSpecStr = symbol.to_s

		# As long as there is a specifier, replace it with the respective code.
		# Nice: This is short for 'ansiSpecStr.sub!(/#{AnsiSpecifier}/) { |m| AnsiColor[m] }'
		while ansiSpecStr.sub!(/#{AnsiSpecifier}/, AnsiColor)
		end

		if ansiSpecStr != symbol.to_s # It is a color specifier.
			# Determine type of color specifier and return a hash as appropriate
			# with remaining underscores removed, if any.

			if    (@@ansiCodes = ansiSpecStr.match(/(.+)__$/)    { { expr: $1 } })                # It is a color specifier for evaluated expression.
			elsif (@@ansiCodes = ansiSpecStr.match(/^__(.+)/)    { { exprValue: $1 } })           # It is a color specifier for value of evaluated expression.
			elsif (@@ansiCodes = ansiSpecStr.match(/(.+)__(.+)/) { { expr: $1, exprValue: $2 } }) # It is a color specifier for both.
			else  (@@ansiCodes =                                   { normal: ansiSpecStr })       # It is a color specifier for a normal string.
			end

			@@ansiCodes.gsub(/_/, '')
		else
			## If it isn't a color specifier, it is an expression to be evaluated.

			# Return a string containing the expression and its value.

			exprValue = eval(symbol.to_s, @@bind)

			exprValue =
				case exprValue
					when Hash
						hashOrArrayToString(exprValue, prettyGenerateHashes)
					when Array
						hashOrArrayToString(exprValue, prettyGenerateArrays)
					else
						exprValue
				end

			evalExprPrefix + evalExprAnsiCodes + symbol.to_s + AnsiColor['norm'] + ': ' + evalExprValueAnsiCodes + exprValue + AnsiColor['norm']
		end
	end

	# @return [String]
	def self.hashOrArrayToString(hashOrArray, prettyGenerate)
		prettyGenerate ? JSON.pretty_generate(hashOrArray) : hashOrArray.inspect
	end

	private_class_method(:processSymbol, :hashOrArrayToString)
end
