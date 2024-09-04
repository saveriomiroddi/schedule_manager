require 'highline'

class InputHelper
  # input_description: A description of what is asked, e.g. "socks size"
  #
  def ask(message, prefill: "")
    puts message

    if prefill != ""
      # MWAAAAAHAHAHAH!!
      #
      # This hack is not intended to be used on space shuttles or codebases requiring determinism. 🧐😂
      #
      Thread.new do
        sleep 0.2

        `xdotool key Tab`
      end
    end

    # It seems there isn't a simple a simple solution to this.
    # This approach is a hack of the solution at https://stackoverflow.com/a/41522086/210029.
    #
    HighLine.new.ask("") { |q| q.completion = [prefill]; q.readline = true }
  end
end
