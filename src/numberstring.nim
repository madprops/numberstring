import std/[times, random, math, strutils, sequtils, strformat, sugar]

const
  # Letter constants
  Vowels* = ['a', 'e', 'i', 'o', 'u']
  Consonants* = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z']
  
  # Constants to calculate time
  Minute = 60.0
  Hour = 3_600.0
  Day = 86_400.0
  Month = 2_592_000.0
  Year = 31_536_000.0
  
  # Constants to calculate number words
  Powers = [("hundred", 2), ("thousand", 3), ("million", 6), ("billion", 9), ("trillion", 12)]
  Tens = ["twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
  Teens = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
  Digits = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

# Init the random number generator
var randgen = initRand(int(epochTime()))

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
  if n < 10: return Digits[n]
  if n < 20: return Teens[n - 10]

  if n < 100:
    result = Tens[(int(n / 10) - 2) mod 10]
    if n mod 10 != 0: result.add(&"-{numberwords(n mod 10)}")
    return

  let ns = $n
  var idx = Powers.len - 1

  while true:
    let d = Powers[idx][1]

    if ns.len > d:
      let 
        first = numberwords(parseInt(ns[0..^(d + 1)]))
        second = numberwords(parseInt(ns[^d..^1]))
        dz = Powers[idx][0]

      result = &"{first} {dz}"
      if second != "zero": result.add(&" {second}")
      return

    dec(idx)

proc countword*(text: string): int =
  ## Purpose: Get the sum of letter index values
  ## 
  ## a = 1, z = 26. abc = 6
  result = 0

  for c in toSeq(text.strip().tolower()):
    if c != ' ':
      if c in '0'..'9':
        result += parseInt($c)
      elif c in 'a'..'z':
        result += alphabetpos(c)

proc timeago*(date_high, date_low: int64): string =
  ## Purpose: Get the timeago message between two dates
  ##
  ## For instance "33 minutes" (which is the diff of the dates)
  ## 
  ## This is for cases where you need to show a simple message
  ## 
  ## Like "posted 1 hour ago"
  ## 
  ## The dates are 2 unix timestamps in seconds
  let diff = float(max(date_high, date_low) - min(date_high, date_low))
  var n: int64; var w: string

  if diff < Minute:
    n = int64(diff)
    w = multistring(n, "second", "seconds")
  elif diff < Hour:
    n = int64(diff / float(60))
    w = multistring(n, "minute", "minutes")
  elif diff < Day:
    n = int64(diff / float(60) / float(60))
    w = multistring(n, "hour", "hours")
  elif diff < Month:
    n = int64(diff / float(24) / float(60) / float(60))
    w = multistring(n, "day", "days")
  elif diff < Year:
    n = int64(diff / float(30) / float(24) / float(60) / float(60))
    w = multistring(n, "month", "months")
  else:
    n = int64(diff / float(365) / float(24) / float(60) / float(60))
    w = multistring(n, "year", "years")

  return &"{n} {w}"

proc wordtag*(num: int, vowels_first: bool = true, rng: var Rand = randgen): string =
  ## Purpose: Generate random string tags
  ## 
  ## It alternates between vowels and consonants
  ## 
  ## Receives a number to set the length
  ## 
  ## Receives a boolean to set if vowels go first
  ## 
  ## A rand seed can be provided as an extra argument
  result = ""; var m = true

  for i in 1..num:
    result.add(if (m and vowels_first) or 
    (not m and not vowels_first): rng.sample(Vowels)
    else: rng.sample(Consonants))
    m = not m

proc leetspeak*(text: string): string =
  ## Purpose: Turn a string into 'leet speak'
  ## 
  ## For instance "maple strikter" -> "m4pl3 s7r1k73r"
  return text.tolower().replace("a", "4")
  .replace("e", "3").replace("i", "1")
  .replace("o", "0").replace("t", "7")

proc numerate*(lines: openArray[string], left, right: string): string =
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

proc insertnum*(text, token: string): string =
  ## Purpose: Replace token with an incrementing number
  ## 
  ## This is __ and this is __
  ## 
  ## This is 1 and this is 2
  result = ""; var ss = text

  for n in 1..text.count(token):
    let i = ss.find(token)
    result.add(&"{ss[0..(i - 1)]}{n}")
    ss = ss[i + token.len..^1]