#
# COVERAGE.MK --Rules for building coverage reports with gcov, lcov.
#
# Remarks:
# The coverage module provides the phony targets "coverage" "html-coverage".
# These targets build textual and html coverage reports respectively.
#
# Coverage is tied fairly closely to gcov/lcov, and therefore the GCC
# toolchain; you must add "--coverage" to $(CFLAGS) for the statistics
# files to be generated, and to $(LDFLAGS) to link in the
# statistics-gathering code.
#
# The "coverage" target is auto-recursive, and is used to
# generate the text reports per directory.  The HTML reports
# act on an entire tree, so they are not generated recursively; you must
# move to a directory and "make html-coverage".
#
# The coverage target generates coverage data for the files specified
# by $(GCOV_FILES), which is automatically defined via $(C_SRC) and
# $(C++_SRC).
#

GCOV_FILES := $(C_SRC:%.c=%.c.gcov) $(C++_SRC:%=%.gcov)
GCOV_GCDA_FILES := $(C_OBJ:%.o=%.gcda) $(C++_OBJ:%.o=%.gcda)

.PHONY: coverage html-coverage
coverage:	$(GCOV_FILES)
html-coverage:	$(archdir)/coverage/index.html

#
# the ".gcda" files won't exist if the code hasn't been run, so we
# have a dummy target that silently returns true.
#
$(archdir)/%.gcda:;@:

#
# trace.info: --Collate the coverage data for this tree of files.
#
# Remarks:
#
$(archdir)/zero.info:	$(GCOV_GCDA_FILES) | mkdir[$(archdir)]
	lcov --initial --capture --no-external --directory . >$@

$(archdir)/trace.info:	$(archdir)/zero.info | mkdir[$(archdir)]
	lcov --capture --no-external --directory . --test-name 'unit tests' >$(archdir)/base.info
	lcov --add-tracefile $(archdir)/zero.info \
	     --add-tracefile $(archdir)/base.info >$@
	$(RM) $(archdir)/zero.info $(archdir)/base.info

#
# coverage/index.html: --Create the html-formatted coverage reports.
#
$(archdir)/coverage/index.html:	$(archdir)/trace.info | mkdir[$(archdir)]
	genhtml --demangle-cpp --output-directory $(archdir)/coverage \
	    $(archdir)/trace.info

#
# clean: --Remove the coverage data and reports
#
.PHONY:	clean-coverage
clean:	clean-coverage
clean-coverage:
	$(ECHO_TARGET)
	$(RM) -r $(GCOV_FILES) $(archdir)/trace.info $(archdir)/coverage
