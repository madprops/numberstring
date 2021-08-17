## multistring

Purpose: Avoid strings like "1 days" when it should be "1 day"

Send the number of the amount of things. 1 == singular

Send an array with the singular word and the plural word

Send an optional array of other words to consider

Receive the appropiate words (without the number)

>proc multistring*(num: SomeNumber, words: openArray[string], afterwords: openArray[string] = []): string

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