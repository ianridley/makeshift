#
# PACKAGE/DEBHELPER.MK --Targets for building Debian packages using debhelper
#
# Copyright (c) 2023 Procept Pty. Ltd. All rights reserved.
# SPDX-License-Identifier: LicenseRef-Procept
#
# Contents:
# package-deb:    --Build a debian package for the current version/release/arch.
# clean:          --Remove derived files created as a side-effect of packaging.
# distclean:      --Remove the package.
#

# Macros that control the generation files and meta-data required for
# building of packages. These may be customized
DEB_ARCH ?= any
DEB_BROWSE ?= $(shell echo ${DEB_SOURCE} |sed -re "s|git@(.*):(.*).git|https://\1/\2/|")
DEB_COMPAT ?= 13
DEB_DATE ?= $(shell git show --no-patch --format="%ad" @)
DEB_DISTRIBUTION ?= $(shell ${GIT_DIRTINESS_CMD})
DEB_LICENSES ?= $(wildcard ${topdir}/LICENSES/*.md)
DEB_MAINTAINER ?= $(shell git tag --list --format="%(taggername) %(taggeremail)" "${VERSION_TAG}")
DEB_COPYRIGHT_HOLDER ?= $(error DEB_COPYRIGHT_HOLDER is not defined)

DEB_SRC_PACKAGE ?= ${DEB_PROJECT}-$(notdir $(realpath ${CURDIR}))
DEB_BIN_PACKAGES ?= none
DEB_PROJECT ?= ${PROJECT}
DEB_RIGHTS ?= All rights reserved.
DEB_SOURCE ?= $(shell git remote get-url origin)
DEB_URGENCY ?= medium
DEB_VERSION ?= ${VERSION:v%=%}
DEB_YEAR ?= $(word 5,${DEB_DATE})

# Version and package name strings.
V-B_A = ${VERSION}${BUILD:%=-%}${DEB_ARCH:%=_%}
P_V-B_A	= ${PACKAGE}${V-B_A:%=_%}

# Set *NOCHECK* if we're cross compiling.
NOCHECK ?= $(if $(filter $(ARCH),$(shell uname -m)),,1)

# Sometimes we need to take specific action when make is invoked
# directly or invoked from a debian/rules target recipe. To manage this
# we will arrange that debian/rules set one or more of the following
# macros to 1.
DH_AUTO_CLEAN ?= 0
DH_AUTO_BUILD ?= 0
DH_AUTO_INSTALL ?= 0

# Determine what the topdir is.
topdir ?= $(eval topdir:=$(shell git rev-parse --show-toplevel))${topdir}

# Use `git-describe` to determine how *dirty* the sources are and in
# turn set the *distribution* to stable, unstable or experimental
# accordingly. The defaults below assume git-scm is in use.
SED_DIRTINESS_CMD ?= 's/.*-([[:digit:]]+)-g[[:xdigit:]]+(-dirty)?/\1\2/'
GIT_DIRTINESS_CMD ?= git describe --long --dirty | \
    sed -re ${SED_DIRTINESS_CMD} \
        -e 's/^0$$/stable/' \
        -e 's/^[[:digit:]]+$$/unstable/'\
        -e 's/.*-dirty/experimental/'

#
# A directory in which to construct all the meta files needed to build
# packages using debhelper.
#
debuilddir = $(archdir)/debuild
debiandir = ${debuilddir}/debian

${debuilddir}:
	${MKDIR} $@

${debiandir}:
	${MKDIR} $@

#
# dpkg-architecture
#
${debuilddir}/dpkg-architecture: | ${debuilddir}
	CC=${CROSS_COMPILE}${CC} dpkg-architecture ${ARCH:%=-a%} --print-format=make > $@

ifeq ($(filter clean distclean,$(MAKECMDGOALS)),)
include $(debuilddir)/dpkg-architecture
endif

#
# deb: --Build a debian package for the current version/release/arch.
#
# Remarks:
# "package-deb" and "deb" are aliases, for convenience.
#
.PHONY: package-deb deb
package deb: package-deb

package-deb: ${debuilddir}/../$(P_V-B_A).deb

${debuilddir}/../$(P_V-B_A).build \
${debuilddir}/../$(P_V-B_A).buildinfo \
${debuilddir}/../$(P_V-B_A).changes \
${debuilddir}/../$(P_V-B_A).deb: prepare-debian
	$(ECHO_TARGET)
	cd ${debuilddir}; \
	DEB_BUILD_OPTIONS="$(if $(NOCHECK),nocheck)" \
	debuild ${CC:%=-eCC=${CROSS_COMPILE}%} -ePROJECT=${PROJECT} \
	    ${DEB_HOST_ARCH:%=-a%} -b -ui -us -uc $(if $(NOCLEAN),-nc)

#
# Create a file of sed compatible substitutions. Used to update
# tokens in various template files.
#
${debuilddir}/substitutions: | ${debuilddir}
	@echo "# Automatically generated, edit at own risk." > $@
	@echo "s|\{\{deb-source\}\}|${DEB_SOURCE}|g" >> $@
	@echo "s|\{\{deb-browse\}\}|${DEB_BROWSE}|g" >> $@
	@echo "s|\{\{maintainer\}\}|${DEB_MAINTAINER}|g" >> $@
	@echo "s|\{\{DISTRIBUTION\}\}|\U${DEB_DISTRIBUTION}|g" >> $@
	@echo "s|\{\{Distribution\}\}|\u${DEB_DISTRIBUTION}|g" >> $@
	@echo "s|\{\{distribution\}\}|\L${DEB_DISTRIBUTION}|g" >> $@
	@echo "s|\{\{PROJECT\}\}|\U${DEB_PROJECT}|g" >> $@
	@echo "s|\{\{Project\}\}|\u${DEB_PROJECT}|g" >> $@
	@echo "s|\{\{project\}\}|\L${DEB_PROJECT}|g" >> $@
	@echo "s|\{\{PACKAGE\}\}|\U${DEB_SRC_PACKAGE}|g" >> $@
	@echo "s|\{\{Package\}\}|\u${DEB_SRC_PACKAGE}|g" >> $@
	@echo "s|\{\{package\}\}|\L${DEB_SRC_PACKAGE}|g" >> $@
	@echo "s|\{\{URGENCY\}\}|\U${DEB_VERSION}|g" >> $@
	@echo "s|\{\{Urgency\}\}|\u${DEB_URGENCY}|g" >> $@
	@echo "s|\{\{urgency\}\}|\L${DEB_URGENCY}|g" >> $@
	@echo "s|\{\{VERSION\}\}|\U${DEB_VERSION}|g" >> $@
	@echo "s|\{\{Version\}\}|\u${DEB_VERSION}|g" >> $@
	@echo "s|\{\{version\}\}|\L${DEB_VERSION}|g" >> $@

#
# changelog -- create the *changelog* file.
#

# Default template for generating the `debain/changelog` file.
DEB_CHANGELOG ?= debian/changelog

# Remove any comments from the *changelog* template.
${debuilddir}/changelog.template: ${DEB_CHANGELOG} | ${debuilddir}
	sed -E '/^\#/d; /./,$$!d' $< > $@

# Use the tempate with `git-tag` to generate a changelog from the
# annotated tag's message and meta-data, then piped through *sed* to
# make further substitutions and reformat the sign-off lines to comply
# with required changelog format.
${debiandir}/changelog: ${debuilddir}/substitutions | ${debuilddir}
${debiandir}/changelog: ${debuilddir}/changelog.template
	${Q}echo "make: generating '$@'"
	git tag --list --format="$$(cat $<)" "${VERSION_TAG}" | \
	sed -rf ${debuilddir}/substitutions \
	    -e '2,$$s/^/  /;$$s/^\s*--/ --/' > $@

#
# compat -- create the *compat* file.
#

${debiandir}/compat: | ${debiandir}
	${Q}echo "make: generating '$@'"
	${Q}echo ${DEB_COMPAT} > $@

#
# control -- create the *control* file.
#
# Remove header comments and apply substitutions to control stanza
# fragments and combine into a single debian/control.
#

${debiandir}/control: ${debuilddir}/substitutions | ${debiandir}
${debiandir}/control: debian/control ${DEB_BIN_PACKAGES:%=debian/%.control}
	${Q}echo "make: generating '$@'"
	for stanza in debian/control ${DEB_BIN_PACKAGES:%=debian/%.control}; do \
	  sed -re '/^\#/d; /./,$$!d' \
	      -f ${debuilddir}/substitutions $${stanza} ; echo ""; \
	done | cat -s > $@

#
# copyright -- create the *copyright* file, copies the file stanzas
# from the debian/copyright file and adds the license stanzas.
#
${debiandir}/copyright: | ${debuilddir} ${debiandir}
${debiandir}/copyright: debian/copyright
	cat -s $< > $@
	echo -n "$@: " > ${debuilddir}/${@F}.d
	sed -nre "s|License: ||p" $< | sort -u | \
	while read lic; do \
	  path=$$(find ${topdir} -path "*/LICENSES/$$lic.*" | head -1); \
	  if [ -f "$$path" ]; then \
	    echo "\nLicense: $$lic" >> $@; \
	    cat -s $$path | sed "s/^/ /" >> $@; \
		echo -n " $$path" >> ${debuilddir}/${@F}.d; \
	  else \
	    echo "error: could not file license file for: $$lic" >&2; \
	    exit 1; \
	  fi; \
	done
	echo "" >> $(debuilddir)/${@F}.d

-include $(debuilddir)/copyright.d

#
# Perform substitutions and set file mode on scripts.
#
DEB_SH_SUBST = PACKAGE KERNELRELEASE
DEB_SH_SUBST[KERNELRELEASE] = ${KERNELRELEASE}
DEB_SH_SUBST[PACKAGE] = $(basename ${@F})
DEB_SH_SUBST[SCRIPT] = $(patsubst .%,%,$(suffix ${@F}))

DEB_SH_SUBST_ARGS = $(foreach s,${DEB_SH_SUBST}, -e "s/@${s}@/${DEB_SH_SUBST[${s}]}/g")

# Make with DEBUG=1 to substitute "#DEBUG#" in maintainer scripts with some debug...
ifneq (${DEBUG},)
define DEB_SH_DEBUG_ARGS
-e '1s~/bin/sh -e~/bin/sh -ex~'
-e '2,$$s/#DEBUG#/printf "%b" "\\033[32m${DEB_SH_SUBST[PACKAGE]}: ${DEB_SH_SUBST[SCRIPT]}: $$*\\033[0m\\n"/'
endef
endif

${debiandir}/rules: debian/rules.mk | ${debiandir}
	@$(ECHO_TARGET)
	install -D -m 755 $< $@

$(debiandir)/${DEB_SRC_PACKAGE}-%: debian/%.sh | ${debiandir}
	@$(ECHO_TARGET)
	sed ${DEB_SH_SUBST_ARGS} ${DEB_SH_DEBUG_ARGS} $< > $@
	chmod +x $@

${debiandir}/${DEB_SRC_PACKAGE}-%.install: debian/%.install | ${debiandir}
	@$(ECHO_TARGET)
	install -D -m 644 $< $@

${debiandir}/${DEB_SRC_PACKAGE}-%.overrides: debian/%.overrides | ${debiandir}
	@$(ECHO_TARGET)
	install -D -m 644 $< $@

#
# prepare: --
#
.PHONY: prepare prepare-debian
prepare: prepare-debian
prepare-debian: \
	${debiandir}/rules \
	${debiandir}/changelog \
	${debiandir}/compat \
	${debiandir}/control \
	${debiandir}/copyright \
	${DEB_SH_SRC:debian/%.sh=$(debiandir)/${DEB_SRC_PACKAGE}-%} \
	${DEB_INSTALL_SRC:debian/%=$(debiandir)/${DEB_SRC_PACKAGE}-%} \
	${DEB_OVERRIDES_SRC:debian/%=$(debiandir)/${DEB_SRC_PACKAGE}-%}

#
# install: --
#
.PHONY: install-overrides
install: install-overrides
install-overrides: ${OVERRIDES_SRC:lintian/%.overrides=${lintian_datadir}/overrides/%}

lintian_datadir ?= ${DESTDIR}/usr/share/lintian

${lintian_datadir}/overrides/%: debian/%.overrides
	install -D -m 644 $< $@

#
# src: -- Update the DEB_OVERRIDES_SRC and DEB_MAINT_SRC macros.
#
.PHONY: src-debhelper
src: src-debhelper
src-debhelper:
	${ECHO_TARGET}
	${Q}mk-filelist -f ${MAKEFILE} -qn DEB_OVERRIDES_SRC debian/*.overrides
	${Q}mk-filelist -f ${MAKEFILE} -qn DEB_SH_SRC debian/*.sh
	${Q}mk-filelist -f ${MAKEFILE} -qn DEB_INSTALL_SRC debian/*.install

#
# clean: -- Remove derived files created as a side-effect of packaging.
#
.PHONY: clean-debhelper-0 clean-debhelper-1
clean: clean-debhelper-${DH_AUTO_CLEAN}
clean-debhelper-1:;
clean-debhelper-0:
	test -f ${debiandir}/control && cd ${debuilddir} && dh_clean || :
	${RM} ${debiandir}/changelog ${debiandir}/compat \
	      ${debiandir}/control ${debiandir}/copyright \
	      ${debiandir}/rules \
		  ${DEB_SH_SRC:debian/%.sh=${debiandir}/${PACKAGE}-%} \
		  ${DEB_INSTALL_SRC:debian/%=${debiandir}/${PACKAGE}-%} \
		  ${DEB_OVERRIDES_SRC:debian/%=${debiandir}/${PACKAGE}-%}
	${RM} ${debuilddir}/copyright.d ${debuilddir}/changelog.template ${debuilddir}/dpkg-architecture ${debuilddir}/substitutions

#
# distclean: -- Remove the package.
#
.PHONY: distclean-debhelper-0 distclean-debhelper-1
distclean: distclean-debhelper-${DH_AUTO_CLEAN}
distclean-debhelper-1: clean-debhelper-1; @:
distclean-debhelper-0: clean-debhelper-0; @:
