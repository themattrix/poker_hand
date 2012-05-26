Poker Hand Identifier
=====================

Given a poker hand, this sed script will output the name of the hand. For example, the hand `Q:S 7:C Q:D 7:D 7:S` (queen of spades, 7 of clubs, queen of diamonds, 7 of diamonds, 7 of spades) will output `Full house`. The hand can be in any order and the colons are optional.

The script comes in two flavors, _compact_ and _verbose_. They contain identical logic, but have different goals. The compact version is an attempt to be as short as possible (796 characters); the verbose version is commented to explain how it works.

Here is the entire contents of compact.sed:
```sed
#!/bin/sed -rf
x;s/.*//;x;s/10/T/g;tx;:x /([^2-9TJQKA]|[^ ].):/s/.*/Card has incorrect denomination/;tz;/:([^CDHS]|.[^ ])/s/.*/Card has incorrect suit/;tz;s/[ :]//g;ty;:y /.{11}/s/.*/Too many cards/;tz;/.{10}/!s/.*/Too few cards/;tz;/(.[CDHS]).*\1/s/.*/Duplicate card/;tz;s/^/23456789TJQKA /;ta;:a / $/bc;s/^(.)(.*) (.*)(\1.)(.*)$/\4 \1\2 \3\5/;tb;s/^.//;ta;:b H;x;s/\n(..).*/\1/;x;s/^.. //;ta;:c g;/.(.)(.\1){4}/s/^/f/;s/[CDHS]//g;s/^/23456789TJQKA /;/(.{5}).*\1/s/ / s/;s/.* //;te;:e /sf/{/A/s/.*/Royal flush/;t;s/.*/Straight flush/;b};/(.)\1{3}/s/.*/Four of a kind/;t;/((.)\2(.)\3\3|(.)\4\4(.)\5)/s/.*/Full house/;t;/f/{s/.*/Flush/;b};/s/s/.*/Straight/;t;/(.)\1\1/s/.*/Three of a kind/;t;/(.)\1.*(.)\2/s/.*/Two pair/;t;/(.)\1/s/.*/One pair/;t;s/.*(.)/High card: \1/;s/T$/10/;b;:z s/^/ERROR: /
```

Example usage:

    $ echo "5:H 5:D A:S 10:D 5:C" | src/compact.sed
    Three of a kind

    $ echo "2:H 3:H 4:H 5:H A:D" | src/compact.sed
    High card: A

Invalid hands are also flagged, for example:

    $ echo "2:H 3:H 4:H 5:H A:D 5:C" | src/compact.sed
    ERROR: Too many cards

    $ echo "8:S 3:H 4:H 5:H 6:HS" | src/compact.sed
    ERROR: Card has incorrect suit

A pair of input and output files are included to exercise the range output options (valid and invalid hands):

    $ cat test/input.txt
    10:H J:H Q:H K:H A:H
    A:D K:D Q:D J:D 10:D
    K:C J:C 10:C A:C Q:C
    Q:S K:S A:S 10:S J:S
    2:H 3:H 4:H 5:H 6:H
    K:D Q:D J:D 10:D 9:D
    2:S 2:H 2:D 4:C 2:C
    J:S J:C 5:H J:H J:D
    Q:S 7:C Q:D 7:D 7:S
    7:S Q:C 7:D Q:D Q:S
    A:D 6:D 7:D 9:D 2:D
    2:D 3:H 4:H 5:H 6:C
    5:C 6:H 7:D 8:D 9:D
    5:H 5:D A:S 10:D 5:C
    8:H J:S 8:S 3:D 3:H
    A:D 2:D 2:C 9:S A:H
    Q:S 2:H 3:H 4:H Q:H
    2:H 3:H 4:H 5:H 7:D
    2:H 3:H 4:H 5:H 10:D
    2:H 3:H 4:H 5:H J:D
    2:H 3:H 4:H 5:H Q:D
    2:H 3:H 4:H 5:H K:D
    2:H 3:H 4:H 5:H A:D
    2:H 3:H 4:H 5:H A:D 5:C
    2:H 3:H 4:H 5:H
    2:H 3:H 4:H 2:H J:H
    2:U 3:H 4:H 5:H 6:H
    12:U 3:H 4:H 5:H 6:H
    2:S 3:H 14:H 5:H 6:H
    8:S 3:H 4:HS 5:H 6:H
    8:S 3:H 4:H 5:H 6:HS
    8:S 8:S 8:H 8:D 8:C

    $ src/compact.sed test/input.txt
    Royal flush
    Royal flush
    Royal flush
    Royal flush
    Straight flush
    Straight flush
    Four of a kind
    Four of a kind
    Full house
    Full house
    Flush
    Straight
    Straight
    Three of a kind
    Two pair
    Two pair
    One pair
    High card: 7
    High card: 10
    High card: J
    High card: Q
    High card: K
    High card: A
    ERROR: Too many cards
    ERROR: Too few cards
    ERROR: Duplicate card
    ERROR: Card has incorrect suit
    ERROR: Card has incorrect denomination
    ERROR: Card has incorrect denomination
    ERROR: Card has incorrect suit
    ERROR: Card has incorrect suit
    ERROR: Duplicate card

This is also the contents of "test/output.txt". The included makefile can be run to verify that the scripts (compact and verbose) are working correctly:

    $ make
    [SUCCESS] src/compact.sed
    [SUCCESS] src/verbose.sed

Note for OS X users: The version of sed installed has different options than the Linux one. Notably, it does not have the extended-regex option '-r'. I recommend building the latest version from here: http://sed.sourceforge.net/
