#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';
use Getopt::Long;

my $inputopt = '';
my $markdowopt = '';

GetOptions(
    'input=s' => \$inputopt,
    'markdown!' => \$markdowopt,
);

my $userinput = '';
my $datahtml = '';

# Read from STDIN or from a file as argument
if ($inputopt eq '') {
  $userinput = do { local $/; <STDIN> };
} else {
  $userinput = $inputopt;
}

# Call curl to get the data
my $command = "curl -s https://dem.colmex.mx/Ver/".$userinput;
$datahtml = `$command`;

# Does the term exist in the dictionary?
if ($datahtml =~ /no se ha incluido entre las entradas del diccionario. Sin embargo,/) {
  say "The term does not exist in the dictionary.";
  if ($datahtml =~ /Los siguientes vocablos guardan cierta similitud con el que se busca:/) {
    say "The following words have a similarity with the term you are looking for:";
    my $regexexp = qr/<a id="MainContent_repeaterDistancia_lbnPalabra_(\d+)"[^>]*>(.*?)<\/a>/s;
    while ($datahtml =~ m{ $regexexp }gx) {
      say "$1: $2";
    }
  }
  exit;
}

# Strip only the definitions with the numeration from the input
my $def = qr/<span\s+id="MainContent_repeater_[a-zA-Z0-9]+_(\d+)">(.*?)<\/span>/s;

# Replace " with « and »
$datahtml =~ s/&#8220;/«/g;
$datahtml =~ s/&#8221;/»/g;

# Remove <br />
$datahtml =~ s/<br \/>//g;
# Remove empty html tags
$datahtml =~ s/<[^>^\/]+><\/[^>^\/]+>//g;

# Change <i> </i> to markdown syntax for italics
$datahtml =~ s/<i>(.*?)<\/i>/_$1_/g;
# Change <b> </b> to markdown syntax for bold
$datahtml =~ s/<b>(.*?)<\/b>/\*$1\*/g;

# Add delimiters
$datahtml =~ s/(\*\d+\*)/\%\%ENDSG\%\%\n\%\%BEGINSG\%\%$1./g;

# Remove newlines in text between %%BEGINSG%% and %%ENDSG%%
# my $sgremover = s/\%\%BEGINSG\%\%\n([^\n]*)\n\%\%ENDSG\%\%/$1/g;

my $counter = 0;
my $endpt = "";

my $newtxt = "";
while ($datahtml =~ m{ $def }gx) {
    #Match if not empty
    if ($2) {
        #End if $1 is less than $counter
        if ($1 < $counter) {
            last;
        }
        $newtxt = $newtxt . $2 . "\n";
        #Increment counter if definition is greater than $counter
        $counter = $1 if $1 > $counter;
    }
}

# Add missing %%ENDSG%%
$newtxt = $newtxt . "%%ENDSG%%";

# Remove first %%ENDSG%%
$newtxt =~ s/\%\%ENDSG\%\%//;

my $newtxt2 = "";
my $svnl = 1;
# read each line of $newtxt
for my $line (split /\n/, $newtxt) {
  my $newline = " ";
  if ($line =~ /\%\%BEGINSG\%\%/g) {
    $svnl = 0;
  }
  if ($line =~ /\%\%ENDSG\%\%/g) {
    $svnl = 1;
  }
  if ($svnl) {
    $newline = "\n";
  }
  $newtxt2 = $newtxt2 . $line . $newline;
}

# Delete all %%BEGINSG%% and %%ENDSG%%
$newtxt2 =~ s/\%\%BEGINSG\%\%//g;
$newtxt2 =~ s/\%\%ENDSG\%\%//g;

# Add a newline before each roman numeral
$newtxt2 =~ s/(\*[IVXLCDM]+\*) /\n\n$1.\n/g;

# Fixes
$newtxt2 =~ s/\n\n\%\%BEGINSG\%\%/\n\%\%BEGINSG\%\%/g;
$newtxt2 =~ s/(\*I\*)/\n$1./g;
$newtxt2 =~ s/(\*[IVXLCDM]+\*\.)\n\n/$1\n/g;

# Print markdown if --markdown is set
if ($markdowopt) {
  say $newtxt2;
} else {
  my $terminalrichtext = $newtxt2;
  # Replace Bold
  $terminalrichtext =~ s/\*([^\*]+)\*/\e[1m$1\e[0m/g;
  # Replace Italics (use underline because italics are not widely supported)
  $terminalrichtext =~ s/_([^_]+)_/\e[4m$1\e[0m/g;
  say $terminalrichtext;
}
