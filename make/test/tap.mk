#
# TAP.MK --Rules for running unit tests with the TAP framework.
#
# Contents:
# test:    --Run all the tests, and summarise them.
# test[%]: --Run a particular test.
# clean:   --Cleanup after TAP tests.
#
# Remarks:
# This defines some tap-specific targets related to testing,
# and actions that are triggered by the "test" target.
#
PROVE ?= prove
ALL_PROVE_FLAGS = $(TARGET.PROVE_FLAGS) $(LOCAL.PROVE_FLAGS) \
    $(PROJECT.PROVE_FLAGS) $(ARCH.PROVE_FLAGS) $(OS.PROVE_FLAGS) \
    $(PROVE_FLAGS)

%.tap:	%;	./$* > $@
%.tap:	%.t;	perl $*.t > $@

#
# test: --Run all the tests, and summarise them.
#
test:	test-tap
test-tap: | cmd-exists[$(PROVE)]
	$(ECHO_TARGET)
	$(PROVE) $(ALL_PROVE_FLAGS) $^

#
# test[%]: --Run a particular test.
#
test[%]:	$(archdir)/%;      $(archdir)/$*
test[%.sh]:	%;      ./$*
