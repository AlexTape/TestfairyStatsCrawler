# Simple Client for Testfairy.com REST API

This very simple perl wrapper to do queries against the Testfairy.com REST API.

Usage:
        Testfairy.pl [options]
        Options:
                    -e      Email
                    -t      API Token
                    -p      Project ID (will list all relevant builds)
                    -b      Build ID (will list all revelevant sessions)
                    -s      Session ID (will list relevant session data)
                    -f      Output File for concrete Session
                    -c      Content of CSV Output File [cpu,memory,opengl,battery]

Examples:

To get a list of available projects simply do this:

$ perl -w crawl-testfairy.pl -e your@mail.com -t YOUR_API_TOKEN
Projects:	ID		Namespace					Name
			[1]		de.alextape.ExampleApp.tf		ExampleApp

To get deeper into your builds call:

$ perl -w crawl-testfairy.pl -e your@mail.com -t YOUR_API_TOKEN -p 1
Builds:		ID		Appname				uploadDate
			[1]		ExampleApp			2015-07-08 06:15:54
			[2]		ExampleApp			2015-07-08 05:56:16
			[3]		ExampleApp			2015-07-08 05:21:45

To get the relevant build sessions type:

$ perl -w crawl-testfairy.pl -e your@mail.com -t YOUR_API_TOKEN -p 1 -b 1
Sessions:	ID		Device					Tester
			[1]		samsung - SM-G901F		tester@mail.com
			[2]		samsung - SM-G901F		tester@mail.com
			[3]		Samsung - Galaxy S5		antoher@mail.org

If you want to export CPU, Memory, OpenGL or Battery statistics to an CSV file you can simply request them like this:

For CPU stats:

$ perl -w crawl-testfairy.pl -e your@mail.com -t YOUR_API_TOKEN -p 1 -b 1 -s 1 -f output.csv -c cpu
Info: Obtain session..
Info: Open output file: output.csv
Info: Obtaining data: cpu
Note: CPU data requested..
Info: Closing output file..
Success: done..

For Memory stats:

$ perl -w crawl-testfairy.pl -e your@mail.com -t YOUR_API_TOKEN -p 1 -b 1 -s 1 -f output.csv -c memory
Info: Obtain session..
Info: Open output file: output.csv
Info: Obtaining data: cpu
Note: Memory data requested..
Info: Closing output file..
Success: done..

For OpenGL stats:

$ perl -w crawl-testfairy.pl -e your@mail.com -t YOUR_API_TOKEN -p 1 -b 1 -s 1 -f output.csv -c opengl
Info: Obtain session..
Info: Open output file: output.csv
Info: Obtaining data: cpu
Note: OpenGL data requested..
Info: Closing output file..
Success: done..

For Battery stats:

$ perl -w crawl-testfairy.pl -e your@mail.com -t YOUR_API_TOKEN -p 1 -b 1 -s 1 -f output.csv -c battery
Info: Obtain session..
Info: Open output file: output.csv
Info: Obtaining data: cpu
Note: Battery data requested..
Info: Closing output file..
Success: done..

The stats will be saved to output.csv.

Example for CPU stats:

stime;utime;threads;ts
13;8;11;0.002
30;41;21;1.002
28;64;27;2.005
37;129;29;3.032
39;93;32;4.003
50;120;33;5.004
44;104;33;6.005
46;117;35;7.004
39;126;37;8.004
...

Have fun to use Testfairy data in e.g. your LaTeX Graphs or whatever :)


