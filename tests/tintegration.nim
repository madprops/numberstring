import pkg/numberstring

assert multistring(0, "day", "days") == "0 days"
assert multistring(1, "day", "days") == "1 day"
assert multistring(2, "day", "days") == "2 days"
assert multistring(10, "thing", "things") & " " & multistring(10, "was", "were", false) == "10 things were"

assert numberwords(-89) == "minus eighty-nine"
assert numberwords(0) == "zero"
assert numberwords(1) == "one"
assert numberwords(18) == "eighteen"
assert numberwords(100) == "one hundred"
assert numberwords(122) == "one hundred twenty-two"
assert numberwords(999) == "nine hundred ninety-nine"
assert numberwords(2345) == "two thousand three hundred forty-five"
assert numberwords(4455667788) == "four billion four hundred fifty-five million six hundred sixty-seven thousand seven hundred eighty-eight"
assert numberwords(9.1818) == "nine"

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
assert timeago(80, 50) == "30 seconds"

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

assert insertnum("this is number __ and this is number __", "__") == "this is number 1 and this is number 2"
assert insertnum("slot$  vs  trak$ in\nthe room-$ and\n$", "$") == "slot1  vs  trak2 in\nthe room-3 and\n4"

echo "Test completed successfully."