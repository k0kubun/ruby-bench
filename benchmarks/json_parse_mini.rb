# A minimal recursive-descent JSON parser that walks the input one character at a time
# through String#[] and compares single-character Strings.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_json_parse.rb
require_relative '../lib/harness/loader'

class MiniJSONParser
  def initialize(input)
    @input = input
    @pos = 0
  end

  def parse
    skip_ws
    parse_value
  end

  def skip_ws
    while @pos < @input.length
      c = @input[@pos]
      if c == " " || c == "\n" || c == "\t" || c == "\r"
        @pos = @pos + 1
      else
        break
      end
    end
  end

  def peek
    if @pos < @input.length
      @input[@pos]
    else
      ""
    end
  end

  def advance
    c = @input[@pos]
    @pos = @pos + 1
    c
  end

  def parse_value
    skip_ws
    c = peek
    if c == "\""
      return parse_string
    end
    if c == "["
      return parse_array
    end
    if c == "{"
      return parse_object
    end
    if c == "t"
      @pos = @pos + 4
      return "true"
    end
    if c == "f"
      @pos = @pos + 5
      return "false"
    end
    if c == "n"
      @pos = @pos + 4
      return "null"
    end
    parse_number
  end

  def parse_string
    advance  # skip "
    result = ""
    while peek != "\""
      result = result + advance
    end
    advance  # skip "
    result
  end

  def parse_number
    start = @pos
    if peek == "-"
      @pos = @pos + 1
    end
    while @pos < @input.length
      c = @input[@pos]
      if c >= "0" && c <= "9"
        @pos = @pos + 1
      elsif c == "."
        @pos = @pos + 1
      else
        break
      end
    end
    @input[start, @pos - start]
  end

  # Returns the number of items as a String
  def parse_array
    advance  # skip [
    items = 0
    skip_ws
    if peek != "]"
      parse_value
      items = items + 1
      skip_ws
      while peek == ","
        advance
        parse_value
        items = items + 1
        skip_ws
      end
    end
    advance  # skip ]
    items.to_s
  end

  # Returns the number of keys as a String
  def parse_object
    advance  # skip {
    keys = 0
    skip_ws
    if peek != "}"
      parse_string
      skip_ws
      advance  # skip :
      parse_value
      keys = keys + 1
      skip_ws
      while peek == ","
        advance
        skip_ws
        parse_string
        skip_ws
        advance  # skip :
        parse_value
        keys = keys + 1
        skip_ws
      end
    end
    advance  # skip }
    keys.to_s
  end
end

JSON_OBJECT = '{"name": "spinel", "version": 1, "features": ["aot", "gc", "fiber"], "fast": true}'
JSON_ARRAY = '[1, 2, [3, 4, [5]], "hello", null, true, false]'
PARSES = 10_000

run_benchmark(20) do
  result = ""
  i = 0
  while i < PARSES
    result = MiniJSONParser.new(JSON_OBJECT).parse
    i = i + 1
  end
  raise "incorrect key count: #{result}" unless result == "4"
  raise "incorrect item count" unless MiniJSONParser.new(JSON_ARRAY).parse == "7"
end
