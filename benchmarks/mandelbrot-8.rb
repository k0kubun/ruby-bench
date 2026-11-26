# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# line-by-line from Greg Buchholz's C program
#
# Ported from https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/mandelbrot-ruby-8.html

require_relative '../lib/harness/loader'
require 'digest/md5'
require 'stringio'

N = 400
EXPECTED_DIGEST = "29ea778660f9fa53751db1d799f60578"

def main(n)

    w, h, bit_num = 0, 0, 0, 0, 0
    byte_acc = 0
    i, iter = 0, 50
    x, y, limit = 2.0, 2.0, 2.0
    zr, zi, cr, ci, tr, ti = 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

    h = n; w = h

    puts "P4\n#{w} #{h}"

    h.times do |y|

        w.times do |x|

            zr, zi, tr, ti = 0.0, 0.0, 0.0, 0.0
            cr = 2.0*x/w - 1.5; ci = 2.0*y/h - 1.0

            iter.times do
                if tr+ti <= limit*limit
                    zi = 2.0*zr*zi + ci;
                    zr = tr - ti + cr;
                    tr = zr * zr;
                    ti = zi * zi;
                end
            end
            byte_acc = byte_acc << 1
            if tr+ti <= limit*limit then byte_acc = byte_acc | 0x01 end

            bit_num += 1

            if bit_num == 8
                print byte_acc.chr
                byte_acc = 0;
                bit_num = 0


            elsif x == w-1

                byte_acc = byte_acc << (8-w%8)
                print byte_acc.chr
                byte_acc = 0;
                bit_num = 0
            end
       end
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
  digest = benchmarks_game_run() { main(N) }
  raise "incorrect output: #{digest}" unless digest == EXPECTED_DIGEST
end
