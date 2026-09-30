# Ackermann function: deeply recursive integer arithmetic with two arguments.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_ackermann.rb
require_relative '../lib/harness/loader'

def ack(m, n)
  if m == 0
    n + 1
  elsif n == 0
    ack(m - 1, 1)
  else
    ack(m - 1, ack(m, n - 1))
  end
end

run_benchmark(20) do
  result = ack(3, 9)
  raise "incorrect result: #{result}" unless result == 4093
end
