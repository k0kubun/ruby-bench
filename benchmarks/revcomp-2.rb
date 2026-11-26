# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# Contributed by Peter Bjarke Olsen
# Modified by Doug King
# Modified by Joseph LaFata
#
# Ported from https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/revcomp-ruby-2.html

require_relative '../lib/harness/loader'
require 'digest/md5'
require 'stringio'

N = 1_000_000
EXPECTED_DIGEST = "e1f3f9bd58199445c02ae78571a8d62a"

def revcomp(seq)
  seq.reverse!.tr!('wsatugcyrkmbdhvnATUGCYRKMBDHVN','WSTAACGRYMKVHDBNTAACGRYMKVHDBN')
  stringlen=seq.length-1
  0.step(stringlen,60) {|x| print seq[x,60] , "\n"}
end

def benchmarks_game_main
  seq=""
  $stdin.each do |line|
    if line.include? '>'
      if !seq.empty?
        revcomp(seq)
        seq=""
      end
      puts line
    else
      line.chomp!
      seq << line
    end
  end
  revcomp(seq)
end

# The input of this program is the output of the fasta program, generated once here
def fasta_input(n)
  alu = "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA" \
    "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAATACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA" \
    "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGGAGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC" \
    "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"
  seed = 42
  random = lambda do |seq, probability, count|
    count.times.map do
      seed = (seed * 3877 + 29573) % 139968
      v = seed / 139968.0
      j = probability.index { |p| (v -= p) < 0 } || seq.size - 1
      seq[j]
    end.join
  end
  lines = lambda { |s| s.scan(/.{1,60}/).join("\n") + "\n" }
  ">ONE Homo sapiens alu\n" + lines.((alu * (n * 2 / alu.size + 1))[0, n * 2]) +
    ">TWO IUB ambiguity codes\n" +
    lines.(random.("acgtBDHKMNRSVWY", [0.27, 0.12, 0.12, 0.27] + [0.02] * 11, n * 3)) +
    ">THREE Homo sapiens frequency\n" +
    lines.(random.("acgt", [0.3029549426680, 0.1979883004921, 0.1975473066391, 0.3015094502008], n * 5))
end

INPUT = fasta_input(N)

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
  digest = benchmarks_game_run(INPUT) { benchmarks_game_main }
  raise "incorrect output: #{digest}" unless digest == EXPECTED_DIGEST
end
