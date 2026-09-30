# Left-leaning red-black tree: inserts 10,000 keys with recursive rebalancing rotations,
# eleven times over.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_rbtree.rb
require_relative '../lib/harness/loader'

class RBNode
  attr_accessor :key, :left, :right, :red
  def initialize(key)
    @key = key
    @left = nil
    @right = nil
    @red = 1
    @tag = "rb"
  end
end

def is_red(node)
  if node.nil?
    return 0
  end
  node.red
end

def rotate_left(h)
  x = h.right
  h.right = x.left
  x.left = h
  x.red = h.red
  h.red = 1
  x
end

def rotate_right(h)
  x = h.left
  h.left = x.right
  x.right = h
  x.red = h.red
  h.red = 1
  x
end

def flip_colors(h)
  h.red = 1
  h.left.red = 0
  h.right.red = 0
end

def insert_node(h, key)
  if h.nil?
    return RBNode.new(key)
  end
  if key < h.key
    h.left = insert_node(h.left, key)
  elsif key > h.key
    h.right = insert_node(h.right, key)
  end
  if is_red(h.right) == 1 && is_red(h.left) == 0
    h = rotate_left(h)
  end
  if is_red(h.left) == 1
    if h.left != nil && is_red(h.left.left) == 1
      h = rotate_right(h)
    end
  end
  if is_red(h.left) == 1 && is_red(h.right) == 1
    flip_colors(h)
  end
  h
end

def count_nodes(h)
  if h.nil?
    return 0
  end
  1 + count_nodes(h.left) + count_nodes(h.right)
end

def build_tree(offset)
  # Start from a typed node so that ahead-of-time compilers can infer the type of a nil root
  root = RBNode.new(0)
  root = nil
  i = 0
  while i < 10000
    key = (i * 7919 + offset) % 100000
    root = insert_node(root, key)
    i = i + 1
  end
  root.red = 0
  root
end

run_benchmark(20) do
  root = build_tree(1)
  raise "incorrect node count" unless count_nodes(root) == 10000

  # Rebuild 10 times
  j = 0
  while j < 10
    root = build_tree(j)
    j = j + 1
  end
  raise "incorrect node count" unless count_nodes(root) == 10000
end
