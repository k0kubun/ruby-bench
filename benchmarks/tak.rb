# Takeuchi function: triply recursive integer function calls.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_tak.rb
require_relative '../lib/harness/loader'

def tak(x, y, z)
  if y < x
    tak(tak(x - 1, y, z), tak(y - 1, z, x), tak(z - 1, x, y))
  else
    z
  end
end

run_benchmark(20) do
  result = tak(18, 9, 0)
  raise "incorrect result: #{result}" unless result == 9
end
