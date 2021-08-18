import std/math
import std/strutils
import std/tables
import std/enumerate
import std/sequtils
import std/strformat

# Hold letters and their 1 based position
# a = 1, z = 26
var lettermap = initTable[char, int]()
for i, c in enumerate('a'..'z'): lettermap[c] = i + 1

# Constants to calculate time
let t_minute = 60.0
let t_hour = 3600.0
let t_day = 86400.0
let t_month = 2592000.0
let t_year = 31536000.0

# Purpose: Return rounded float strings
# This avoids cases like 1.19999 and just returns 1.2
# Right now it just rounds to 1 decimal place
proc numstring*(num: SomeNumber): string =
  let split = split_decimal(float(num))
  let n = int(round(split.floatpart * 10))
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
    let split = numstring(num).split(".")
    let part_1 = numberwords(parseInt(split[0]))
    let part_2 = numberwords(parseInt(split[1]))
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
      elif lettermap.hasKey(c):
        sum += lettermap[c]

  return sum

# Purpose: Get the timeago message between two dates
# The dates are 2 unix seconds
# First is the highest, second is the lowest
proc timeago*(date_high, date_low: int64): string =
  let diff = float(date_high - date_low)

  if diff < t_minute:
    return "just now"
  else:
    var n: int64
    var w: string

    if diff < t_hour:
      n = int64(diff / float(60))
      w = multistring(n, "minute", "minutes")
    elif diff >= t_hour and diff < t_day:
      n = int64(diff / float(60) / float(60))
      w = multistring(n, "hour", "hours")
    elif diff >= t_day and diff < t_month:
      n = int64(diff / float(24) / float(60) / float(60))
      w = multistring(n, "day", "days")
    elif diff >= t_month and diff < t_year:
      n = int64(diff / float(30) / float(24) / float(60) / float(60))
      w = multistring(n, "month", "months")
    elif diff >= t_year:
      n = int64(diff / float(365) / float(24) / float(60) / float(60))
      w = multistring(n, "year", "years")

    return &"{n} {w} ago"