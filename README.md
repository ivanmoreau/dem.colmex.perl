
This Perl script allows to consult the COLMEX's spanish DEM dictionary without a user interface.

Right now it can just generate Rich Text terminal output or Markdown.

Input can be supplied as an argument or from stdin.

I hacked this all together last night without previous Perl knowledge. I feel the Perl power now.

It doesn't use external dependencies, nor will it in the future. So it should run in every computer. All the most used operating systems ship with Perl, right?

Usage:

```bash
$ echo pato | ./dem.pl
$ ./dem.pl --input pato
$ echo pato | ./dem.pl -m
$ echo pato | ./dem.pl -markdown
```
