function diminishing_returns(max, start, factor, x)
  return x + (max * (1-math.exp(factor * math.max(0, x-start))))
end
