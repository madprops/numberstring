import std/[times, random, math, strutils, sequtils, strformat, sugar]

## Some procs receive a "num_mode" string which can be the following:
## 
## num: Use a number literal like 2
## 
## word: Use the number word like two
## 
## Word: Use the number word like Two
## 
## WORD: Use the number word like TWO
## 
## None: Don't show anything

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
proc capitalizer(text, mode: string): string =
  if mode == "Word": capitalizeAscii(text)
  elif mode == "WORD": toUpperAscii(text)
  elif mode == "word": toLowerAscii(text)
  else: text

# Get the number, or the appropiate word
proc apply_num_mode(num: SomeNumber, num_mode: string): string =
  if num_mode == "num": $num
  elif num_mode.toLower == "word": capitalizer(numberwords(num), num_mode)
  else: ""

proc multistring*(num: SomeNumber, s_word, p_word: string, num_mode: string = "num"): string =
  ## Purpose: Avoid strings like "1 days" when it should be "1 day"
  ## 
  ## Send the number of the amount of things. 1 == singular
  ## 
  ## Send the singular word and the plural word
  ## 
  ## Accepts a num_mode string
  runnableExamples:
    assert multistring(1, "day", "days") == "1 day"
    assert multistring(3, "cat", "cats") == "3 cats"
    assert multistring(4, "dog", "dogs", "none") == "dogs"
    assert multistring(4, "dog", "dogs", "word") == "four dogs"
    assert multistring(4, "dog", "dogs", "Word") == "Four Dogs"
    assert multistring(1, "dog", "dogs", "WORD") == "ONE DOG"
  
  result = if num == 1: s_word else: p_word

  if num_mode != "none":
    result = capitalizer(result, num_mode)
    let ns = apply_num_mode(num, num_mode)
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

proc timeago*(date_1, date_2: int64, num_mode: string = "num"): string =
  ## Purpose: Get the timeago message between two dates
  ## 
  ## Used for simple messages like "posted 1 hour ago"
  ## 
  ## The dates are 2 unix timestamps in seconds
  ## 
  ## Accepts a num_mode string
  ## 
  ## The num_mode also affects the strings
  runnableExamples:
    assert timeago(0, 10) == "10 seconds"
    assert timeago(0, 140) == "2 minutes"
    assert timeago(0, Hour * 3, "word") == "three hours"
    assert timeago(0, Month, "Word") == "One Month"
    assert timeago(0, Year * 10, "WORD") == "TEN YEARS"
    
  let d = float(max(date_1, date_2) - min(date_1, date_2))
  
  if d < Minute: multistring(int64(d), "second", "seconds", num_mode)
  elif d < Hour: multistring(int64(d / 60), "minute", "minutes", num_mode)
  elif d < Day: multistring(int64(d / 60 / 60), "hour", "hours", num_mode)
  elif d < Month: multistring(int64(d / 24 / 60 / 60), "day", "days", num_mode)
  elif d < Year: multistring(int64(d / 30 / 24 / 60 / 60), "month", "months", num_mode)
  else: multistring(int64(d / 365 / 24 / 60 / 60), "year", "years", num_mode)

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

proc numerate*(lines: openArray[string], left, right: string, num_mode: string = "num"): string =
  ## Purpose: Add numbers to lines
  ## 
  ## Send an array of lines
  ## 
  ## And the left and right parts around the number
  ## 
  ## Accepts a num_mode string
  runnableExamples:
    assert numerate(["This line", "That line"], "", ")") == "1) This line\n2) That line"
    assert numerate(["This line", "That line"], "[", "]", "word") == "[one] This line\n[two] That line"
    assert numerate(["This line", "That line"], "[", "]", "Word") == "[One] This line\n[Two] That line"
    assert numerate(["This line", "That line"], "[", "]", "WORD") == "[ONE] This line\n[TWO] That line"
    
  let new_array = collect(newSeq):
    for i, s in lines: 
      let num = apply_num_mode(i + 1, num_mode)
      &"{left}{num}{right} {s}"
  return new_array.join("\n")

proc insertnum*(text, token: string, num_mode: string = "num"): string =
  ## Purpose: Replace token with an incrementing number
  ## 
  ## Send the text and token
  ## 
  ## Accepts a num_mode string
  runnableExamples:
    assert insertnum("This is $ and this is $", "$") == "This is 1 and this is 2"
    assert insertnum("Hello _ and _", "_", "word") == "Hello one and two"
    assert insertnum("Hello _ and _", "_", "Word") == "Hello One and Two"
    assert insertnum("Hello _ and _", "_", "WORD") == "Hello ONE and TWO"

  result = ""; var ss = text

  for n in 1..text.count(token):
    let i = ss.find(token)
    let num = apply_num_mode(n, num_mode)
    result.add(&"{ss[0..(i - 1)]}{num}")
    ss = ss[i + token.len..^1]