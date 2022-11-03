#
# VERSION.MK --Rules for updating the project version.
#
# Contents:
# major-version: --Increment the major version number.
# minor-version: --Increment the minor version number.
# patch-version: --Increment the patch version number.
#
# Remarks:
# The project version is stored as a dotted triplet of numbers in the
# local file "VERSION".  The idea is to facilitate/encourage
# "semantic" versioning.  In any case, these rules provide mechanism
# only, not policy.
#
# In addition to the VERSION, a simple build identifier is stored in
# _BUILD.
#
# REVISIT: use git-describe (svn-describe) to set _BUILD.
#
.PHONY: clean-version major-version minor-version patch-version build-number

#
# major-version: --Increment the major version number.
#
# Remarks:
# A major version is used for significant architectural changes, and
# any backward incompatible changes.
#
major-version: _VERSION
	major=$$(<_VERSION cut -d. -f1); \
	minor=$$(<_VERSION cut -d. -f2); \
	patch=$$(<_VERSION cut -d. -f3); \
	echo "$$((major+1)).0.0" >_VERSION

#
# minor-version: --Increment the minor version number.
#
# Remarks:
# A minor version is used for feature development, or any
# backward compatible changes.
#
minor-version: _VERSION
	major=$$(<_VERSION cut -d. -f1); \
	minor=$$(<_VERSION cut -d. -f2); \
	patch=$$(<_VERSION cut -d. -f3); \
	echo "$$major.$$((minor+1)).0" >_VERSION

#
# patch-version: --Increment the patch version number.
#
# Remarks:
# Patch versions are used for bug fixes.
#
patch-version: _VERSION
	major=$$(<_VERSION cut -d. -f1); \
	minor=$$(<_VERSION cut -d. -f2); \
	patch=$$(<_VERSION cut -d. -f3); \
	echo "$$major.$$minor.$$((patch+1))" >_VERSION
