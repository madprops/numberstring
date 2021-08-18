import pkg/numberstring

assert multistring(0, "day", "days") == "days"
assert multistring(1, "day", "days") == "day"
assert multistring(2, "day", "days") == "days"
assert multistring(3, "cat", "cats") == "cats"
assert multistring(4, "is", "are") == "are"
assert multistring(1, "was", "were") == "was"
assert multistring(2, "it", "them") == "them"

let n = 10000
assert multistring(n, "thing", "things") & " " & multistring(n, "was", "were") == "things were"

assert numberwords(-89) == "minus eighty-nine"
assert numberwords(0) == "zero"
assert numberwords(1) == "one"
assert numberwords(18) == "eighteen"
assert numberwords(100) == "one hundred"
assert numberwords(101) == "one hundred one"
assert numberwords(122) == "one hundred twenty-two"
assert numberwords(999) == "nine hundred ninety-nine"
assert numberwords(2345) == "two thousand three hundred forty-five"
assert numberwords(4455667788) == "four billion four hundred fifty-five million six hundred sixty-seven thousand seven hundred eighty-eight"
assert numberwords(245.11) == "two hundred forty-five point one"
assert numberwords(9.1818) == "nine point two"

assert countword("") == 0
assert countword("a") == 1
assert countword("abc") == 6
assert countword("abc $$ !@#") == 6
assert countword("Red Trains") == 108
assert countword("2  a  b  c  2") == 10

assert timeago(1629246966, 1629246960) == "just now"
assert timeago(1629246966, 1629243966) == "50 minutes ago"
assert timeago(1629246966, 1629233966) == "3 hours ago"
assert timeago(1629246966, 1629102966) == "1 day ago"
assert timeago(1629246966, 1623102966) == "2 months ago"
assert timeago(1629246966, 1513102966) == "3 years ago"

echo "Test completed successfully."