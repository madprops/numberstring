import std/[times, random, math, strutils, sequtils, strformat, sugar]

const
  # Letter constants
  Vowels* = ['a', 'e', 'i', 'o', 'u']
  Consonants* = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z']
  
  # Constants to calculate time
  Minute* = 60
  Hour* = 3_600
  Day* = 86_400
  Month* = 2_592_000
  Year* = 31_536_000
  
  # Constants to calculate number words
  Powers* = [("hundred", 2), ("thousand", 3), ("million", 6), ("billion", 9), ("trillion", 12)]
  Tens* = ["twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
  Teens* = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
  Digits* = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

# Init the random number generator
var randgen = initRand(int(epochTime()))

# a = 1, z = 26
proc alphabetpos(c: 'a'..'z'): int = (c.ord - 'a'.ord) + 1

proc multistring*(num: SomeNumber, s_word, p_word: string): string =
  ## Purpose: Avoid strings like "1 days" when it should be "1 day"
  ## 
  ## Send the number of the amount of things. 1 == singular
  ## 
  ## Send the singular word and the plural word
  runnableExamples:
    assert multistring(1, "day", "days") == "day"
    assert multistring(3, "cat", "cats") == "cats"
    
  if num == 1: s_word else: p_word

proc numberwords*(num: SomeNumber): string =
  ## Purpose: Turn numbers into english words
  ## 
  ## Submit the number that is transformed into words
  runnableExamples:
    assert numberwords(0) == "zero"
    assert numberwords(10) == "ten"
    assert numberwords(122) == "one hundred twenty-two"
    assert numberwords(3_654_321) == "three million six hundred fifty-four thousand three hundred twenty-one"
    
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
  runnableExamples:
    assert countword("a") == 1
    assert countword("z") == 26
    assert countword("abc") == 6
    assert countword("2 abc #$% 2") == 10
    
  result = 0

  for c in toSeq(text.strip().tolower()):
    if c != ' ':
      if c in '0'..'9':
        result += parseInt($c)
      elif c in 'a'..'z':
        result += alphabetpos(c)

proc timeago*(date_1, date_2: int64): string =
  ## Purpose: Get the timeago message between two dates
  ## 
  ## The dates are 2 unix timestamps in seconds
  runnableExamples:
    assert timeago(0, 10) == "10 seconds"
    assert timeago(0, 140) == "2 minutes"
    assert timeago(0, Hour * 3) == "3 hours"
    assert timeago(0, Month) == "1 month"
    assert timeago(0, Year * 10) == "10 years"
    
  let diff = float(max(date_1, date_2) - min(date_1, date_2))
  var n: int64; var w: string

  if diff < Minute:
    n = int64(diff)
    w = multistring(n, "second", "seconds")
  elif diff < Hour:
    n = int64(diff / 60)
    w = multistring(n, "minute", "minutes")
  elif diff < Day:
    n = int64(diff / 60 / 60)
    w = multistring(n, "hour", "hours")
  elif diff < Month:
    n = int64(diff / 24 / 60 / 60)
    w = multistring(n, "day", "days")
  elif diff < Year:
    n = int64(diff / 30 / 24 / 60 / 60)
    w = multistring(n, "month", "months")
  else:
    n = int64(diff / 365 / 24 / 60 / 60)
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
  runnableExamples:
    let wtag = wordtag(3, true)
    assert wtag.len == 3
    assert wtag[0] in Vowels
    assert wtag[1] in Consonants

  result = ""; var m = true

  for i in 1..num:
    result.add(if (m and vowels_first) or 
    (not m and not vowels_first): rng.sample(Vowels)
    else: rng.sample(Consonants))
    m = not m

proc leetspeak*(text: string): string =
  ## Purpose: Turn a string into 'leet speak'
  runnableExamples:
    assert leetspeak("maple strikter") == "m4pl3 s7r1k73r"

  return text.tolower().replace("a", "4")
  .replace("e", "3").replace("i", "1")
  .replace("o", "0").replace("t", "7")

proc numerate*(lines: openArray[string], left, right: string): string =
  ## Purpose: Add numbers to lines
  ## 
  ## Send an array of lines
  ## 
  ## And the left and right parts around the number
  runnableExamples:
    assert numerate(["This line", "That line"], "", ")") == "1) This line\n2) That line"
    
  let new_array = collect(newSeq):
    for i, s in lines: &"{left}{i + 1}{right} {s}"
  return new_array.join("\n")

proc insertnum*(text, token: string): string =
  ## Purpose: Replace token with an incrementing number
  runnableExamples:
    assert insertnum("This is $ and this is $", "$") == "This is 1 and this is 2"

  result = ""; var ss = text

  for n in 1..text.count(token):
    let i = ss.find(token)
    result.add(&"{ss[0..(i - 1)]}{n}")
    ss = ss[i + token.len..^1]