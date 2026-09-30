# Conway's Game of Life on a 40x80 torus stored in a flat Array, using Array#count and
# Array#sum with blocks to count neighbors.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_life.rb
require_relative '../lib/harness/loader'

H = 40
W = 80
SIZE = H * W
GENERATIONS = 100

OFFSETS = [-1, 0, 1]

def cell_get(cells, x, y)
  cells[(y % H) * W + (x % W)]
end

def neighbors(cells, x, y)
  OFFSETS.sum { |iy|
    OFFSETS.count { |ix| cell_get(cells, x + ix, y + iy) == 1 }
  }
end

def next_gen(cells)
  Array.new(SIZE) { |i|
    y = i / W
    x = i % W
    n = neighbors(cells, x, y)
    if n == 3
      1
    elsif n == 4 && cells[i] == 1
      1
    else
      0
    end
  }
end

# A deterministic initial pattern: a glider and a blinker
def initial_cells
  cells = Array.new(SIZE) { 0 }

  # Glider at (1,1)
  cells[1 * W + 2] = 1
  cells[2 * W + 3] = 1
  cells[3 * W + 1] = 1
  cells[3 * W + 2] = 1
  cells[3 * W + 3] = 1

  # Blinker at (10,10)
  cells[10 * W + 10] = 1
  cells[10 * W + 11] = 1
  cells[10 * W + 12] = 1

  cells
end

run_benchmark(20) do
  cells = initial_cells
  gen = 0
  while gen < GENERATIONS
    cells = next_gen(cells)
    gen = gen + 1
  end
  # This ruleset lets the initial pattern die out, so no cell is left alive.
  live = cells.count { |cell| cell == 1 }
  raise "incorrect number of live cells: #{live}" unless live == 0
end
