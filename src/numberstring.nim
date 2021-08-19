

import std/times
import std/random
import std/math
import std/strutils
import std/sequtils
import std/strformat
import std/sugar

let
  # Letter constants
  ns_vowels = ['a', 'e', 'i', 'o', 'u']
  ns_consonants = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z']

let
  # Constants to calculate time
  ns_minute = 60.0
  ns_hour = 3_600.0
  ns_day = 86_400.0
  ns_month = 2_592_000.0
  ns_year = 31_536_000.0

let
  # Constants to calculate number words
  ns_powers = [("hundred", 2), ("thousand", 3), ("million", 6), ("billion", 9), ("trillion", 12)]
  ns_tens = ["twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
  ns_teens = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
  ns_digits = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

# Init the rng
randomize()

# a = 1, z = 26
proc alphabetpos(c: 'a'..'z'): int = (c.ord - 'a'.ord) + 1

proc multistring*(num: int64, s_word, p_word: string): string =
  ## Purpose: Avoid strings like "1 days" when it should be "1 day"
  ## 
  ## Send the number of the amount of things. 1 == singular
  ## 
  ## Send the singular word and the plural word
  if num == 1: s_word else: p_word

proc numberwords*(num: SomeNumber): string =
  ## Purpose: Turn numbers into english words
  ## 
  ## Example: 122 == "one hundred twenty-two"
  ## 
  ## Submit the number that is transformed into words
  let n = int(num)
  if n < 0: return &"minus {numberwords(-n)}"
  if n < 10: return ns_digits[n]
  if n < 20: return ns_teens[n - 10]

  if n < 100:
    let tens = ns_tens[(int(n / 10) - 2) mod 10]
    if n mod 10 != 0:
      return &"{tens}-{numberwords(n mod 10)}"
    else:
      return tens

  let ns = $n
  var idx = ns_powers.len - 1

  while true:
    let d = ns_powers[idx][1]

    if ns.len > d:
      let 
        first = numberwords(parseInt(ns[0..^(d + 1)]))
        second = numberwords(parseInt(ns[^d..^1]))
        dz = ns_powers[idx][0]

      var s = &"{first} {dz}"
      if second != "zero": s.add(&" {second}")
      return s

    dec(idx)

proc countword*(s: string): int =
  ## Purpose: Get the sum of letter index values
  ## 
  ## a = 1, z = 26. abc = 6
  var sum = 0

  for c in toSeq(s.strip().tolower()):
    if c != ' ':
      if c in '0'..'9':
        sum += parseInt($c)
      elif c in 'a'..'z':
        sum += alphabetpos(c)

  return sum

proc timeago*(date_high, date_low: int64): string =
  ## Purpose: Get the timeago message between two dates
  ## 
  ## The dates are 2 unix timestamps in seconds
  let diff = float(max(date_high, date_low) - min(date_high, date_low))
  var n: int64; var w: string

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

proc wordtag*(n: int, vf: bool = true): string =
  ## Purpose: Generate random string tags
  ## 
  ## It alternates between vowels and consonants
  ## 
  ## Receives a number to set the length
  ## 
  ## Receives a boolean to set if vowels go first
  var s = ""; var m = true

  for i in 1..n:
    s &= (if (m and vf) or (not m and not vf): sample(ns_vowels)
    else: sample(ns_consonants))
    m = not m

  return s

proc leetspeak*(s: string): string =
  ## Purpose: Turn a string into 'leet speak'
  ## 
  ## For instance "maple strikter" -> "m4pl3 s7r1k73r"
  return s.tolower().replace("a", "4")
  .replace("e", "3").replace("i", "1")
  .replace("o", "0").replace("t", "7")

proc numerate*(lines: openArray[string], left: string, right: string): string =
  ## Purpose: Add numbers to lines
  ## 
  ## 1) This is a line
  ## 
  ## 2) This is another line
  ## 
  ## Send an array of lines
  ## 
  ## And the left and right parts around the number
  let new_array = collect(newSeq):
    for i, s in lines: &"{left}{i + 1}{right} {s}"
  return new_array.join("\n")

proc insertnum*(s: string, token: string): string =
  ## Purpose: Replace token with an incrementing number
  ## 
  ## This is __ and this is __
  ## 
  ## This is 1 and this is 2
  var ss = s; var ns = ""

  for n in 1..s.count(token):
    let i = ss.find(token)
    ns &= &"{ss[0..(i - 1)]}{n}"
    ss = ss[i + token.len..^1]

  return ns