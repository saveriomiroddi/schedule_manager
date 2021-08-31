require 'highline'

class InputHelper
  # input_description: A description of what is asked, e.g. "socks size"
  #
  def ask(input_description, prefill: "")
    print_message(input_description, prefill)

    # It seems there isn't a simple a simple solution to this.
    # This approach is a hack of the solution at https://stackoverflow.com/a/41522086/210029.
    #
    # Interesting hack: send in a separate thread a tab character (and also a backspace, since highline
    # appends an ugly space at the end).
    #
    HighLine.new.ask("") { |q| q.completion = [prefill]; q.readline = true }
  end

  private

  def print_message(input_description, prefill)
    print "Enter the #{input_description}"
    print " (press Tab to autocomplete)" if prefill != ""
    puts  ":"
  end
end