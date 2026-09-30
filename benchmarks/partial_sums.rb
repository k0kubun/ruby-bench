# Partial sums: accumulates nine series in a single Float loop that calls Math.sin, Math.cos,
# Math.sqrt and Float#**.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_partial_sums.rb
require_relative '../lib/harness/loader'

N = 1_000_000

def partial_sums(n)
  alt = 1.0
  s0 = 0.0
  s1 = 0.0
  s2 = 0.0
  s3 = 0.0
  s4 = 0.0
  s5 = 0.0
  s6 = 0.0
  s7 = 0.0
  s8 = 0.0

  d_int = 1
  while d_int <= n
    d = d_int.to_f
    d2 = d * d
    d3 = d2 * d
    ds = Math.sin(d)
    dc = Math.cos(d)

    s0 = s0 + (2.0 / 3.0) ** (d - 1.0)
    s1 = s1 + 1.0 / Math.sqrt(d)
    s2 = s2 + 1.0 / (d * (d + 1.0))
    s3 = s3 + 1.0 / (d3 * ds * ds)
    s4 = s4 + 1.0 / (d3 * dc * dc)
    s5 = s5 + 1.0 / d
    s6 = s6 + 1.0 / d2
    s7 = s7 + alt / d
    s8 = s8 + alt / (2.0 * d - 1.0)

    alt = 0.0 - alt
    d_int = d_int + 1
  end

  [s0, s1, s2, s3, s4, s5, s6, s7, s8]
end

run_benchmark(20) do
  sums = partial_sums(N)
  # (2/3)^k sums to 3, 1/(d(d+1)) sums to 1, and the Gregory series 1 - 1/3 + 1/5 ... sums to pi/4.
  raise "incorrect sum: #{sums[0]}" unless (sums[0] - 3.0).abs < 1e-6
  raise "incorrect sum: #{sums[2]}" unless (sums[2] - 1.0).abs < 1e-5
  raise "incorrect sum: #{sums[8]}" unless (sums[8] - 0.7853981633974483).abs < 1e-5
end
