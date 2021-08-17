import numberstring

assert multistring(1, ["day", "days"], @["is", "are"]) == "1 day is"
assert multistring(2, @["day", "days"], ["was", "were"]) == "2 days were"
assert multistring(3, ["day", "days"], @["is", "are"]) == "3 days are"
assert multistring(4, @["day", "days"]) == "4 days"
assert multistring(9.1818, ["day", "days"]) == "9.2 days"

assert numberword(-89) == "minus eighty-nine"
assert numberword(1) == "one"
assert numberword(18) == "eighteen"
assert numberword(100) == "one hundred"
assert numberword(101) == "one hundred and one"
assert numberword(122) == "one hundred and twenty-two"
assert numberword(999) == "nine hundred and ninety-nine"
assert numberword(2345) == "two thousand three hundred and forty-five"
assert numberword(4455667788) == "four billion four hundred and fifty-five million six hundred and sixty-seven thousand seven hundred and eighty-eight"
assert numberword(245.111) == "two hundred and forty-five dot one"
assert numberword(9.1818) == "nine dot two"