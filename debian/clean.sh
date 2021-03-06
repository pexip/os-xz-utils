#!/bin/sh
# Remove files generated by autoreconf -fi.
# For use by the clean target in debian/rules.

set -e

remove_files='#!/usr/bin/perl
# Remove specified files from the current directory.
# Each line must be a filename, a comment (starting with #),
# a simple glob (of the form *.extension), or blank.
# Filenames are restricted to a small character set.

use strict;
use warnings;

my $fnchar = qr/[-_~.@[:alnum:]]/;

my $empty = qr/^$/;
my $comment = qr/^#/;
my $simple = qr/^$fnchar+$/;
my $glob = qr/^\*$fnchar+$/;
while (my $line = <>) {
	chomp $line;
	next if $line =~ $empty;
	next if $line =~ $comment;

	if ($line =~ $simple) {
		unlink $line;
		next;
	}
	if ($line =~ $glob) {
		unlink glob($line);
		next;
	}

	die "cannot parse $line";
}
'

dh_testdir
rm -f debug/translation.bash tests/test_block.c
rm -f ABOUT-NLS aclocal.m4 config.h.in configure
(cd po && perl -e "$remove_files") < debian/generated-po.list
(cd m4 && perl -e "$remove_files") < debian/generated-m4.list
(cd build-aux && perl -e "$remove_files") < debian/generated-build-aux.list
find . -name Makefile.in -delete
