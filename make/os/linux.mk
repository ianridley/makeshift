#
# LINUX.MK	--Macros and definitions for (Debian) Linux.
#
# Remarks:
# The "linux" module provices customisations for the Linux OS.
# The default Linux variant is (currently!?) Debian, and so this
# include file sets up some definitions to assist building Debian
# packages.
#
OS.C_DEFS	= -D__Linux__ -D_BSD_SOURCE -D_XOPEN_SOURCE
OS.C++_DEFS	= -D__Linux__ -D_BSD_SOURCE -D_XOPEN_SOURCE

RANLIB		= ranlib
FAKEROOT	= fakeroot
GREP		= grep
INDENT          = indent

PKG_TYPE	= deb
