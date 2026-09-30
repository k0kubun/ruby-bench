# Tarai function, the original form of the Takeuchi function: triply recursive integer function calls.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_tarai.rb
require_relative '../lib/harness/loader'

def tarai(x, y, z)
  if x <= y
    y
  else
    tarai(tarai(x - 1, y, z), tarai(y - 1, z, x), tarai(z - 1, x, y))
  end
end

run_benchmark(20) do
  result = tarai(12, 6, 0)
  raise "incorrect result: #{result}" unless result == 12
end
