#/usr/bin/perl -w
use strict;
use warnings;

use LaTeXML::Converter;
use LaTeXML::Util::Config;
use JSON::XS;
my $json = JSON::XS->new;
use Scalar::Util qw/reftype/;
use Data::Dumper;
# Collects and outputs all command sequences for a given set of LaTeX classes and packages
my (@packages) = @ARGV;
# If empty input - describe all available LaTeXML bindings
if (!scalar(@packages)) {
  my ($package_directory) = grep { -d $_ } map { "$_/LaTeXML/Package" } @INC;
  opendir(my $dh, $package_directory);
  @packages = map {s/\.ltxml$//; $_;} grep {/\.ltxml$/} readdir($dh);
  closedir($dh); }
my %package_test = map {$_=>1} @packages;
my %dictionary;
my %dependencies;

# We need to preload each package individually, to make sure we avoid messing up the state with varius overwrites
my $total = scalar(@packages);
my $current = 0;
foreach my $package(@packages) {
  print STDERR "Reporting on $package [",++$current,"/","$total]...\n";
  my $config = LaTeXML::Util::Config->new();
  $config->set('preload',[$package]);

  my $converter = LaTeXML::Converter->get_converter($config);
  $converter->prepare_session($config);
  my $state = $converter->{latexml}->{state};
  my $meaning_table = $state->{table}->{meaning};

  foreach my $key(keys %$meaning_table) {
    my $definition = $meaning_table->{$key}->[0];
    my $type = reftype($definition);
    next unless $type && ($type eq 'HASH');
    my $locator = $definition->{locator};
    # We want to record the CS Name in the actual definition,
    # to avoid the aliasing confusion from using \let
    my $csname = $definition->getCSName;
    if ($locator =~ /^from\s(\S+\.\S+)(\.ltxml)?\s/) {
      my $source = $1;
      $dictionary{$source}->{$csname} = 1;
      if ($source ne $package) {
        # Record dependencies with at least one command sequence definition
        $dependencies{$package}->{$source} = 1; }
    }}}

# Refine the dictionary csnames into an array
foreach my $key(keys %dictionary) {
  $dictionary{$key} = [sort keys %{$dictionary{$key}}]; }
open my $fh, ">", "dictionary.json";
print $fh $json->pretty(1)->encode(\%dictionary);
close $fh;

# Refine the dependencies into an array
foreach my $key(keys %dependencies) {
  $dependencies{$key} = [sort keys %{$dependencies{$key}}]; }
open $fh, ">", "dependencies.json";
print $fh $json->pretty(1)->encode(\%dependencies);
close $fh;