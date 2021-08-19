import std/times
import std/random
import std/math
import std/strutils
import std/tables
import std/enumerate
import std/sequtils
import std/strformat
import std/sugar

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
let ns_hour* = 3600.0
let ns_day* = 86400.0
let ns_month* = 2592000.0
let ns_year* = 31536000.0

# Init the rng
randomize()

# Purpose: Return rounded float strings
# This avoids cases like 1.19999 and just returns 1.2
# Right now it just rounds to 1 decimal place
proc numstring*(num: SomeNumber): string =
  let
    split = split_decimal(float(num))
    n = int(round(split.floatpart * 10))

  if n == 0: $(int(split.intpart))
  else: &"{(int(split.intpart))}.{n}"

# Purpose: Avoid strings like "1 days" when it should be "1 day"
# Send the number of the amount of things. 1 == singular
# Send the singular word and the plural word
proc multistring*(num: int64, s_word, p_word: string): string =
  if num == 1: s_word else: p_word

# Purpose: Turn numbers into english words
# Example: 122 == "one hundred and twenty-two"
# Submit the number that is transformed into words
proc numberwords*(num: SomeNumber): string =
  if "." in $num:
    let
      split = numstring(num).split(".")
      part_1 = numberwords(parseInt(split[0]))
      part_2 = numberwords(parseInt(split[1]))
      
    return &"{part_1} point {part_2}"

  let n = int(num)

  if n < 0: return &"minus {numberwords(-n)}"

  if n < 10:
    return ["zero", "one", "two", "three", "four", "five",
            "six", "seven", "eight", "nine"][n]

  if n < 20:
    return ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
            "sixteen", "seventeen", "eighteen", "nineteen"][n - 10]

  if n < 100:
    let tens = ["twenty", "thirty", "forty", "fifty", "sixty",
            "seventy", "eighty", "ninety"][(int(n / 10) - 2) mod 10]

    if n mod 10 != 0:
      return &"{tens}-{numberwords(n mod 10)}"
    else:
      return tens

  let powers = [("hundred", 2), ("thousand", 3), ("million", 6), ("billion", 9), ("trillion", 12)]

  let ns = $n
  var idx = powers.len - 1

  while true:
    let d = powers[idx][1]

    if ns.len > d:
      let first = numberwords(parseInt(ns[0..^(d + 1)]))
      let second = numberwords(parseInt(ns[^d..^1]))

      if second == "zero":
        return &"{first} {powers[idx][0]}"
      else:
        return &"{first} {powers[idx][0]} {second}"

    idx = idx - 1

# Purpose: Get the sum of letter index values
# a = 1, z = 26. abc = 6
proc countword*(s: string): int =
  var sum = 0

  for c in toSeq(s.strip().tolower()):
    if c != ' ':
      if c in '0'..'9':
        sum += parseInt($c)
      elif ns_lettermap.hasKey(c):
        sum += ns_lettermap[c]

  return sum

# Purpose: Get the timeago message between two dates
# The dates are 2 unix timestamps in seconds
proc timeago*(date_high, date_low: int64): string =
  let diff = float(max(date_high, date_low) - min(date_high, date_low))

  var
    n: int64
    w: string

  if diff < ns_minute:
    n = int64(diff)
    w = multistring(n, "second", "seconds")
  elif diff < ns_hour:
    n = int64(diff / float(60))
    w = multistring(n, "minute", "minutes")
  elif diff < ns_day:
    n = int64(diff / float(60) / float(60))
    w = multistring(n, "hour", "hours")
  elif diff < ns_month:
    n = int64(diff / float(24) / float(60) / float(60))
    w = multistring(n, "day", "days")
  elif diff < ns_year:
    n = int64(diff / float(30) / float(24) / float(60) / float(60))
    w = multistring(n, "month", "months")
  else:
    n = int64(diff / float(365) / float(24) / float(60) / float(60))
    w = multistring(n, "year", "years")

  return &"{n} {w}"

# Purpose: Generate random string tags
# It alternates between vowels and consonants
# Receives a number to set the length
# Receives a boolean to set if vowels go first
proc wordtag*(n: int, vf: bool = true): string =
  var
    s = ""
    m = true

  for i in 1..n:
    if m:
      if vf:
        s &= sample(ns_vowels)
      else:
        s &= sample(ns_consonants)
    else:
      if vf:
        s &= sample(ns_consonants)
      else:
        s &= sample(ns_vowels)
    m = not m

  return s

# Purpose: Turn a string into 'leet speak'
# For instance "maple strikter" -> "m4pl3 s7r1k73r"
proc leetspeak*(s: string): string =
  var s2 = s.tolower()
  s2 = s2.replace("a", "4")
  s2 = s2.replace("e", "3")
  s2 = s2.replace("i", "1")
  s2 = s2.replace("o", "0")
  s2 = s2.replace("t", "7")
  return s2

# Purpose: Add numbers to lines
# 1) This is a line
# 2) This is another line
# Send an array of lines
# And the left and right parts around the number
proc numerate*(lines: openArray[string], left: string, right: string): string =
  var new_array = collect(newSeq):
    for i, s in lines: &"{left}{i + 1}{right} {s}"
  return new_array.join("\n")

# Purpose: Replace token with an incrementing number
# This is __ and this is __
# This is 1 and this is 2
proc insertnum*(s: string, token: string): string =
  var
    ss = s
    ns = ""

  for n in 1..s.count(token):
    let i = ss.find(token)
    if i == -1: break
    ns &= &"{ss[0..(i - 1)]}{n}"
    ss = ss[i + token.len..^1]

  return ns