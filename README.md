
This Perl script allows to consult the COLMEX's spanish DEM dictionary without a user interface.

Right now it can just generate Rich Text terminal output or Markdown from a HTML file.

Input can be supplied as an argument or from stdin.

I hacked this all together last night without previous Perl knowledge. I feel the Perl power now.

It doesn't use external dependencies, nor will it in the future. So it should run in every computer. All the most used operating systems ship with Perl, right?

Usage:

```bash
$ curl https://dem.colmex.mx/Ver/pato | ./dem.pl
$ ./dem.pl --input page.html
$ curl https://dem.colmex.mx/Ver/pato | ./dem.pl -m
$ curl https://dem.colmex.mx/Ver/pato | ./dem.pl -markdown
```
