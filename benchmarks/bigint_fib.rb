# Fibonacci numbers by iterated addition up to a 209-digit result, exercising Integer
# addition as it grows from Fixnum into Bignum.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_bigint_fib.rb
require_relative '../lib/harness/loader'

REPEAT = 3000
N = 1000

run_benchmark(20) do
  result = 0
  j = 0
  while j < REPEAT
    a = 0
    b = 1
    i = 0
    while i < N
      c = a + b
      a = b
      b = c
      i = i + 1
    end
    result = a
    j = j + 1
  end
  raise "incorrect result" unless result.to_s.length == 209 && result % 1_000_000 == 228_875
end
