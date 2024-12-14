AC_PREREQ([2.69])
AC_INIT([program], [1.0], [foxira242@gmail.com])
AM_INIT_AUTOMAKE([foreign])
AC_PROG_CC                 # Ensure the C compiler is detected
AC_PROG_CXX                # Ensure the C++ compiler is detected

# Check for glib and gtest
PKG_CHECK_MODULES([PROGRAM], [glib-2.0])
PKG_CHECK_MODULES([GTEST], [gtest])

# Check if the header file for gtest exists
AC_CHECK_HEADERS([gtest/gtest.h])

# Check for the gtest library
AC_SEARCH_LIBS([gtest], [gtest])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT

