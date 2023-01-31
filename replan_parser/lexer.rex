# The `DAY`/`NUM` concept would be better described with `WEEKDAY` and `DAY`.
#
class ReplanParser
macro
  REPLAN      replan
  WHITESPACE  \s+
  DAY         (mon|tue|wed|thu|fri|sat|sun)\+?
  LAST_DAY    -(mon|tue|wed|thu|fri|sat|sun)
  LAST_DAYNUM -\d+
  F           f
  S           s
  U_LOW       u
  U_UP        U
  TIME        \d{1,2}:\d\d
  INTERVAL    \d+(\.\d+)?[dwmy]?
  IN          in

rule
  {REPLAN}      { [:REPLAN, text] }
  {WHITESPACE}  { [:WHITESPACE, text] }
  {DAY}         { [:DAY, text] }
  {LAST_DAY}    { [:LAST_DAY, text] }
  {LAST_DAYNUM} { [:LAST_DAYNUM, text] }
  {F}           { [:F, text] }
  {S}           { [:S, text] }
  {U_LOW}       { [:U_LOW, text] }
  {U_UP}        { [:U_UP, text] }
  {TIME}        { [:TIME, text] }
  {INTERVAL}    { [:INTERVAL, text] }
  {IN}          { [:IN, text] }
end
