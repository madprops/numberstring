import std/[times, random, math, strutils, sequtils, strformat, sugar, tables]
from unicode import title

type NumberMode* = enum
  ## Type of number to display
  ##
  ## Int Number. Float Number. No number
  ##
  ## Words can be like "two hundred eighty-eight"
  ##
  ## Lower case word, Capitalized word, Upper case word
  ##
  ## Words that use a float number like "two point one"
  ##
  ## Roman number like XXI
  Number, FloatNumber, NoNumber,
  LowWord, CapWord, UpWord,
  FloatLowWord, FloatCapWord, FloatUpWord,
  Roman

# Check if it's an int word
proc is_word(mode: NumberMode): bool =
  mode in [LowWord, CapWord, UpWord]

# Check if it's a float word
proc is_f_word(mode: NumberMode): bool =
  mode in [FloatLowWord, FloatCapWord, FloatUpWord]

# Check if the number should be treated as int
proc is_int(mode: NumberMode): bool =
  mode in [Number, Roman] or is_word(mode)

const
  # Letter constants
  Vowels* = ['a', 'e', 'i', 'o', 'u']
  Consonants* = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z']

  # To calculate time
  Minute* = 60
  Hour* = 3_600
  Day* = 86_400
  Month* = 2_592_000
  Year* = 31_536_000

  # To calculate number words
  Powers* = [("hundred", 2), ("thousand", 3), ("million", 6), ("billion", 9), ("trillion", 12)]
  Tens* = ["twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
  Teens* = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
  Digits* = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

  # For roman number conversion
  Symbols* = [
    ("M", 1000), ("CM", 900), ("D", 500), ("CD", 400), ("C", 100),
    ("XC", 90), ("L", 50), ("XL", 40), ("X", 10),
    ("IX", 9), ("V", 5), ("IV", 4), ("I", 1)]

  Morse = {'A': ".-",     'B': "-...",   'C': "-.-.",    'D': "-..",    'E': ".",
           'F': "..-.",   'G': "--.",    'H': "....",    'I': "..",     'J': ".---",
           'K': "-.-",    'L': ".-..",   'M': "--",      'N': "-.",     'O': "---",
           'P': ".--.",   'Q': "--.-",   'R': ".-.",     'S': "...",    'T': "-",
           'U': "..-",    'V': "...-",   'W': ".--",     'X': "-..-",   'Y': "-.--",
           'Z': "--..",   '0': "-----",  '1': ".----",   '2': "..---",  '3': "...--",
           '4': "....-",  '5': ".....",  '6': "-....",   '7': "--...",  '8': "---..",
           '9': "----.",  '.': ".-.-.-", ',': "--..--",  '?': "..--..", '\'': ".----.",
           '!': "-.-.--", '/': "-..-.",  '(': "-.--.",   ')': "-.--.-", '&': ".-...",
           ':': "---...", ';': "-.-.-.", '=': "-...-",   '+': ".-.-.",  '-': "-....-",
           '_': "..--.-", '"': ".-..-.", '$': "...-..-", '@': ".--.-."}.toTable

# Init the random number generator
var randgen = initRand(int(epochTime()))

# a = 1, z = 26
proc alphabetpos(c: 'a'..'z'): int = (c.ord - 'a'.ord) + 1

# '1' = 1
proc numericval(c: '0'..'9'): int = (c.ord - '0'.ord)

# Split into words
proc get_words(text: string, lower: bool = false): seq[string] =
  let s = if lower: text.toLowerAscii else: text
  s.split(" ").filterIt(it != "")  

# Pre-Declare numberwords
proc numberwords*(num: SomeNumber): string

# Pre-Declare romano
proc romano*(num: SomeNumber): string

# Capitalize accordingly
proc capi(text: string, mode: NumberMode): string =
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
  elif is_word(mode): capi(numberwords(int(num)), mode)
  elif is_f_word(mode): capi(numberwords(float(num)), mode)
  elif mode == Roman: romano(num)
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
    assert multistring(1.2, "thing", "things", Roman) == "I thing"

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
    assert numberwords(9.1818) == "nine point two"
    assert numberwords(603000000) == "six hundred three million"

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

  for c in toSeq(text.strip().toLowerAscii()):
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

  let d = float(max(date_1, date_2) - min(date_1, date_2))

  if d < Minute:
    multistring(d, capi("second", mode), capi("seconds", mode), mode)
  elif d < Hour:
    multistring(d / 60, capi("minute", mode), capi("minutes", mode), mode)
  elif d < Day:
    multistring(d / 60 / 60, capi("hour", mode), capi("hours", mode), mode)
  elif d < Month:
    multistring(d / 24 / 60 / 60, capi("day", mode), capi("days", mode), mode)
  elif d < Year:
    multistring(d / 30 / 24 / 60 / 60, capi("month", mode), capi("months", mode), mode)
  else:
    multistring(d / 365 / 24 / 60 / 60, capi("year", mode), capi("years", mode), mode)

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

  return text.toLowerAscii().replace("a", "4")
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
    assert numerate(["This line", "That line"], "(", ")", Roman) == "(I) This line\n(II) That line"

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
    assert insertnum("x x x x x", "x", Roman) == "I II III IV V"

  result = ""; var ss = text

  for n in 1..text.count(token):
    let i = ss.find(token)
    let num = apply_number_mode(n, mode)
    result.add(&"{ss[0..(i - 1)]}{num}")
    ss = ss[i + token.len..^1]

proc linesummary*(lines: openArray[string], words, characters: bool, mode = Number): string =
  ## Print the number of words and characters per line
  ##
  ## Send an array of lines
  ##
  ## And two booleans to enable/disable words & chars
  runnableExamples:
    assert linesummary(["hello there"], true, true) == "hello there (2 words) (10 chars)"
    assert linesummary(["ab", "c d e"], false, true) == "ab (2 chars)\nc d e (3 chars)"
    assert linesummary(["ab", "c d e"], false, true, CapWord) == "ab (Two Chars)\nc d e (Three Chars)"

  var newlines: seq[string] = @[]

  for line in lines:
    var s = line

    if words:
      let c = get_words(line).len
      let cs = multistring(c, capi("word", mode), capi("words", mode), mode)
      s &= &" ({cs})"

    if characters:
      let c = line.replace(" ", "").len
      let cs = multistring(c, capi("char", mode), capi("chars", mode), mode)
      s &= &" ({cs})"

    newlines.add(s)

  return newlines.join("\n")

proc romano*(num: SomeNumber): string =
  ## Convert regular numbers to roman numbers
  runnableExamples:
    assert romano(21) == "XXI"
    assert romano(1994) == "MCMXCIV"
    assert romano(1) == "I"
    assert romano(0) == "0"
    assert romano(-11) == "-XI"

  var number = int(num)

  if number == 0:
    return "0"
  elif number < 0:
    result &= "-"
    number = abs(number)

  while number > 0:
    for symbol, value in Symbols.items:
      while number >= value:
        result.add symbol
        number -= value

proc wordsnumber*(text: string): float =
  ## Change number words to numbers
  runnableExamples:
    assert wordsnumber("six hundred three") == 603.0
    assert wordsnumber("six hundred three million") == 603000000.0
    assert wordsnumber("six million three hundred ten thousand six hundred thirty-two") == 6310632.0
    assert wordsnumber("zero") == 0
    assert wordsnumber("minus four thousand two") == -4002.0
    assert wordsnumber("thirty-three point three") == 33.3
    assert wordsnumber("thirty three point five hundred thirty two thousand eleven") == 33.532011
    assert wordsnumber("three hundred forty") == 340
    assert wordsnumber("One HUNDRED NiNeteen") == 119
    assert wordsnumber("minus three three two one seven point five") == -33217.5

  let words = get_words(text, true)

  if words.len == 0:
    raise newException(CatchableError, "No words provided")

  var
    ns = ""
    mode = ""
    mode_num = 0
    mode_index = 0
    charge = 0
    last_num = ""
    skip = false

  proc checkdiff(i: int) =
    let diff = mode_num - charge

    if diff > 0:
      if i > 0 and mode_index - 1 >= 0:
        let pnext = Powers[mode_index - 1]
        if pnext[0] in words[i..^1]:
          return

      let zeroes = "0".repeat(diff)

      if charge > 0:
        ns = ns[0..^(last_num.len + 1)] & zeroes & last_num
      else:
        ns &= zeroes

  for i, word in words:
    if skip:
      skip = false
      continue
    elif word == "point":
      ns &= "."
      continue
    elif word == "minus":
      ns &= "-"
      continue
    
    let num = block:
      if word in Digits:
        $(Digits.find(word))
      elif word in Teens:
        $(Teens.find(word) + 10)
      elif word in Tens:
        var ans = $((Tens.find(word) + 2) * 10)
        if i + 1 < words.len:
          if words[i + 1] in Digits:
            skip = true
            ans = $(Tens.find(word) + 2) & $(Digits.find(words[i + 1]))
        ans
      elif "-" in word:
        let split = word.split("-")
        $(Tens.find(split[0]) + 2) & $(Digits.find(split[1]))
      else: ""

    if num != "":
      charge += num.len
      ns &= num
      last_num = num
      continue

    block modeblock:
      for pi, p in Powers:
        if p[0] == word:
          checkdiff(i)
          mode = p[0]
          mode_num = p[1]
          mode_index = pi
          charge = 0
          break modeblock

      raise newException(CatchableError,
      "Invalid number word -> " & word)

  checkdiff(0)
  parseFloat(ns)

proc writemorse*(text: string): string =
  ## Turn a string into morse code
  ## 
  ## Words in the result are separated by a slash
  runnableExamples:
    assert writemorse("a b   c") == ".- / -... / -.-."
    assert writemorse("420") == "....- ..--- -----"
    assert writemorse("hunter 2") == ".... ..- -. - . .-. / ..---"
    assert writemorse("@$.,") == ".--.-. ...-..- .-.-.- --..--"
    assert writemorse("what 112 !!?") == ".-- .... .- - / .---- .---- ..--- / -.-.-- -.-.-- ..--.."
    assert writemorse("100 + 200") == ".---- ----- ----- / .-.-. / ..--- ----- -----"    

  var fullcode: seq[string]

  for word in text.toUpperAscii.splitWhitespace:
    var code: seq[string]
    let chars = toSeq(word.items).filterIt(it != ' ')
    for c in chars:
      if Morse.hasKey(c):
        code.add Morse[c]
    fullcode.add(code.join(" "))

  fullcode.join(" / ")

proc readmorse*(text: string): string =
  ## Turn morse code into a string
  ## 
  ## Words should be separated by a slash
  runnableExamples:
    assert readmorse(".-- .... .- - / .---- .---- ..--- / -.-.-- -.-.-- ..--..") == "what 112 !!?"
    assert readmorse("- .... . / -- .- --. .. -.-. .. .- -.") == "the magician"
    assert readmorse(".---- ----- ----- / .-.-. / ..--- ----- -----") == "100 + 200"    

  var wordlist: seq[string]
  let words = text.split("/").mapIt(it.strip())

  for word in words:
    var ws = ""
    let codes = word.splitWhitespace
    for c in codes:
      for k in Morse.keys:
        if Morse[k] == c:
          ws &= k

    wordlist.add(ws)
  
  wordlist.join(" ").toLowerAscii

proc shufflewords*(text: string, rng: var Rand = randgen): string =
  ## Shuffle words around
  ## 
  ## Send a string to be shuffled
  ## 
  ## A rand seed can be provided as an extra argument
  runnableExamples:
    import std/random
    var rng = initRand(100)
    assert shufflewords("this thing is", rng) == "thing is this"
    assert shufflewords("this thing is", rng) == "this thing is"
    assert shufflewords("this thing is", rng) == "thing this is"    

  var words = get_Words(text)
  rng.shuffle(words)
  return words.join(" ")

proc textnumbers*(text: string, mode = Number): string =
  ## Replace all numbers in a string
  ## 
  ## Send a text string
  ## 
  ## It checks every word in search for numbers
  ## 
  ## Accepts an optional NumberMode
  runnableExamples:
    assert textnumbers("Number 3.2 and 8.9") == "Number 3 and 8"
    assert textnumbers("Number 3.2 and 8.9", FloatNumber) == "Number 3.2 and 8.9"
    assert textnumbers("Number 3 and 8", LowWord) == "Number three and eight"
    assert textnumbers("Number 3 and 8", Roman) == "Number III and VIII"
    assert textnumbers("3.2 and 8.9", FloatCapWord) == "Three Point Two and Eight Point Nine"  

  let words = get_words(text)
  var new_words: seq[string]

  for word in words:
    try:
      let num = parseFloat(word)
      new_words.add(apply_number_mode(num, mode))
    except:
      new_words.add(word)
  
  new_words.join(" ")

proc wordslen*(text: string, keep_word: bool, mode = Number): string =
  ## Replace all words with their string length
  ## 
  ## Send a text string
  ## 
  ## Send a boolean to specify if words are kept
  ## 
  ## Accepts an optional NumberMode
  runnableExamples:
    assert wordslen("what is there", false) == "4 2 5"
    assert wordslen("what is there", true) == "what (4) is (2) there (5)"
    assert wordslen("what is there", false, CapWord) == "Four Two Five"
    assert wordslen("what is there", true, Roman) == "what (IV) is (II) there (V)"

  let words = get_words(text)
  var new_words: seq[string]

  for word in words:
    var ns = apply_number_mode(word.len, mode)
    if keep_word:
      ns = &"{word} ({ns})"
    new_words.add(ns)
  
  new_words.join(" ")

proc dumbspeak*(text: string, caps_first: bool): string =
  ## Capitalize every other letter
  ## 
  ## Send a text string
  ## 
  ## Send a boolean to specify if caps go first
  runnableExamples:
    assert dumbspeak("hello there", true) == "HeLlO tHeRe"
    assert dumbspeak("hello there", false) == "hElLo ThErE"
  
  let words = get_words(text)
  var new_words: seq[string]
  var cap = caps_first

  for word in words:
    var ns = ""
    for c in word.items:
      var cs = $c
      if cap: ns &= cs.toUpperAscii
      else: ns &= cs.toLowerAscii
      cap = not cap
    new_words.add(ns)
  
  new_words.join(" ")

echo dumbspeak("hello there", true)