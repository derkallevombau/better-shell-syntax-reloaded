require('json')
require_relative('directory')
require(PathFor[:textmate_tools])

grammar = Grammar.new(
	name: 'Test',
	scope_name: 'Test',
	file_types: ['foo'],
	wrap_source: false,
	version: ''
)

grammar[:$initial_context] = [
	newPattern(
		match: /(?<!x)a/,
		at_least: 0,
		tag_as: 'a'
	).or(
		match: /(?<!x)b/,
		at_least: 1,
		tag_as: 'b'
	)
]

puts(JSON.pretty_generate(grammar.to_h['patterns']))
