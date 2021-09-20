class ReplanParser
rule
  expression
    : REPLAN WHITESPACE options_r period_and_next
    ;

  options_r
    : | options WHITESPACE
    ;

  options
    : options option
    | option
    ;

  option
    : F                            { checked_assign(:v_f, val[0]) }
    | F TIME                       { checked_assign(:v_f, val[0]); checked_assign(:v_f_time, val[1]) }
    | S                            { checked_assign(:v_s, val[0]) }
    | U                            { checked_assign(:v_u, val[0]) }
    ;

  period_and_next
    : INTERVAL                     { self.v_interval = val[0] }
    | next
    | INTERVAL WHITESPACE next     { self.v_interval = val[0] }
    ;

  next
    : IN WHITESPACE INTERVAL       { self.v_next = val[2] }
    ;
end

---- header
  require 'ostruct'

  require_relative 'replan_lexer'

---- inner
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
