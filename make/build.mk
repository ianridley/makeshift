#
# BUILD.MK --Rules for building (sub!) directories of packages.
#
# Contents:
# latest:   --Get the lastest released version of all packages.
# package:  --Create packages for each sub-directory.
# publish() --Publish latest packages to the repository.
#
# Remarks:
# These rules aren't used in any particular package, but are intended
# for use by a Makefile in a directory ABOVE all the packages, to
# automate the process of building a set of packages.
#
SORT_VERSION=sort -n -t. -k 1,1 -k 2,2 -k 3,3
ALL := $(shell svn ls $$SVN_ROOT | sed -e 's|/||')

#
# latest:  --Get the lastest released version of all packages.
#
.PHONY:	latest
latest:	$(SUBDIRS:%=latest@%)
$(SUBDIRS:%=latest@%):	pre-latest
pre-latest:	;
latest@%:
	@$(ECHO) "++ make[$@]"
	@tag=$$(svn ls $$SVN_ROOT/$*/tags | \
	    grep [0-9.]* | $(SORT_VERSION) | \
	    tail -1 | \
	    sed -e 's|/$$||'); \
	if [ -d $* ]; then \
	    current=$$(svn info $* | sed -ne '/URL: /s|URL: .*/||p'); \
	fi; \
	if [ "$$current" != "$$tag" ]; then \
	    echo "$*: removing release $$current"; \
	     $(RM) -r $*; \
	fi; \
	if [ ! -d $* ]; then \
	    echo "$*: unpacking release $$tag"; \
	    svn co $$SVN_ROOT/$*/tags/$$tag $*; \
	fi

latest@all: $(ALL:%=latest@%)

#
# package: --Create packages for each sub-directory.
#
# Remarks:
# Project top-level directories typically include "package.mk",
# which defines this target to build a REAL package.  The one we
# define here merely does the recursion.
#
.PHONY:	package
package:	$(SUBDIRS:%=package@%)
$(SUBDIRS:%=package@%):	pre-package
pre-package:	;
package@%:
	@if [ -e $*/Makefile ]; then cd $* && $(MAKE) package; fi

#
# publish() --Publish latest packages to the repository.
#
# Remarks:
# This target is designed to publish what it can, but skip
# over target directories that don't have a deb to publish.
#
.PHONY:	publish
publish:	$(SUBDIRS:%=publish@%)
$(SUBDIRS:%=publish@%):	pre-publish
pre-publish:	;
publish@%:
	@$(ECHO) "++ make[$@]"
	@deb=$$(find $* -maxdepth 1 -type f -name '$**.deb'); \
	if [ "$$deb" ]; then \
	    base=$$(basename $$deb); \
	    if [ ! -f $(REPO_DIR)/$$base ]; then \
		echo "publishing $$base"; \
		scp $$deb yirtl:; \
		sudo cp $$deb $(REPO_DIR); \
	    fi; \
	else \
	    echo "nothing to publish"; \
	fi

publish:
	@echo "...and now rebuild the repository metadata"