require 'rspec'

require_relative '../../../replan.lib/reworker.rb'

describe Reworker do
  # Includes all the work formats, although not the whole code paths.
  #
  it 'compute the work times and add the accounting entry to the following day' do
    content = <<~TEXT
          MON 07/JUN/2021
      - 9:00. work -10:00
        - 15:00. work -16:00 -20
      - 16:00. work -10 -17:00
      - 20:00. work 1h
      - 21:00. work 1.5h
      - 23:00. work 20

          TUE 08/JUN/2021
      - foo
        - RSS, email
        - bar

    TEXT

    result = subject.execute(content)

    expected_result = <<~TEXT
          MON 07/JUN/2021
      - 9:00. work -10:00
        - 15:00. work -16:00 -20
      - 16:00. work -10 -17:00
      - 20:00. work 1h
      - 21:00. work 1.5h
      - 23:00. work 20

          TUE 08/JUN/2021
      - foo
        - RSS, email
        - lpimw -t ye '9:00-10:00, 15:00-16:00 -20, 16:00-17:00 -10, 1h, 1.5h, 20' # -c half|off
        - bar

    TEXT

    expect(result).to eql(expected_result)
  end
end # describe Reworker
