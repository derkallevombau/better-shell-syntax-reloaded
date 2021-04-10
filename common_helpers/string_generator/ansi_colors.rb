# Author: derkallevombau
# Created 2020-04-25 13:00:52

# ANSI escape control sequences for text colors / formatting
module AnsiColors
	AnsiColor = {
		# rubocop: disable Layout/HashAlignment

		# foreground normal

		'black'   => "\e[30m",
		'red'     => "\e[31m",
		'green'   => "\e[32m",
		'yellow'  => "\e[33m",
		'blue'    => "\e[34m",
		'magenta' => "\e[35m",
		'cyan'    => "\e[36m",
		'white'   => "\e[37m",
		'salmon'  => "\e[38;2;250;160;130m",

		# foreground light

		'light_black'   => "\e[90m",
		'light_red'     => "\e[91m",
		'light_green'   => "\e[92m",
		'light_yellow'  => "\e[93m",
		'light_blue'    => "\e[94m",
		'light_magenta' => "\e[95m",
		'light_cyan'    => "\e[96m",
		'light_white'   => "\e[97m",
		'light_salmon'  => "\e[38;2;255;170;120m", # No mechanism to automatically intensify RGB colors

		# some 8 bit foreground colors

		'redorange' => "\e[38;5;202m",
		'orange'    => "\e[38;5;208m",
		'lime'      => "\e[38;5;154m",
		'violet'    => "\e[38;5;200m",
		'turquoise' => "\e[38;5;49m",

		# background normal

		'on_black'   => "\e[40m",
		'on_red'     => "\e[41m",
		'on_green'   => "\e[42m",
		'on_yellow'  => "\e[43m",
		'on_blue'    => "\e[44m",
		'on_magenta' => "\e[45m",
		'on_cyan'    => "\e[46m",
		'on_white'   => "\e[47m",
		'on_salmon'  => "\e[48;2;250;160;130m",

		# background light

		'on_light_black'   => "\e[100m",
		'on_light_red'     => "\e[101m",
		'on_light_green'   => "\e[102m",
		'on_light_yellow'  => "\e[103m",
		'on_light_blue'    => "\e[104m",
		'on_light_magenta' => "\e[105m",
		'on_light_cyan'    => "\e[106m",
		'on_light_white'   => "\e[107m",
		'on_light_salmon'  => "\e[48;2;255;170;120m", # see light_salmon

		# formatting

		'norm'   => "\e[0m", # resets all attributes, i. e. not only formatting, but also foreground/background color
		'bold'   => "\e[1m",
		'dim'    => "\e[2m",
		'italic' => "\e[3m",
		'undl'   => "\e[4m",
		'blink'  => "\e[5m",
		'rev'    => "\e[7m",
		'hidden' => "\e[8m",
		'strike' => "\e[9m",
		'dundl'  => "\e[21m"

		# rubocop: enable Layout/HashAlignment
	}.freeze
end
