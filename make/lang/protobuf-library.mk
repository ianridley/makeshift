#
# PROTOBUF-LIBRARY.MK --Rules for libraries containing PROTOBUF objects.
#
# Contents:
# pre-build-lib:       --Install headers into library root, via lib's pre-build.
# clean-lib:           --Remove the staged include files.
# install-lib-include-protobuf: --Install a library's include files.
#

$(archdir)/lib.a:	$(PROTOBUF_OBJ)

#
# pre-build-lib: --Install headers into library root, via lib's pre-build.
#
# Remarks:
# library.mk defines LIB_INCLUDEDIR, and pre-build-lib.
#
.PHONY: pre-build-lib-protobuf
pre-build-lib: pre-build-lib-protobuf
pre-build-lib-protobuf: $(PROTOBUF_H++:$(archdir)/%=$(LIB_INCLUDEDIR)/%)

#
# clean-lib: --Remove the staged include files.
#
.PHONY: clean-lib-protobuf
clean-lib: clean-lib-protobuf
clean-lib-c:; $(RM) $(PROTOBUF_H++:$(archdir)/%=$(LIB_INCLUDEDIR)/%)

#
# install-lib-include-protobuf: --Install a library's include files.
#
# Remarks:
# These targets customise the library.mk behaviour.
#
.PHONY: install-lib-include-protobuf
install-lib-include:	install-lib-include-protobuf
install-lib-include-protobuf:  $(PROTOBUF_SRC:%.proto=$(includedir)/%.pb.$(H++_SUFFIX))
.PHONY: uninstall-lib-include-protobuf
uninstall-lib-include:	uninstall-lib-include-protobuf
uninstall-lib-include-protobuf:; $(RM) $(PROTOBUF_SRC:%.proto=$(includedir)/%.pb.$(H++_SUFFIX))