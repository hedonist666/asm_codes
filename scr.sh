#!/usr/bin/env ruby


ARGV[0] =~ /(.*)\.asm/
fn = $1

res = `fasm #{ARGV[0]} && ./#{fn} suka SUKA`
puts res
