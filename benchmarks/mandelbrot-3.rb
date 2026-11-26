#  The Computer Language Benchmarks Game
#  https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
#  contributed by Karl von Laudermann
#  modified by Jeremy Echols
#  modified by Detlef Reichl
#  modified by Joseph LaFata
#  modified by Peter Zotov
#
# Ported from https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/mandelbrot-ruby-3.html

require_relative '../lib/harness/loader'
require 'digest/md5'
require 'stringio'

N = 400
EXPECTED_DIGEST = "29ea778660f9fa53751db1d799f60578"

def benchmarks_game_main(size)

  puts "P4\n#{size} #{size}"

  byte_acc = 0
  bit_num = 0

  y = 0
  while y < size
    ci = (2.0*y/size)-1.0

    x = 0
    while x < size
      zrzr = zr = 0.0
      zizi = zi = 0.0
      cr = (2.0*x/size)-1.5
      escape = 0b1

      z = 0
      while z < 50
        tr = zrzr - zizi + cr
        ti = 2.0*zr*zi + ci
        zr = tr
        zi = ti
        # preserve recalculation
        zrzr = zr*zr
        zizi = zi*zi
        if zrzr+zizi > 4.0
          escape = 0b0
          break
        end
        z += 1
      end

      byte_acc = (byte_acc << 1) | escape
      bit_num += 1

      # Code is very similar for these cases, but using separate blocks
      # ensures we skip the shifting when it's unnecessary, which is most cases.
      if (bit_num == 8)
        print byte_acc.chr
        byte_acc = 0
        bit_num = 0
      elsif (x == size - 1)
        byte_acc <<= (8 - bit_num)
        print byte_acc.chr
        byte_acc = 0
        bit_num = 0
      end
      x += 1
    end
    y += 1
  end
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
  digest = benchmarks_game_run() { benchmarks_game_main(N) }
  raise "incorrect output: #{digest}" unless digest == EXPECTED_DIGEST
end
