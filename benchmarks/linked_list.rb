# Singly linked list of 100,000 nodes: builds it, reverses it in place and sums it,
# exercising attr_accessor reads and writes on small objects.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_linked_list.rb
require_relative '../lib/harness/loader'

class LNode
  attr_accessor :val, :nxt
  def initialize(val)
    @val = val
    @nxt = nil
    @tag = "ln"
  end
end

def list_push(head, val)
  node = LNode.new(val)
  node.nxt = head
  node
end

def list_length(head)
  n = 0
  cur = head
  while cur != nil
    n = n + 1
    cur = cur.nxt
  end
  n
end

def list_reverse(head)
  prev = nil
  cur = head
  while cur != nil
    nxt = cur.nxt
    cur.nxt = prev
    prev = cur
    cur = nxt
  end
  prev
end

def list_sum(head)
  s = 0
  cur = head
  while cur != nil
    s = s + cur.val
    cur = cur.nxt
  end
  s
end

def build_list(n)
  head = nil
  i = 0
  while i < n
    head = list_push(head, i)
    i = i + 1
  end
  head
end

LENGTH = 100_000

run_benchmark(20) do
  head = build_list(LENGTH)
  raise "incorrect length" unless list_length(head) == LENGTH
  raise "incorrect sum" unless list_sum(head) == 4_999_950_000

  # Reverse and sum
  head = list_reverse(head)
  raise "incorrect sum" unless list_sum(head) == 4_999_950_000

  # Rebuild + reverse 10 times
  j = 0
  while j < 10
    head = list_reverse(build_list(LENGTH))
    j = j + 1
  end
  raise "incorrect length" unless list_length(head) == LENGTH
end
