# Word count: reads a 5,000-line file with IO#each_line, splits each line and counts the
# first word of each line in a Hash.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_io_wordcount.rb
require_relative '../lib/harness/loader'

WORDS = ["the", "quick", "brown", "fox", "jumps", "over", "lazy", "dog"]
PATH = File.join(ENV["TMPDIR"] || "/tmp", "ruby_bench_io_wordcount_#{Process.pid}.txt")
PASSES = 100

# Write test data: word frequency file
File.open(PATH, "w") do |f|
  i = 0
  while i < 5000
    w = WORDS[i % 8]
    f.puts(w + " " + (i % 100).to_s)
    i = i + 1
  end
end

def count_words(path)
  counts = {}
  File.open(path, "r") do |f|
    f.each_line do |line|
      parts = line.strip.split(" ")
      if parts.length >= 1
        word = parts[0]
        if counts.has_key?(word)
          counts[word] = counts[word] + 1
        else
          counts[word] = 1
        end
      end
    end
  end
  counts
end

run_benchmark(20) do
  counts = {}
  i = 0
  while i < PASSES
    counts = count_words(PATH)
    i = i + 1
  end
  raise "incorrect counts" unless counts.size == 8 && counts["the"] == 625
end

File.delete(PATH)
