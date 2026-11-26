# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
# Contributed by Sokolov Yura
# Modified by Chris Houhoulis (April 2013):
#   - made loops uglier to avoid the unnecessary overhead of blocks
#   - nicer naming for readability
#
# Ported from https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/spectralnorm-ruby-4.html

require_relative '../lib/harness/loader'
require 'digest/md5'
require 'stringio'

N = 400
EXPECTED_DIGEST = "9102afc15ff804a410e0f8a220085425"

ARRAY_LENGTH = N

def eval_A(i,j)
  1.0/((i+j)*(i+j+1)/2+i+1)
end

def vector_times_array(vector)
  arr, i = [], 0
  while i < ARRAY_LENGTH
    sum, j = 0, 0
    while j < ARRAY_LENGTH
      sum += eval_A(i,j) * vector[j]
      j += 1
    end
    arr << sum
    i += 1
  end
  arr
end

def vector_times_array_transposed(vector)
  arr, i = [], 0
  while i < ARRAY_LENGTH
    sum, j = 0, 0
    while j < ARRAY_LENGTH
      sum += eval_A(j,i) * vector[j]
      j += 1
    end
    arr << sum
    i += 1
  end
  arr
end

def vector_times_array_times_array_transposed(vector)
  vector_times_array_transposed(vector_times_array(vector))
end

def benchmarks_game_main
  u = Array.new(ARRAY_LENGTH, 1)
  v = []
  10.times do
    v = vector_times_array_times_array_transposed(u)
    u = vector_times_array_times_array_transposed(v)
  end

  vBv, vv, i = 0, 0, 0
  while i < ARRAY_LENGTH
    vBv += u[i]*v[i]
    vv += v[i]*v[i]
    i += 1
  end

  print "%0.9f" % (Math.sqrt(vBv/vv)), "\n"
end

# Runs the block with $stdout (and $stdin) redirected and returns the MD5 of what it printed
def benchmarks_game_run(input = nil)
  $stdin = StringIO.new(input) if input
  $stdout = StringIO.new
  yield
  Digest::MD5.hexdigest($stdout.string)
ensure
  $stdin = STDIN
  $stdout = STDOUT
end

run_benchmark(10) do
  digest = benchmarks_game_run() { benchmarks_game_main }
  raise "incorrect output: #{digest}" unless digest == EXPECTED_DIGEST
end
