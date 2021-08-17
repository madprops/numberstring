import math
import strutils

# Purpose: Return rounded float strings
# This avoids cases like 1.19999 and just returns 1.2
# Right now it just rounds to 1 decimal place
proc numstring*(num: SomeNumber): string =
  let split = split_decimal(float(num))
  let n = int(round(split.floatpart * 10))
  if n == 0:
    return $(int(split.intpart))
  else:
    return $(int(split.intpart)) & "." & $n

# Purpose: Avoid strings like "1 days" when it should be "1 day"
# Send the number of the amount of things. 1 == singular
# Send an array with the singular word and the plural word
# Send an optional array of other words to consider
proc multistring*(num: SomeNumber, words: openArray[string],
afterwords: openArray[string] = []): string =
  let ns = numstring(num)

  if words.len != 2:
    return ""

  var msg = ns & " "
  let is_singular = float(num) == 1.0

  if is_singular: msg.add(words[0])
  else: msg.add(words[1])

  if afterwords.len == 2:
    msg.add(" ")
    if is_singular: msg.add(afterwords[0])
    else: msg.add(afterwords[1])

  return msg

# Purpose: Turn numbers into english words
# Example: 122 == "one hundred and twenty-two"
# Submit the number that is transformed into words
proc numberword*(num: SomeNumber): string =
  if "." in $num:
    let split = numstring(num).split(".")
    return numberword(parseInt(split[0])) & " dot " & numberword(parseInt(split[1]))
  let n = int(num)
  if n < 0: return "minus " & numberword(-n)
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
      return tens & "-" & numberword(n mod 10)
    else:
      return tens
  if n < 1000:
    if n mod 100 == 0:
      return numberword(int(n / 100)) & " hundred"
    else:
      return numberword(int(n / 100)) & " hundred and " & numberword(n mod 100)
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
      let first = numberword(parseInt(ns[0..^(d + 1)]))
      let second = numberword(parseInt(ns[^d..^1]))
      if second == "zero":
        return first & " " & powers[idx][0]
      else:
        return first & " " & powers[idx][0] & " " & second
    idx = idx - 1