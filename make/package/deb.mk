#
# DEB.MK --Targets for building Debian packages.
#
# Contents:
# deb:            --Build a debian package for the current version/release/arch.
# debian-binary:  --Create the "debian-binary" file automatically.
# control.tar.gz: --Create the control tarball from the debian subdirectory.
# data.tar.gz:    --Create the installed binary tarball.
# md5sums:        --Calculate the md5sums for all the installed files.
# conffiles:      --Make "conffiles" as required.
# control:        --Make "control" from control.txt.
# clean:          --Remove derived files created as a side-effect of packaging.
# distclean:      --Remove the package.
#
# Remarks:
# There are many ways to build a debian package, and this is
# just one more to add to the confusion.
#
DEB_ARCH ?= $(shell mk-deb-buildarch debian/control)
DEB_ARCH := $(DEB_ARCH)

V.B_A	= $(VERSION)$(BUILD:%=.%)$(DEB_ARCH:%=_%)
P_V.B_A	= $(PACKAGE)$(VERSION:%=_%)$(BUILD:%=.%)$(DEB_ARCH:%=_%)

#
# deb: --Build a debian package for the current version/release/arch.
#
# Remarks:
# "package-deb" and "deb" are aliases, for convenience.
#
.PHONY:		package-deb deb
package:	package-deb
deb:		package-deb
package-deb:	 $(P_V.B_A).deb

$(P_V.B_A).deb:	debian-binary control.tar.gz data.tar.gz
	$(ECHO_TARGET)
	$(FAKEROOT) mk-ar debian-binary control.tar.gz data.tar.gz >$@

#
# debian-binary: --Create the "debian-binary" file automatically.
#
debian-binary:	;	echo "2.0" > $@

#
# control.tar.gz: --Create the control tarball from the debian subdirectory.
#
control.tar.gz:	debian/control debian/md5sums debian/conffiles
	$(ECHO_TARGET)
	(cd debian; \
	    test -f Makefile && $(MAKE) $(MFLAGS) all; \
	    $(FAKEROOT) tar zcf ../$@ --exclude 'Makefile' --exclude '*.*' *)

#
# data.tar.gz: --Create the installed binary tarball.
#
data.tar.gz:	$(DESTDIR_ROOT)
	$(ECHO_TARGET)
	(cd $(DESTDIR_ROOT); $(FAKEROOT) tar zcf ../$@ *)

#
# md5sums: --Calculate the md5sums for all the installed files.
#
debian/md5sums: $(DESTDIR_ROOT)
	$(ECHO_TARGET)
	find $(DESTDIR_ROOT) -type f | xargs md5sum | sed -e s@$(DESTDIR_ROOT)/@@ > $@
	chmod 644 $@

#
# conffiles: --Make "conffiles" as required.
#
# Remarks:
# This rule makes the file if it doesn't exist, but if it's
# subsequently modified it won't be trashed by this rule.
#
debian/conffiles: $(DESTDIR_ROOT)
	$(ECHO_TARGET)
	@touch $@
	@if [ -d $(DESTDIR_ROOT)/etc ]; then \
	    $(ECHO) '++make[$@]: automatically generated'; \
	    find $(DESTDIR_ROOT)/etc -type f | sed -e s@$(DESTDIR_ROOT)/@/@ > $@; \
	    chmod 644 $@; \
	fi

#
# control: --Make "control" from control.txt.
#
debian/control: debian/control.txt
	$(ECHO_TARGET)
	sed -e 's/PACKAGE/$(PACKAGE)/' $< >$@
	sed -i -e 's/VERSION/$(VERSION)/' $@
	sed -i -e 's/ARCH/$(DEB_ARCH)/' $@

#
# clean: --Remove derived files created as a side-effect of packaging.
#
clean:	clean-deb
distclean:	clean-deb distclean-deb

.PHONY: clean-deb
clean-deb:
	$(ECHO_TARGET)
	$(RM) debian/control debian-binary control.tar.gz data.tar.gz

#
# distclean: --Remove the package.
#
.PHONY: distclean-deb
distclean-deb: clean-deb
	$(ECHO_TARGET)
	$(RM) debian/conffiles debian/md5sums $(P_V.B_A).deb
