#
# GITVERSION.MK -- Rules for determining git local version information.
#
# Copyright (c) 2023 Procept Pty. Ltd. All rights reserved.
# SPDX-License-Identifier: LicenseRef-Procept
#

long_version_cmd = git describe --always --first-parent --long --dirty 2>/dev/null || echo unknown

export LONG_VERSION = $(eval LONG_VERSION:=$(shell ${long_version_cmd}))${LONG_VERSION}

cut_version_cmd = echo ${LONG_VERSION} | \
        sed -re 's/^(.*)-([[:digit:]]+)-(g[[:xdigit:]]+)(-(dirty))?$$/\1 \2 \3 \5/'

export VERSION_PARTS = $(eval VERSION_PARTS:=$(shell ${cut_version_cmd}))${VERSION_PARTS}

export VERSION_TAG = $(eval VERSION_TAG:=$(word 1,${VERSION_PARTS}))${VERSION_TAG}
export VERSION_COUNT = $(eval VERSION_COUNT:=$(word 2,${VERSION_PARTS}))${VERSION_COUNT}
export VERSION_SHA1 = $(eval VERSION_SHA1:=$(word 3,${VERSION_PARTS}))${VERSION_SHA1}
export VERSION_DIRTY = $(eval VERSION_DIRTY:=$(word 4,${VERSION_PARTS}))${VERSION_DIRTY}

export LOCAL_VERSION = $(eval LOCAL_VERSION:=$(if ${VERSION_COUNT:0=},-${VERSION_COUNT}-${VERSION_SHA1})${VERSION_DIRTY:%=-%})${LOCAL_VERSION}
export VERSION = $(eval VERSION:=${VERSION_TAG}${LOCAL_VERSION})${VERSION}
