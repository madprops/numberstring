import tables

# Hold letters and their 1 based position
# a = 1, z = 26
let ns_lettermap* = block:
  var temp = initTable[char, int]()
  for i, c in enumerate('a'..'z'): temp[c] = i + 1
  temp

# List of vowel letters
let ns_vowels* = ['a', 'e', 'i', 'o', 'u']

# List of consonant letters
let ns_consonants* = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm',
                  'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z']

# Constants to calculate time
let ns_minute* = 60.0
let ns_hour* = 3_600.0
let ns_day* = 86_400.0
let ns_month* = 2_592_000.0
let ns_year* = 31_536_000.0

# Constants to calculate number words
let ns_powers* = [("hundred", 2), ("thousand", 3), ("million", 6), ("billion", 9), ("trillion", 12)]
let ns_tens* = ["twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
let ns_teens* = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
let ns_digits* = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]