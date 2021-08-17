import std/math
import std/strutils
import std/tables
import std/enumerate
import std/sequtils

# Hold letters and their 1 based position
# a = 1, z = 26
var lettermap = initTable[char, int]()
for i, c in enumerate('a'..'z'): lettermap[c] = i + 1

# Purpose: Return rounded float strings
# This avoids cases like 1.19999 and just returns 1.2
# Right now it just rounds to 1 decimal place
proc numstring*(num: SomeNumber): string =
  let split = split_decimal(float(num))
  let n = int(round(split.floatpart * 10))
  if n == 0: $(int(split.intpart))
  else: $(int(split.intpart)) & "." & $n

# Purpose: Avoid strings like "1 days" when it should be "1 day"
# Send the number of the amount of things. 1 == singular
# Send the singular word and the plural word
proc multistring*(num: SomeNumber, s_word, p_word: string): string =
  if float(num) == 1.0: s_word else: p_word

# Purpose: Turn numbers into english words
# Example: 122 == "one hundred and twenty-two"
# Submit the number that is transformed into words
proc numberwords*(num: SomeNumber): string =
  if "." in $num:
    let split = numstring(num).split(".")
    return numberwords(parseInt(split[0])) & " point " & numberwords(parseInt(split[1]))

  let n = int(num)

  if n < 0: return "minus " & numberwords(-n)

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
      return tens & "-" & numberwords(n mod 10)
    else:
      return tens

  if n < 1000:
    if n mod 100 == 0:
      return numberwords(int(n / 100)) & " hundred"
    else:
      return numberwords(int(n / 100)) & " hundred and " & numberwords(n mod 100)

  let powers = [("thousand", 3), ("million", 6),
            ("billion", 9), ("trillion", 12), ("quadrillion", 15),
            ("quintillion", 18), ("sextillion", 21), ("septillion", 24),
            ("octillion", 27), ("nonillion", 30), ("decillion", 33),
            ("undecillion", 36), ("duodecillion", 39), ("tredecillion", 42),
            ("quattuordecillion", 45), ("quindecillion", 48),
            ("sexdecillion", 51), ("eptendecillion", 54),
            ("octadecillion", 57), ("novemdecillion", 61),
            ("vigintillion", 64)]

  let ns = $n
  var idx = powers.len - 1

  while true:
    let d = powers[idx][1]

    if ns.len > d:
      let first = numberwords(parseInt(ns[0..^(d + 1)]))
      let second = numberwords(parseInt(ns[^d..^1]))

      if second == "zero":
        return first & " " & powers[idx][0]
      else:
        return first & " " & powers[idx][0] & " " & second

    idx = idx - 1

# Purpose: Get the sum of letter index values
# a = 1, z = 26. abc = 6
proc countword*(s: string): int =
  var sum = 0
  let s_low = s.strip().tolower()

  for c in toSeq(s_low):
    if c != ' ': 
      if c in '0'..'9':
        sum += parseInt($c)
      elif lettermap.hasKey(c):
        sum += lettermap[c]

  return sum