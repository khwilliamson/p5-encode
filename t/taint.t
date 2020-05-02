#!/usr/bin/perl -T
use strict;
use Encode qw(encode decode);
use Scalar::Util qw(tainted);
use Test::More;
my $taint = substr($ENV{PATH},0,0);
my $str = "dan\x{5f3e}" . $taint;                 # tainted string to encode
my $bin = encode('UTF-8', $str);                  # tainted binary to decode
my $notaint = "";
my $notaint_str = "dan\x{5f3e}" . $notaint;
my $notaint_bin = encode('UTF-8', $notaint_str);
my @names = Encode->encodings(':all');
plan tests => 4 * @names;
for my $name (@names) {
    my ($d, $e, $s);
    eval {
        $e = encode($name, $str);
    };
  SKIP: {
      skip $@, 1 if $@;
      ok tainted($e), "encode $name";
    }
    $bin = $e.$taint if $e;
    eval {
        $d = decode($name, $bin);
    };
  SKIP: {
      skip $@, 1 if $@;
      ok tainted($d), "decode $name";
    }
}
for my $name (@names) {
    my ($d, $e, $s);
    eval {
        $e = encode($name, $notaint_str);
    };
  SKIP: {
      skip $@, 1 if $@;
      ok ! tainted($e), "encode $name";
    }
    $notaint_bin = $e.$notaint if $e;
    eval {
        $d = decode($name, $notaint_bin);
    };
  SKIP: {
      skip $@, 1 if $@;
      ok ! tainted($d), "decode $name";
    }
}
