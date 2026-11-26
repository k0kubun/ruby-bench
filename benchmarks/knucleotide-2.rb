# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by jose fco. gonzalez
# modified by Sokolov Yura
#
# Ported from https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/knucleotide-ruby-2.html

require_relative '../lib/harness/loader'
require 'digest/md5'
require 'stringio'

N = 25_000
EXPECTED_DIGEST = "060ec5a22e127f62b5f26469d19e9d27"

def frecuency( seq,length )
    n, table = seq.length - length + 1, Hash.new(0)
    f, i = nil, nil
    (0 ... length).each do |f|
        (f ... n).step(length) do |i|
            table[seq[i,length]] += 1
        end
    end
    [n,table]

end

def sort_by_freq( seq,length )
    n,table = frecuency( seq,length )
    a, b, v = nil, nil, nil
    table.sort{|a,b| b[1] <=> a[1]}.each do |v|
        puts "%s %.3f" % [v[0].upcase,((v[1]*100).to_f/n)]
    end
    puts
end

def find_seq( seq,s )
    n,table = frecuency( seq,s.length )
    puts "#{table[s].to_s}\t#{s.upcase}"
end

def benchmarks_game_main
  seq = String.new
  line = nil
  line = $stdin.gets while line !~ /^>THREE/
  line = $stdin.gets
  while (line !~ /^>/) & line do
      seq << line.chomp
      line = $stdin.gets
  end

  [1,2].each {|i| sort_by_freq( seq,i ) }

  %w(ggt ggta ggtatt ggtattttaatt ggtattttaatttatagt).each{|s| find_seq( seq,s) }
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
