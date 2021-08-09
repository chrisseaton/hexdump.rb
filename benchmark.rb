#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path('../lib',__FILE__))

require 'hexdump'
require 'benchmark/ips'

DATA = ((0..255).map { |b| b.chr }.join) * (1024 * 5)
OUTPUT = Class.new { def <<(data); end }.new
RANDOM = Random.new

puts RUBY_DESCRIPTION

Benchmark.ips do |b|
  [1, 2, 4, 8].each do |word_size|
    dumper = Hexdump::Dumper.new(word_size: word_size)

    b.report("each s=#{word_size}") do
      output = []
      dumper.each(DATA) do |index,numeric,printable|
        output.push index
        output.push numeric
        output.push printable
      end
      output
    end
  end

  [1, 2, 4, 8].each do |word_size|
    dumper = Hexdump::Dumper.new(word_size: word_size)

    b.report("each_word s=#{word_size}") do
      output = []
      dumper.each_word(DATA) do |word|
        output.push word
      end
      output
    end
  end

  b.report('sprintf') do
    sprintf("%.8x  %-48s |%s|\n", 0, "00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f", "................")
  end

  [1, 4].each do |word_size|
    dumper = Hexdump::Dumper.new(word_size: word_size)
    max = 2**(word_size * 8)
    
    b.report("format_numeric s=#{word_size}") do
      dumper.format_numeric(RANDOM.rand(max))
    end
  end

  [1, 4].each do |word_size|
    dumper = Hexdump::Dumper.new(word_size: word_size)
    random = Random.new
    max = 2**(word_size * 8)
    
    b.report("format_printable s=#{word_size}") do
      dumper.format_printable(RANDOM.rand(max))
    end
  end

  b.report('H.d (output)') do
    Hexdump.dump(DATA, :output => OUTPUT)
  end

  b.report('H.d w=256 (output)') do
    Hexdump.dump(DATA, width: 256, output: OUTPUT)
  end

  b.report('H.d a=true (output)') do
    Hexdump.dump(DATA, ascii: true, output: OUTPUT)
  end

  [2, 4, 8].each do |word_size|
    b.report("H.d s=#{word_size} (output)") do
      Hexdump.dump(DATA, word_size: word_size, output: OUTPUT)
    end
  end

  b.report('H.d (block)') do
    Hexdump.dump(DATA) { |index,hex,print| }
  end

  b.report('H.d w=256 (block)') do
    Hexdump.dump(DATA, width: 256) { |index,hex,print| }
  end

  b.report('H.d a=true (block)') do
    Hexdump.dump(DATA, ascii: true) { |index,hex,print| }
  end

  [2, 4, 8].each do |word_size|
    b.report("H.d s=#{word_size} (block)") do
      Hexdump.dump(DATA, word_size: word_size) { |index,hex,print| }
    end
  end
end
