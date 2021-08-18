## multistring

Purpose: Avoid strings like "1 days" when it should be "1 day"

Send the number of the amount of things. 1 == singular

Send the singular word and the plural word

>proc multistring*(num: int64, s_word, p_word: string): string

## numberwords

Purpose: Turn numbers into english words

Example: 122 == "one hundred and twenty-two"

Submit the number that is transformed into words

>proc numberword*(num: SomeNumber): string

## numstring

Purpose: Return rounded float strings

This avoids cases like 1.19999 and just returns 1.2

Right now it just rounds to 1 decimal place

>proc numstring*(num: SomeNumber): string

## countword

Purpose: Get the sum of letter index values

a = 1, z = 26. abc = 6

>proc countword*(s: string): int

## timeago


Purpose: Get the timeago message between two dates

The dates are 2 unix seconds

First is the highest, second is the lowest

>proc timeago*(date_high, date_low: int64): string

## wordtag

Purpose: Generate random string tags

It alternates between vowels and consonants

Receives a number to set the length

Receives a boolean to set if vowels go first

>proc wordtag*(n: int, vf: bool = true): string

## Constants

> Hold letters and their 1 based position

> a = 1, z = 26

### let ns_lettermap*

---

> List of vowel letters

### let ns_vowels*

---

> List of consonant letters

### let ns_consonants*

---

> Constants to calculate time

### let ns_minute*

### let ns_hour*

### let ns_day*

### let ns_month*

### let ns_year*