# Sieve of Eratosthenes over an 8192-element array of flags, repeated many times.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_sieve.rb
require_relative '../lib/harness/loader'

ROUNDS = 500

def sieve(rounds)
  count = 0
  k = 0
  while k < rounds
    k = k + 1
    count = 0
    flags = Array.new(8192, 1)
    i = 2
    while i < 8192
      i = i + 1
      if flags[i] == 1
        j = i * i
        while j < 8192
          j = j + i
          flags[j] = 0
        end
        count = count + 1
      end
    end
  end
  count
end

run_benchmark(20) do
  count = sieve(ROUNDS)
  raise "incorrect count: #{count}" unless count == 1616
end
