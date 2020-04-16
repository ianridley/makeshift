#
# Makefile --Build rules for devkit, the developer utilities kit.
#
# Contents:
# devkit.mk:         --Fail if devkit is not available.
# devkit-version.mk: --Install a file recording the devkit version.
#
language = markdown
PACKAGE = devkit
package-type = rpm deb

DEB_ARCH = all
RPM_ARCH = noarch

MK_SRC = _VERSION.mk devkit-version.mk

include devkit.mk make/version.mk make/package.mk

$(DESTDIR_ROOT):
	$(ECHO_TARGET)
	$(MAKE) install DESTDIR=$$(pwd)/$@ prefix=$(prefix) usr=$(usr) opt=$(opt)

SPECS/devkit.spec: Makefile

#
# devkit.mk: --Fail if devkit is not available.
#
$(includedir)/devkit.mk:
	@echo "You need to do a self-hosted install:"
	@echo "    sh install.sh [make-arg.s...]"
	@false

#
# devkit-version.mk: --Install a file recording the devkit version.
#
install:	$(includedir)/devkit-version.mk

$(includedir)/devkit-version.mk: devkit-version.mk
	$(INSTALL_DATA) $? $@

devkit-version.mk: _VERSION _BUILD
	date "+# DO NOT EDIT.  This file was generated by $$USER. %c" >$@
	echo "export DEVKIT_VERSION=$$(cat _VERSION)" >$@
	echo "export DEVKIT_BUILD=$$(cat _BUILD)" >>$@

uninstall:	uninstall-local
uninstall-local:
	$(ECHO_TARGET)
	$(RM) $(includedir)/devkit-version.mk
	-$(RMDIR) -p $(includedir) 2>/dev/null

distclean:	clean-this
clean-this:
	$(RM) devkit-version.mk
