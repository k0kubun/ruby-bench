# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by Gabriele Renzi
#
# Ported from https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/pidigits-ruby-1.html

require_relative '../lib/harness/loader'
require 'digest/md5'
require 'stringio'

N = 2_000
EXPECTED_DIGEST = "fe417b93233f813cee20f028b734c4bc"

class PiDigitSpigot

    def initialize()
        @z = Transformation.new 1,0,0,1
        @x = Transformation.new 0,0,0,0
        @inverse = Transformation.new 0,0,0,0
    end

    def next!
        @y = @z.extract(3)
        if safe? @y
            @z = produce(@y)
            @y
        else
            @z = consume @x.next!()
            next!()
        end
    end

    def safe?(digit)
        digit == @z.extract(4)
    end

    def produce(i)
        @inverse.qrst(10,-10*i,0,1).compose(@z)
    end

    def consume(a)
        @z.compose(a)
    end
end


WIDTH = 10

class Transformation
    attr_reader :q, :r, :s, :t
    def initialize (q, r, s, t)
        @q,@r,@s,@t,@k = q,r,s,t,0
    end

    def next!()
        @q = @k = @k + 1
        @r = 4 * @k + 2
        @s = 0
        @t = 2 * @k + 1
        self
    end

    def extract(j)
        (@q * j + @r) / (@s * j + @t)
    end

    def compose(a)
        self.class.new( @q * a.q,
                        @q * a.r + r * a.t,
                        @s * a.q + t * a.s,
                        @s * a.r + t * a.t
                    )
    end

    def qrst *args
        initialize *args
        self
    end


end


def benchmarks_game_main(n)
  j = 0

  digits = PiDigitSpigot.new

  while n > 0
      if n >= WIDTH
          WIDTH.times {print digits.next!}
          j += WIDTH
      else
          n.times {print digits.next!}
          (WIDTH-n).times {print " "}
          j += n
      end
      puts "\t:"+j.to_s
      n -= WIDTH
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
