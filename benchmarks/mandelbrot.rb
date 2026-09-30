# The Computer Language Benchmarks Game: mandelbrot
# Renders a Mandelbrot set bitmap with Float arithmetic in nested while loops, packing
# one bit per pixel.
#
# contributed by Karl von Laudermann
# modified by Jeremy Echols
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_so_mandelbrot.rb
require_relative '../lib/harness/loader'

SIZE = 400

# Returns the rendered PBM bitmap rows as an Array of byte values
def mandelbrot(size)
  bytes = []
  iter = 49
  limit_squared = 4.0

  byte_acc = 0
  bit_num = 0

  count_size = size - 1

  y = 0
  while y <= count_size
    x = 0
    while x <= count_size
      zr = 0.0
      zi = 0.0
      cr = (2.0*x/size)-1.5
      ci = (2.0*y/size)-1.0
      escape = false

      i = 0
      while i <= iter
        tr = zr*zr - zi*zi + cr
        ti = 2*zr*zi + ci
        zr = tr
        zi = ti

        if (zr*zr+zi*zi) > limit_squared
          escape = true
          break
        end
        i += 1
      end

      byte_acc = (byte_acc << 1) | (escape ? 0b0 : 0b1)
      bit_num += 1

      # Code is very similar for these cases, but using separate blocks
      # ensures we skip the shifting when it's unnecessary, which is most cases.
      if (bit_num == 8)
        bytes.push(byte_acc)
        byte_acc = 0
        bit_num = 0
      elsif (x == count_size)
        byte_acc <<= (8 - bit_num)
        bytes.push(byte_acc)
        byte_acc = 0
        bit_num = 0
      end
      x += 1
    end
    y += 1
  end
  bytes
end

run_benchmark(20) do
  bytes = mandelbrot(SIZE)
  raise "incorrect bitmap size: #{bytes.length}" unless bytes.length == SIZE * SIZE / 8
  raise "incorrect bitmap checksum: #{bytes.sum}" unless bytes.sum == 2_021_333
end
