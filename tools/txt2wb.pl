#!/usr/bin/perl

$max_src = 30;
$max_dest = 51;

while(<>) {
  @zeile = split("=", $_);
  chomp @zeile;
  $zeile[0] =~  s/\s*$//g;
  $zeile[0] =~  s/^\s*//g;
  $zeile[1] =~  s/\s*$//g;
  $zeile[1] =~  s/^\s*//g;


$zeile[0] = substr $zeile[0], 0, $max_src;
print $zeile[0];
  for ($i=0;$i<=$max_src - length( $zeile[0]) ;$i++) { print chr(0)}; 

$zeile[1] = substr $zeile[1], 0, $max_dest;
print $zeile[1];
  for ($i=0;$i<=$max_dest + 1 - length( $zeile[1]) ;$i++) { print chr(0)};
};

