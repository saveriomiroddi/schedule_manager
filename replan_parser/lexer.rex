class ReplanParser
macro
  REPLAN     replan
  WHITESPACE \s+
  DAY        mon|tue|wed|thu|fri|sat|sun
  F          f
  S          s
  U          u
  TIME       \d{1,2}:\d\d
  INTERVAL   \d+(\.\d+)?[dwmy]?
  IN         in

rule
  {REPLAN}     { [:REPLAN, text] }
  {WHITESPACE} { [:WHITESPACE, text] }
  {DAY}        { [:DAY, text] }
  {F}          { [:F, text] }
  {S}          { [:S, text] }
  {U}          { [:U, text] }
  {TIME}       { [:TIME, text] }
  {INTERVAL}   { [:INTERVAL, text] }
  {IN}         { [:IN, text] }
end
