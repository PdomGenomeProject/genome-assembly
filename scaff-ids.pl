#!/usr/bin/perl
#
# -----------------------------------------------------------------------------
# Copyright (c) 2012-2015   Daniel Standage <daniel.standage@gmail.com>
# Copyright (c) 2012-2015   Indiana University
#
# This file is part of the Polistes dominula genome project and is licensed
# under the Creative Commons Attribution 4.0 International License.
# -----------------------------------------------------------------------------
use strict;
use Bio::SeqIO;

my $prefix = shift(@ARGV);

my $instream  = Bio::SeqIO->new( -fh => \*STDIN,  -format => 'Fasta' );
my $outstream = Bio::SeqIO->new( -fh => \*STDOUT, -format => 'Fasta' );
my $scaf_counter = 0;
while(my $seq = $instream->next_seq )
{
  $scaf_counter++;
  my $scaf_number = $scaf_counter;
  $scaf_number = "0" . $scaf_number while(length($scaf_number) < 4);
  my $id = $prefix ? $prefix . $scaf_number : "scaffold_$scaf_number";
  $seq->id($id);
  $outstream->write_seq($seq);
}
