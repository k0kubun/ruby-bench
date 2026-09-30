# A tiny template engine that scans a template one character at a time and replaces
# {{key}} placeholders with values from a Hash of Strings.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_template.rb
require_relative '../lib/harness/loader'

def render(template, vars)
  result = ""
  i = 0
  while i < template.length
    if i + 1 < template.length && template[i] == "{" && template[i + 1] == "{"
      # Find closing }}
      j = i + 2
      while j + 1 < template.length
        if template[j] == "}" && template[j + 1] == "}"
          break
        end
        j = j + 1
      end
      key = template[i + 2, j - i - 2]
      if vars.has_key?(key)
        result = result + vars[key]
      else
        result = result + "{{" + key + "}}"
      end
      i = j + 2
    else
      result = result + template[i]
      i = i + 1
    end
  end
  result
end

TEMPLATE = "Hello {{name}}! You are {{age}} years old. Welcome to {{city}}."
VARS = {"name" => "Matz", "age" => "58", "city" => "Matsue"}
EXPECTED = "Hello Matz! You are 58 years old. Welcome to Matsue."
RENDERS = 25_000

run_benchmark(20) do
  result = ""
  i = 0
  while i < RENDERS
    result = render(TEMPLATE, VARS)
    i = i + 1
  end
  raise "incorrect output: #{result}" unless result == EXPECTED
end
