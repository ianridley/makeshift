#
# MK.MK --makeshift rules for manipulating ".mk" files.
#
# Contents:
# install-mk:   --Install ".mk" files to their usual places.
# uninstall-mk: --Uninstall the default ".mk" files.
# src:          --Update MK_SRC with the list of ".mk" files.
# toc:          --Rebuild a Makefile's table-of-contents.
# todo:         --Report unfinished work in Makefiles.
# +stddirs:     --Print the current make directory macros.
# +version:     --Report the version of make.
#
.PHONY: $(recursive-targets:%=%-mk)

PRINT_make_VERSION = make --version

ifdef autosrc
    LOCAL_MK_SRC := $(wildcard *.mk)

    MK_SRC ?= $(LOCAL_MK_SRC)
endif

$(includedir)/%.mk:	%.mk;	$(INSTALL_DATA) $< $@

#
# install-mk: --Install ".mk" files to their usual places.
#
install-mk:     $(MK_SRC:%.mk=$(includedir)/%.mk)

#
# uninstall-mk: --Uninstall the default ".mk" files.
#
uninstall-mk:
	$(ECHO_TARGET)
	$(RM) $(MK_SRC:%.mk=$(includedir)/%.mk)
	$(RMDIR) $(includedir)

#
# src: --Update MK_SRC with the list of ".mk" files.
#
src:	src-mk
src-mk:
	$(ECHO_TARGET)
	$(Q)mk-filelist -f $(MAKEFILE) -qn MK_SRC *.mk .mk

#
# toc: --Rebuild a Makefile's table-of-contents.
#
toc:	toc-mk
toc-mk:
	$(ECHO_TARGET)
	$(Q)mk-toc Makefile $(MK_SRC)

#
# todo: --Report unfinished work in Makefiles.
#
todo:	todo-mk
todo-mk:
	$(ECHO_TARGET)
	@$(GREP) $(TODO_PATTERN) Makefile $(MK_SRC) /dev/null ||:

#
# +stddirs: --Print the current make directory macros.
#
.PHONY +stddirs:
+stddirs:
	@echo "DESTDIR:        $(DESTDIR)"
	@echo "prefix:         $(prefix)"
	@echo "opt:            $(opt)"
	@echo "usr:            $(usr)"
	@echo "subdir:         $(subdir)"
	@echo "archdir:        $(archdir)"
	@echo "gendir:         $(gendir)"
	@echo "pkgver:         $(pkgver)"
	@echo ""; echo "rootdir:        $(rootdir)"
	@echo "bindir:         $(bindir)"
	@echo "sbindir:        $(sbindir)"
	@echo "libexecdir:     $(libexecdir)"
	@echo "datadir:        $(datadir)"
	@echo "system_confdir: $(system_confdir)"
	@echo "sysconfdir:     $(sysconfdir)"
	@echo "divertdir:      $(divertdir)"
	@echo "sharedstatedir: $(sharedstatedir)"
	@echo "localstatedir:  $(localstatedir)"
	@echo "srvdir:         $(srvdir)"
	@echo "wwwdir:         $(wwwdir)"
	@echo "libdir:         $(libdir)"
	@echo "infodir:        $(infodir)"
	@echo "lispdir:        $(lispdir)"
	@echo "includedir:     $(includedir)"
	@echo "mandir:         $(mandir)"
	@echo "docdir:         $(docdir)"

#
# +version: --Report the version of make.
#
+version: cmd-version[make]
