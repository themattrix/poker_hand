
SHELL = /bin/bash

all: test

# Loop through all file in the 'src' directory, feeding each one test/input.txt
# and comparing the output to test/output.txt.
test:
	@for f in src/*; do \
	    o=$$(diff <("$$f" test/input.txt) test/output.txt 2>&1); \
	    if [ -z "$$o" ]; then \
	       echo "[SUCCESS] $$f"; \
	    else \
	       echo "[FAILURE] $$f"; \
	       sed '1s/^/ Diff: /;1!s/^/       /' <<< "$$o"; \
	    fi; \
	 done

.PHONY: test
