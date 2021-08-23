import std/[times, random, math, strutils, sequtils, strformat, sugar]
from unicode import title

type NumberMode* = enum
  Number, FloatNumber, NoNumber,
  LowWord, CapWord, UpWord,
  FloatLowWord, FloatCapWord, FloatUpWord

proc is_word(mode: NumberMode): bool =
  mode in [LowWord, CapWord, UpWord]

proc is_f_word(mode: NumberMode): bool =
  mode in [FloatLowWord, FloatCapWord, FloatUpWord] 

proc is_int(mode: NumberMode): bool =
  mode in [Number] or is_word(mode)

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

# '1' = 1
proc numericval(c: '0'..'9'): int = (c.ord - '0'.ord)

# Pre-Declare numberwords
proc numberwords*(num: SomeNumber): string

# Capitalize accordingly
proc capitalizer(text: string, mode: NumberMode): string =
  if mode in [LowWord, FloatLowWord]: toLowerAscii(text)
  elif mode in [CapWord, FloatCapWord]: title(text)
  elif mode in [UpWord, FloatUpWord]: toUpperAscii(text)
  else: text

# Format numbers like 1.1999 to 1.2
proc fnum(num: SomeNumber): string =
  let ns = formatFloat(float(num), format=ffDecimal, precision=1)
  let split = ns.split(".")
  if split.len == 2:
    if split[1] == "0":
      return split[0]
  return ns

# Get the number, or the appropiate word
proc apply_number_mode(num: SomeNumber, mode: NumberMode): string =
  if mode == Number: $(int(num))
  elif mode == FloatNumber: fnum(num)
  elif is_word(mode): capitalizer(numberwords(int(num)), mode)
  elif is_f_word(mode): capitalizer(numberwords(float(num)), mode)
  else: ""

proc multistring*(num: SomeNumber, s_word, p_word: string, mode = Number): string =
  ## Purpose: Avoid strings like "1 days" when it should be "1 day"
  ##
  ## Send the number of the amount of things. 1 == singular
  ##
  ## Send the singular word and the plural word
  ##
  ## Accepts an optional NumberMode
  runnableExamples:
    assert multistring(1, "day", "days") == "1 day"
    assert multistring(3, "cat", "cats") == "3 cats"
    assert multistring(4, "dog", "dogs", NoNumber) == "dogs"
    assert multistring(4, "dog", "dogs", LowWord) == "four dogs"
    assert multistring(4, "DOG", "DoGs", CapWord) == "Four DoGs"
    assert multistring(1, "dog", "dogs", UpWord) == "ONE dog"
    assert multistring(1.2, "thing", "things", Number) == "1 thing"
    assert multistring(1.2, "thing", "things", FloatNumber) == "1.2 things"
    assert multistring(1.2, "thing", "things", LowWord) == "one thing"
    assert multistring(1.2, "thing", "things", FloatUpWord) == "ONE POINT TWO things"

  if is_int(mode):
    result = if int(num) == 1: s_word else: p_word
  else:
    result = if float(num) == 1.0: s_word else: p_word

  if mode != NoNumber:
    let ns = apply_number_mode(num, mode)
    result = &"{ns} {result}"

proc numberwords*(num: SomeNumber): string =
  ## Purpose: Turn numbers into english words
  ##
  ## Submit the number that is transformed into words
  runnableExamples:
    assert numberwords(0) == "zero"
    assert numberwords(10) == "ten"
    assert numberwords(122) == "one hundred twenty-two"
    assert numberwords(3_654_321) == "three million six hundred fifty-four thousand three hundred twenty-one"

  let split = fnum(num).split(".")
  if split.len == 2:
    let a1 = numberwords(parseInt(split[0]))
    let a2 = numberwords(parseInt(split[1]))
    return &"{a1} point {a2}"

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
        result += numericval(c)
      elif c in 'a'..'z':
        result += alphabetpos(c)

proc timeago*(date_1, date_2: int64, mode = Number): string =
  ## Purpose: Get the timeago message between two dates
  ##
  ## Used for simple messages like "posted 1 hour ago"
  ##
  ## The dates are 2 unix timestamps in seconds
  ##
  ## Accepts an optional NumberMode
  runnableExamples:
    assert timeago(0, 10) == "10 seconds"
    assert timeago(0, 140) == "2 minutes"
    assert timeago(0, 140, FloatNumber) == "2.3 minutes"
    assert timeago(0, Hour * 3, LowWord) == "three hours"
    assert timeago(0, Month, CapWord) == "One Month"
    assert timeago(0, Year * 10, UpWord) == "TEN YEARS"

  proc cs(s: string): string =
    if is_word(mode) or is_f_word(mode):
      return capitalizer(s, mode)
    else:
      return s

  let d = float(max(date_1, date_2) - min(date_1, date_2))

  if d < Minute:
    multistring(d, cs("second"), cs("seconds"), mode)
  elif d < Hour:
    multistring(d / 60, cs("minute"), cs("minutes"), mode)
  elif d < Day:
    multistring(d / 60 / 60, cs("hour"), cs("hours"), mode)
  elif d < Month:
    multistring(d / 24 / 60 / 60, cs("day"), cs("days"), mode)
  elif d < Year:
    multistring(d / 30 / 24 / 60 / 60, cs("month"), cs("months"), mode)
  else:
    multistring(d / 365 / 24 / 60 / 60, cs("year"), cs("years"), mode)

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

proc numerate*(lines: openArray[string], left, right: string, mode = Number): string =
  ## Purpose: Add numbers to lines
  ##
  ## Send an array of lines
  ##
  ## And the left and right parts around the number
  ##
  ## Accepts an optional NumberMode
  runnableExamples:
    assert numerate(["This line", "That line"], "", ")") == "1) This line\n2) That line"
    assert numerate(["This line", "That line"], "[", "]", LowWord) == "[one] This line\n[two] That line"
    assert numerate(["This line", "That line"], "[", "]", CapWord) == "[One] This line\n[Two] That line"
    assert numerate(["This line", "That line"], "[", "]", UpWord) == "[ONE] This line\n[TWO] That line"

  let new_array = collect(newSeq):
    for i, s in lines:
      let num = apply_number_mode(i + 1, mode)
      &"{left}{num}{right} {s}"
  return new_array.join("\n")

proc insertnum*(text, token: string, mode = Number): string =
  ## Purpose: Replace token with an incrementing number
  ##
  ## Send the text and token
  ##
  ## Accepts an optional NumberMode
  runnableExamples:
    assert insertnum("This is $ and this is $", "$") == "This is 1 and this is 2"
    assert insertnum("Hello _ and _", "_", LowWord) == "Hello one and two"
    assert insertnum("Hello _ and _", "_", CapWord) == "Hello One and Two"
    assert insertnum("Hello _ and _", "_", UpWord) == "Hello ONE and TWO"

  result = ""; var ss = text

  for n in 1..text.count(token):
    let i = ss.find(token)
    let num = apply_number_mode(n, mode)
    result.add(&"{ss[0..(i - 1)]}{num}")
    ss = ss[i + token.len..^1]