module AdjustedDateWday
  refine Date do
    def adjusted_wday
      (wday - 1) %7
    end
  end
end
