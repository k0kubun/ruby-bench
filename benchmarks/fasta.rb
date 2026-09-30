# The Computer Language Benchmarks Game: fasta
# Generates DNA sequences with a linear congruential generator, one character at a time.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_fasta.rb
require_relative '../lib/harness/loader'

IM = 139968
IA = 3877
IC = 29573

$last = 42

def gen_random(max)
  $last = ($last * IA + IC) % IM
  max * $last / IM
end

def make_repeat_fasta(id, desc, src, n, out)
  out.push(">" + id + " " + desc)
  k = 0
  i = 0
  while i < n
    len = 60
    if n - i < 60
      len = n - i
    end
    line = ""
    j = 0
    while j < len
      line = line + src[k % src.length]
      k = k + 1
      j = j + 1
    end
    out.push(line)
    i = i + len
  end
end

def make_random_fasta(id, desc, table_chars, table_probs, n, out)
  out.push(">" + id + " " + desc)
  # Build cumulative probabilities
  cp = Array.new(table_probs.length, 0.0)
  sum = 0.0
  k = 0
  while k < table_probs.length
    sum = sum + table_probs[k]
    cp[k] = sum
    k = k + 1
  end
  i = 0
  while i < n
    len = 60
    if n - i < 60
      len = n - i
    end
    line = ""
    j = 0
    while j < len
      r = gen_random(1.0)
      # Linear search
      c = 0
      while c < cp.length - 1
        if r < cp[c]
          break
        end
        c = c + 1
      end
      line = line + table_chars[c]
      j = j + 1
    end
    out.push(line)
    i = i + len
  end
end

ALU = "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGACCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAATACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCAGCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGGAGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCCAGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAAAA"

IUB_CHARS = ["a", "c", "g", "t", "B", "D", "H", "K", "M", "N", "R", "S", "V", "W", "Y"]
IUB_PROBS = [0.27, 0.12, 0.12, 0.27, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02]

HOMO_CHARS = ["a", "c", "g", "t"]
HOMO_PROBS = [0.3029549426680, 0.1979883004921, 0.1975473066391, 0.3015094502008]

N = 100_000

def fasta(n)
  $last = 42
  out = []
  make_repeat_fasta("ONE", "Homo sapiens alu", ALU, n * 2, out)
  make_random_fasta("TWO", "IUB ambiguity codes", IUB_CHARS, IUB_PROBS, n * 3, out)
  make_random_fasta("THREE", "Homo sapiens frequency", HOMO_CHARS, HOMO_PROBS, n * 5, out)
  out
end

run_benchmark(20) do
  out = fasta(N)
  raise "incorrect number of lines: #{out.length}" unless out.length == 16671
  raise "incorrect last line: #{out[-1]}" unless out[-1] == "atattccatctttgtgtgct"
end
