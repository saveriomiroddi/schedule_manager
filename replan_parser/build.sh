#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset
set -o errtrace
shopt -s inherit_errexit

rex lexer.rex -o "$(dirname "$0")"/../replan.lib/replan_lexer.rb
racc parser.y -o "$(dirname "$0")"/../replan.lib/replan_parser.rb

ruby -r "$(dirname "$0")"/../replan.lib/replan_parser.rb <<'RUBY'
  examples = [
    "replan 2.5w",
    "replan fsu 2w",
    "replan f18:33su 2w",
    "replan s in 14",
    "replan 2w in 3d",
    "replan fsu 2w in 3d",
  ]

  examples.each do |example|
    puts "#{example}:"
    puts
    pp ReplanParser.new.parse(example).to_h
    puts
  end
RUBY
