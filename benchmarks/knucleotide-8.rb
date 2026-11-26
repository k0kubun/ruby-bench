# The Computer Language Benchmarks Game
#   https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
#   Naive transliteration from bearophile's program
#   contributed by Isaac Gouy
#
# Ported from https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/knucleotide-ruby-8.html

require_relative '../lib/harness/loader'
require 'digest/md5'
require 'stringio'

N = 25_000
EXPECTED_DIGEST = "060ec5a22e127f62b5f26469d19e9d27"

def seq_lines
   lines = Array.new
   loop do
      line = $stdin.gets()
      break if line.nil? | line&.start_with?(">THREE")
   end
   loop do
      line = $stdin.gets()
      break if line.nil? | line&.start_with?(">")
      lines << line.chomp
   end
   return lines
end

def base_counts(bases, seq)
   counts = {}
   size = seq.length + 1 - bases
   for i in 0 ... size
      nucleo = seq[i...i+bases]
      if counts.key?(nucleo)
         counts[nucleo] += 1
      else
         counts[nucleo] = 1
      end
   end
   return counts
end

def sorted_freq(bases, seq)
   kv_ = base_counts(bases, seq)
   size = seq.length + 1 - bases
   sorted_ = kv_.to_a.sort {|a,b| b.last <=> a.last}
   return sorted_.collect {|a| [a.first, 100.0 * a.last  / size]}
end

def specific_count(code, seq)
    return base_counts(code.length, seq)[code]
end

def main
   lines = seq_lines
   seq = lines.map {|s| s.upcase!}.join

   for base in 1..2
      for kv in sorted_freq(base, seq)
         puts "%s %.3f" % [kv[0], kv[1]]
      end
      puts
   end

   for code in ["GGT", "GGTA", "GGTATT",
         "GGTATTTTAATT", "GGTATTTTAATTTATAGT"]
      puts "#{specific_count(code, seq).to_s}\t#{code}"
   end
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
  digest = benchmarks_game_run(INPUT) { main }
  raise "incorrect output: #{digest}" unless digest == EXPECTED_DIGEST
end
