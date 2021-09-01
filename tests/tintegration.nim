import std/[random]
import pkg/numberstring

assert multistring(0, "day", "days") == "0 days"
assert multistring(1, "day", "days") == "1 day"
assert multistring(2, "day", "days") == "2 days"
assert multistring(4, "dog", "dogs", NoNumber) == "dogs"
assert multistring(4, "dog", "dogs", LowWord) == "four dogs"
assert multistring(4, "DOG", "DoGs", CapWord) == "Four DoGs"
assert multistring(1, "dog", "dogs", UpWord) == "ONE dog"
assert multistring(4, "dog", "dogs", Roman) == "IV dogs"
assert multistring(1.2, "thing", "things", Number) == "1 thing"
assert multistring(1.2, "thing", "things", FloatNumber) == "1.2 things"
assert multistring(1.2, "thing", "things", LowWord) == "one thing"
assert multistring(1.2, "thing", "things", CapWord) == "One thing"
assert multistring(1.2, "thing", "things", UpWord) == "ONE thing"
assert multistring(1.2, "thing", "things", FloatLowWord) == "one point two things"
assert multistring(1.2, "thing", "things", FloatCapWord) == "One Point Two things"
assert multistring(1.2, "thing", "things", FloatUpWord) == "ONE POINT TWO things"
assert multistring(1.2, "thing", "things", Roman) == "I thing"

assert numberwords(-89) == "minus eighty-nine"
assert numberwords(0) == "zero"
assert numberwords(1) == "one"
assert numberwords(18) == "eighteen"
assert numberwords(100) == "one hundred"
assert numberwords(122) == "one hundred twenty-two"
assert numberwords(999) == "nine hundred ninety-nine"
assert numberwords(2345) == "two thousand three hundred forty-five"
assert numberwords(4455667788) == "four billion four hundred fifty-five million six hundred sixty-seven thousand seven hundred eighty-eight"
assert numberwords(9.1818) == "nine point two"
assert numberwords(603000000) == "six hundred three million"

assert countword("") == 0
assert countword("a") == 1
assert countword("abc") == 6
assert countword("abc $$ !@#") == 6
assert countword("Red Trains") == 108
assert countword("2  a  b  c  2") == 10

assert timeago(1629243966, 1629246966) == "50 minutes"
assert timeago(1629246966, 1629233966) == "3 hours"
assert timeago(1629246966, 1629102966) == "1 day"
assert timeago(1629246966, 1623102966) == "2 months"
assert timeago(1629246966, 1513102966) == "3 years"
assert timeago(2, 2000) == "33 minutes"
assert timeago(2, 2000) == "33 minutes"
assert timeago(80, 50) == "30 seconds"
assert timeago(0, Hour * 3, LowWord) == "three hours"
assert timeago(0, Month, CapWord) == "One Month"
assert timeago(0, Year * 10, UpWord) == "TEN YEARS"
assert timeago(0, 70) == "1 minute"
assert timeago(0, 70, FloatNumber) == "1.2 minutes"

let wt1 = wordtag(4, true)
assert wt1.len == 4
assert wt1[0] in Vowels
assert wt1[1] notin Vowels

let wt2 = wordtag(6, false)
assert wt2.len == 6
assert wt2[0] notin Vowels
assert wt2[1] in Vowels

assert leetspeak("Maple Strikter") == "m4pl3 s7r1k73r"
assert leetspeak("a e i o t") == "4 3 1 0 7"

assert numerate(["a b c", "dfg", "h i j"], "(", ")") == "(1) a b c\n(2) dfg\n(3) h i j"
assert numerate(["cat", "dog", "cow"], "#", ":") == "#1: cat\n#2: dog\n#3: cow"
assert numerate(["This line", "That line"], "[", "]", LowWord) == "[one] This line\n[two] That line"
assert numerate(["This line", "That line"], "[", "]", CapWord) == "[One] This line\n[Two] That line"
assert numerate(["This line", "That line"], "[", "]", UpWord) == "[ONE] This line\n[TWO] That line"
assert numerate(["This line", "That line"], "(", ")", Roman) == "(I) This line\n(II) That line"

assert insertnum("this is number __ and this is number __", "__") == "this is number 1 and this is number 2"
assert insertnum("slot$  vs  trak$ in\nthe room-$ and\n$", "$") == "slot1  vs  trak2 in\nthe room-3 and\n4"
assert insertnum("Hello _ and _", "_", LowWord) == "Hello one and two"
assert insertnum("Hello _ and _", "_", CapWord) == "Hello One and Two"
assert insertnum("Hello _ and _", "_", UpWord) == "Hello ONE and TWO"
assert insertnum("x x x x x", "x", Roman) == "I II III IV V"

assert linesummary(["hello there"], true, true) == "hello there (2 words) (10 chars)"
assert linesummary(["ab", "c d e"], true, true) == "ab (1 word) (2 chars)\nc d e (3 words) (3 chars)"
assert linesummary(["ab", "c d e"], true, false) == "ab (1 word)\nc d e (3 words)"
assert linesummary(["ab", "c d e"], false, true) == "ab (2 chars)\nc d e (3 chars)"
assert linesummary(["ab", "c d e"], false, true, CapWord) == "ab (Two Chars)\nc d e (Three Chars)"

assert romano(21) == "XXI"
assert romano(1994) == "MCMXCIV"
assert romano(1) == "I"
assert romano(0) == "0"
assert romano(-11) == "-XI"

assert wordsnumber("six hundred three") == 603.0
assert wordsnumber("six hundred three million") == 603000000.0
assert wordsnumber("six million three hundred ten thousand six hundred thirty-two") == 6310632.0
assert wordsnumber("zero") == 0.0
assert wordsnumber("minus four thousand two") == -4002.0
assert wordsnumber("thirty-three point three") == 33.3
assert wordsnumber("thirty three point five hundred thirty two thousand eleven") == 33.532011
assert wordsnumber("three hundred forty") == 340
assert wordsnumber("four billion four hundred fifty-five million six hundred sixty-seven thousand seven hundred eighty-eight") == 4455667788.0
assert wordsnumber("One HUNDRED NiNeteen") == 119
assert wordsnumber("minus three three two one seven point five") == -33217.5
doAssertRaises(CatchableError):
  echo wordsnumber("nothing here")
doAssertRaises(CatchableError):
  echo wordsnumber("")

assert writemorse("a b   c") == ".- / -... / -.-."
assert writemorse("420") == "....- ..--- -----"
assert writemorse("hunter 2") == ".... ..- -. - . .-. / ..---"
assert writemorse("@$.,") == ".--.-. ...-..- .-.-.- --..--"
assert writemorse("what 112 !!?") == ".-- .... .- - / .---- .---- ..--- / -.-.-- -.-.-- ..--.."
assert writemorse("100 + 200") == ".---- ----- ----- / .-.-. / ..--- ----- -----"

assert readmorse(".-- .... .- - / .---- .---- ..--- / -.-.-- -.-.-- ..--..") == "what 112 !!?"
assert readmorse("- .... . / -- .- --. .. -.-. .. .- -.") == "the magician"
assert readmorse(".---- ----- ----- / .-.-. / ..--- ----- -----") == "100 + 200"

var rng = initRand(100)
assert shufflewords("this thing is", rng) == "thing is this"
assert shufflewords("this thing is", rng) == "this thing is"
assert shufflewords("this thing is", rng) == "thing this is"

assert textnumbers("Number 3.2 and 8.9") == "Number 3 and 8"
assert textnumbers("Number 3.2 and 8.9", FloatNumber) == "Number 3.2 and 8.9"
assert textnumbers("Number 3 and 8", LowWord) == "Number three and eight"
assert textnumbers("Number 3 and 8", Roman) == "Number III and VIII"
assert textnumbers("3.2 and 8.9", FloatCapWord) == "Three Point Two and Eight Point Nine"

assert wordslen("what is there", false) == "4 2 5"
assert wordslen("what is there", true) == "what (4) is (2) there (5)"
assert wordslen("what is there", false, CapWord) == "Four Two Five"
assert wordslen("what is there", true, Roman) == "what (IV) is (II) there (V)"

assert dumbspeak("hello there", true) == "HeLlO tHeRe"
assert dumbspeak("hello there", false) == "hElLo ThErE"

let s1 = """
############
# One line #
# Another  #
# line     #
############"""

let s2 = """
################
# One line     #
# Another line #
################"""

let s3 = """
#########################
# One line Another line #
#########################"""

assert charframe("One line\nAnother line", 10, '#') == s1
assert charframe("One line\nAnother line", 15, '#') == s2
assert charframe("One line\nAnother line", 25, '#') == s3

assert longestwords("Is that the only solution to this problem?") == @["solution", "problem?"]

assert shortestwords("Is that the only solution to this problem?") == @["is", "to"]

assert repstring("what !is! this???!", ['!', '?']) == "what is this"
assert repstring("what??is this", ['?', 's'], "@") == "what@@i@ thi@"

assert asciistring("That thing!!") == "That thing"
assert asciistring("N!u!mber 22...") == "Number 22"
assert asciistring("w2h2a2t 5is t4hi9s", false) == "what is this"

assert keepchars("hello these thing", ['e', 'l']) == "ell ee"
assert keepchars("eeEEmsteeEm", ['E', 'm']) == "EEmEm"

assert remove_punctuation("hello, what is this?") == "hello what is this"
assert remove_punctuation("hello!! ok; ??") == "hello ok"
assert remove_punctuation("Hello #12") == "Hello #12"
assert remove_punctuation("Hello?!!?:?!:;; There") == "Hello There"

assert count_vowels("la pacha") == 3
assert count_consonants("la pacha") == 4