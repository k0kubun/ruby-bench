# CSV processing: splits 5,000 comma-separated lines into fields, converts salaries with
# String#to_i and aggregates them into totals and a Hash of department counts.
# Ported from https://github.com/matz/spinel/blob/master/benchmark/bm_csv_process.rb
require_relative '../lib/harness/loader'

def generate_lines(n)
  depts = ["eng", "sales", "hr", "ops"]
  names = ["alice", "bob", "carol", "dave", "eve"]
  lines = ["name,dept,salary,age"]
  i = 0
  while i < n
    name = names[i % 5]
    dept = depts[i % 4]
    salary = 30000 + (i * 1337) % 70000
    age = 22 + i % 40
    lines.push(name + "," + dept + "," + salary.to_s + "," + age.to_s)
    i = i + 1
  end
  lines
end

# Returns [total salary, number of high earners, department counts]
def process_lines(lines)
  total_salary = 0
  high_earners = 0
  dept_counts = {}
  i = 1
  while i < lines.length
    fields = lines[i].split(",")
    if fields.length >= 4
      dept = fields[1]
      salary = fields[2].to_i
      total_salary = total_salary + salary
      if salary >= 80000
        high_earners = high_earners + 1
      end
      if dept_counts.has_key?(dept)
        dept_counts[dept] = dept_counts[dept] + 1
      else
        dept_counts[dept] = 1
      end
    end
    i = i + 1
  end
  [total_salary, high_earners, dept_counts]
end

LINES = generate_lines(5000)
PASSES = 100

run_benchmark(20) do
  total_salary = 0
  high_earners = 0
  dept_counts = {}
  i = 0
  while i < PASSES
    total_salary, high_earners, dept_counts = process_lines(LINES)
    i = i + 1
  end
  raise "incorrect total salary: #{total_salary}" unless total_salary == 324_527_500
  raise "incorrect high earners: #{high_earners}" unless high_earners == 1421
  raise "incorrect department counts" unless dept_counts["eng"] == 1250 && dept_counts.size == 4
end
