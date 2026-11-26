# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# regex-dna program contributed by jose fco. gonzalez
# corrected to use regex instead of string substitution
# array not dictionary by Isaac Gouy
#
# Ported from https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/regexredux-ruby-9.html

require_relative '../lib/harness/loader'
require 'digest/md5'
require 'stringio'

N = 100_000
EXPECTED_DIGEST = "5ba8ea0514d760533c16b6e63722391a"

def benchmarks_game_main
  seq = $stdin.readlines.join
  ilen = seq.size

  seq.gsub!(/>.*\n|\n/,"")
  clen = seq.length

  [
    /agggtaaa|tttaccct/i,
    /[cgt]gggtaaa|tttaccc[acg]/i,
    /a[act]ggtaaa|tttacc[agt]t/i,
    /ag[act]gtaaa|tttac[agt]ct/i,
    /agg[act]taaa|ttta[agt]cct/i,
    /aggg[acg]aaa|ttt[cgt]ccct/i,
    /agggt[cgt]aa|tt[acg]accct/i,
    /agggta[cgt]a|t[acg]taccct/i,
    /agggtaa[cgt]|[acg]ttaccct/i
  ].each {|f| puts "#{f.source} #{seq.scan(f).size}" }

  # ruby 1.8.7: to iterate in-order use array not dictionary
  [
  [/tHa[Nt]/, '<4>'], [/aND|caN|Ha[DS]|WaS/, '<3>'], [/a[NSt]|BY/, '<2>'],
  [/<[^>]*>/, '|'], [/\|[^|][^|]*\|/, '-']
  ].each { |f,r| seq.gsub!(f,r) }

  puts
  puts ilen
  puts clen
  puts seq.length
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
