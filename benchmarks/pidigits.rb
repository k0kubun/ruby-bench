# Pidigits: extracts decimal digits of pi with Gosper's series using Integer arithmetic
# that grows into Bignums.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_pidigits.rb
require_relative '../lib/harness/loader'

def pidigits(n)
  q = 1
  r = 0
  t = 1
  k = 0
  i = 0
  result = ""
  while i < n
    k = k + 1
    b = 2 * k + 1
    nq = q * k
    nr = (2 * q + r) * b
    nt = t * b
    q = nq
    r = nr
    t = nt
    while (q * 3 + r) / t == (q * 4 + r) / t
      d = (q * 3 + r) / t
      result = result + d.to_s
      r = 10 * (r - d * t)
      q = q * 10
      i = i + 1
      if i >= n
        break
      end
    end
  end
  result
end

DIGITS = 2000

run_benchmark(20) do
  result = pidigits(DIGITS)
  raise "incorrect digits: #{result[0, 20]}" unless result.length == DIGITS && result.start_with?("31415926535897932384") && result.end_with?("4780275900")
end
