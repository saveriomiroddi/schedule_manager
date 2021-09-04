#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.5.2
# from Racc grammar file "".
#

require 'racc/parser.rb'

  require 'ostruct'

  require_relative 'replan_lexer'

class ReplanParser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 36)
  attr_accessor :v_f, :v_f_time, :v_s, :v_u, :v_interval, :v_next

  def parse(input)
    scan_str(input)

    OpenStruct.new(
      fixed:      !self.v_f.nil?,
      fixed_time: self.v_f_time,
      skip:       !self.v_s.nil?,
      update:     !self.v_u.nil?,
      interval:   self.v_interval,
      next:       self.v_next,
    )
  end

  private

  # Assign to self.<var>, checking that it_s not already assigned.
  #
  def checked_assign(var, value)
    self.send(var).nil? ?
      self.send("#{var}=", value) :
      raise("Option '#{var}' is already assigned: #{self.send(var)}")
  end
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    15,     9,     2,    10,    11,     9,     3,    10,    11,    13,
    14,     4,     5,    17,    18,    19,    20,    21,    22,    23 ]

racc_action_check = [
     7,     7,     0,     7,     7,     4,     1,     4,     4,     6,
     6,     2,     3,     9,    13,    14,    18,    19,    20,    22 ]

racc_action_pointer = [
     0,     6,     8,    12,     1,   nil,     1,    -3,   nil,     8,
   nil,   nil,   nil,    11,    12,   nil,   nil,   nil,     7,     9,
    15,   nil,    11,   nil ]

racc_action_default = [
   -13,   -13,   -13,   -13,    -2,    24,   -13,   -13,    -5,    -6,
    -8,    -9,    -1,   -10,   -13,    -3,    -4,    -7,   -13,   -13,
   -13,   -11,   -13,   -12 ]

racc_goto_table = [
     8,     1,     6,    16,    12,     7 ]

racc_goto_check = [
     5,     1,     2,     5,     3,     4 ]

racc_goto_pointer = [
   nil,     1,    -2,    -2,     1,    -4 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  4, 11, :_reduce_none,
  0, 12, :_reduce_none,
  2, 12, :_reduce_none,
  2, 14, :_reduce_none,
  1, 14, :_reduce_none,
  1, 15, :_reduce_6,
  2, 15, :_reduce_7,
  1, 15, :_reduce_8,
  1, 15, :_reduce_9,
  1, 13, :_reduce_10,
  3, 13, :_reduce_11,
  5, 13, :_reduce_12 ]

racc_reduce_n = 13

racc_shift_n = 24

racc_token_table = {
  false => 0,
  :error => 1,
  :REPLAN => 2,
  :WHITESPACE => 3,
  :F => 4,
  :TIME => 5,
  :S => 6,
  :U => 7,
  :INTERVAL => 8,
  :IN => 9 }

racc_nt_base = 10

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "REPLAN",
  "WHITESPACE",
  "F",
  "TIME",
  "S",
  "U",
  "INTERVAL",
  "IN",
  "$start",
  "expression",
  "options_r",
  "period_and_next",
  "options",
  "option" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

# reduce 2 omitted

# reduce 3 omitted

# reduce 4 omitted

# reduce 5 omitted

module_eval(<<'.,.,', 'parser.y', 16)
  def _reduce_6(val, _values, result)
     checked_assign(:v_f, val[0])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 17)
  def _reduce_7(val, _values, result)
     checked_assign(:v_f, val[0]); checked_assign(:v_f_time, val[1])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 18)
  def _reduce_8(val, _values, result)
     checked_assign(:v_s, val[0])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 19)
  def _reduce_9(val, _values, result)
     checked_assign(:v_u, val[0])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 23)
  def _reduce_10(val, _values, result)
     self.v_interval = val[0]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 24)
  def _reduce_11(val, _values, result)
     self.v_next = val[2]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 25)
  def _reduce_12(val, _values, result)
     self.v_interval = val[0]; self.v_next = val[4]
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

end   # class ReplanParser
