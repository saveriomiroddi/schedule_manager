#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.5.2
# from Racc grammar file "".
#

require 'racc/parser.rb'

  require 'ostruct'

  require_relative 'replan_lexer'

class ReplanParser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 41)
  attr_accessor :v_f, :v_f_time, :v_s, :v_u, :v_interval, :v_next

  def parse(input)
    scan_str(input)

    OpenStruct.new(
      fixed:      self.v_f,
      fixed_time: self.v_f_time,
      skip:       self.v_s,
      update:     self.v_u,
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
    17,     9,     2,    10,    11,     9,     3,    10,    11,    13,
    15,    16,    15,    16,     4,     5,    19,    20,    21,    23 ]

racc_action_check = [
     7,     7,     0,     7,     7,     4,     1,     4,     4,     6,
     6,     6,    20,    20,     2,     3,     9,    13,    15,    21 ]

racc_action_pointer = [
     0,     6,    11,    15,     1,   nil,     1,    -3,   nil,    11,
   nil,   nil,   nil,    14,   nil,    15,   nil,   nil,   nil,   nil,
     3,    11,   nil,   nil ]

racc_action_default = [
   -15,   -15,   -15,   -15,    -2,    24,   -15,   -15,    -5,    -6,
    -8,    -9,    -1,   -10,   -12,   -15,   -14,    -3,    -4,    -7,
   -15,   -15,   -11,   -13 ]

racc_goto_table = [
    14,     8,     1,     6,    18,    12,     7,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    22 ]

racc_goto_check = [
     6,     5,     1,     2,     5,     3,     4,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,     6 ]

racc_goto_pointer = [
   nil,     2,    -1,    -1,     2,    -3,    -6 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  4, 12, :_reduce_none,
  0, 13, :_reduce_none,
  2, 13, :_reduce_none,
  2, 15, :_reduce_none,
  1, 15, :_reduce_none,
  1, 16, :_reduce_6,
  2, 16, :_reduce_7,
  1, 16, :_reduce_8,
  1, 16, :_reduce_9,
  1, 14, :_reduce_10,
  3, 14, :_reduce_11,
  1, 14, :_reduce_none,
  3, 17, :_reduce_13,
  1, 17, :_reduce_14 ]

racc_reduce_n = 15

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
  :IN => 9,
  :DAY => 10 }

racc_nt_base = 11

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
  "DAY",
  "$start",
  "expression",
  "options_r",
  "period_and_next",
  "options",
  "option",
  "next" ]

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
     self.v_interval = val[0]
    result
  end
.,.,

# reduce 12 omitted

module_eval(<<'.,.,', 'parser.y', 29)
  def _reduce_13(val, _values, result)
     self.v_next = val[2]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 30)
  def _reduce_14(val, _values, result)
     self.v_next = val[0]
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

end   # class ReplanParser
