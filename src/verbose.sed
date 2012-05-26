#!/bin/sed -rf

# Delete contents of hold buffer
x
s/.*//
x

# Make the 10 card into one character
s/10/T/g

# Jump to the next line to clear the conditional jump state
t x

# Check for incorrect denomination
:x /([^2-9TJQKA]|[^ ].):/s/.*/Card has incorrect denomination/
t z

# Check for incorrect suit
/:([^CDHS]|.[^ ])/s/.*/Card has incorrect suit/
t z

# Normalize input
s/[ :]//g

# Jump to the next line to clear the conditional jump state
t y

# Check for too many cards
:y /.{11}/s/.*/Too many cards/
t z

# Check for not enough cards
/.{10}/!s/.*/Too few cards/
t z

# Check for duplicate cards
/(.[CDHS]).*\1/s/.*/Duplicate card/
t z

# Everything from here down to label "c" implements a sort function. Yep, in sed.
# First we add our "stack" variable -- a list of possible card values
s/^/23456789TJQKA /

# Jump to the next line to clear the conditional jump state
t a

# Exit loop when there are no cards left in the pattern buffer
:a / $/b c

# Attempt to pull a card out of the list of cards, and place it as a new stack value
s/^(.)(.*) (.*)(\1.)(.*)$/\4 \1\2 \3\5/

# If the card was pulled out, jump to label "b"
t b

# If the card was not pulled out, delete that card value from the front of the "stack"
s/^.//

# Jump back to the beginning of the loop and also clear the conditional jump state
t a

# Append the pattern buffer onto the hold buffer, with a newline between them
:b H

# In the hold buffer, delete everything after that card value we just pulled out
x
s/\n(..).*/\1/
x

# In the pattern buffer, delete the card value we just pulled out
s/^.. //

# Jump back to the beginning of the loop and also clear the conditional jump state
t a

# At this point, the hold buffer contains a *sorted* version of the card list
# Override the pattern buffer (unsorted) with the contents of the hold buffer (sorted)
:c g

# If the hand contains a flush, put an "f" at the beginning
/.(.)(.\1){4}/s/^/f/

# Delete the suits -- they're not needed anymore
s/[CDHS]//g

# If this hand contains a straight, put an "s" at the beginning
s/^/23456789TJQKA /
/(.{5}).*\1/s/ / s/
s/.* //

# Jump to the next line to clear the conditional jump state
t e

# If this hand is a straight flush...
:e /sf/{
   # ...and contains an Ace -- this is a royal flush!
   /A/s/.*/Royal flush/
   t

   # ...or does *not* contain an Ace -- this is a straight flush!
   s/.*/Straight flush/
   b
}

# See if this hand has a four of a kind
/(.)\1{3}/s/.*/Four of a kind/
t

# This hand has a full house
/((.)\2(.)\3\3|(.)\4\4(.)\5)/s/.*/Full house/
t

# This hand has a flush
/f/s/.*/Flush/
t

# This hand has a straight
/s/s/.*/Straight/
t

# This hand has a three of a kind
/(.)\1\1/s/.*/Three of a kind/
t

# This hand has two pair
/(.)\1.*(.)\2/s/.*/Two pair/
t

# This hand has a pair
/(.)\1/s/.*/One pair/
t

# This hand has nothing but a high card -- pull out the high card
s/.*(.)/High card: \1/
s/T/10/
b

# An error has occurred
:z s/^/ERROR: /
