#
# WINDOWS_NT.MK	--Macros and definitions for (Cygwin) Windows_NT
#
# Remarks:
#
OS.C_DEFS	= -D__Windows_NT__
# -D_BSD_SOURCE -D_XOPEN_SOURCE
OS.C++_DEFS	= -D__Windows_NT__
# -D_BSD_SOURCE -D_XOPEN_SOURCE

RANLIB		= ranlib
FAKEROOT	= fakeroot
GREP		= grep
INDENT          = indent

PKG_TYPE	= deb

