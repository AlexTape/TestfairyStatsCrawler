#!/usr/bin/perl

use strict;
use warnings qw(all);
use utf8;
use autodie;
use LWP;
use LWP::UserAgent;
use Term::ANSIColor qw(:constants);
use JSON::Parse 'parse_json';
use Getopt::Long;
use Pod::Usage;

## Simple Crawler for Testfairy.com REST API with basic CSV Output Options ##
our $VERSION = 0.1;

## Constants ##
our $URI   	  = "https://app.testfairy.com/api/1/projects";

####
## 
## Crawl Testfairy REST API 
##
####

# VERSION

=head1 SYNOPSIS

    Testfairy.pl [options]
    Options:
		-e      Email
		-t      API Token
		-p      Project ID (will list all relevant builds)
		-b      Build ID (will list all revelevant sessions)
		-s      Session ID (will list relevant session data)
		-f      Output File for concrete Session
		-c      Content of CSV Output File [cpu,memory,opengl,battery]

=head1 DESCRIPTION

Testfairy REST API Crawler

=cut

# obtain parameters
GetOptions(
	"e=s"				=> \my $EMAIL,
	"t=s"				=> \my $API_TOKEN,
	"p=i"				=> \my $PROJECT_ID,
	"b=i"				=> \my $BUILD_ID,
	"s=i"				=> \my $SESSION_ID,
	"f=s"				=> \my $FILE_NAME,
	"c=s"				=> \my $CONTENT_TYPE,
    q(help)             => \my $help,
    q(verbose)          => \my $verbose,
) or pod2usage(q(-verbose) => 1);
pod2usage(q(-verbose) => 1) if $help;

# some helper methods
sub success {
	my $msg = shift;
	if ($^O eq 'MSWin32') {
		print "Success: " . $msg . "\n";
	} else {
		print GREEN, "Success: " . $msg . "\n", RESET;
	}
}
sub info {
	my $msg = shift;
	if ($^O eq 'MSWin32') {
		print "Info:" . $msg . "\n";
	} else {
		print BLUE, "Info: " . $msg . "\n", RESET;	
	}
}
sub note {
	my $msg = shift;
	if ($^O eq 'MSWin32') {
		print "Note:" . $msg . "\n";
	} else {
		print MAGENTA, "Note: " . $msg . "\n", RESET;
	}
}
sub error {
	my $msg = shift;
	if ($^O eq 'MSWin32') {
		print "Error: ". $msg . "\n";
	} else {
		print RED, "Error: ". $msg . "\n", RESET;
	}
}
sub request {
	# define user agent
	my $ua = LWP::UserAgent->new();
	$ua->agent("USER/AGENT/IDENTIFICATION");

	# make request
	my $request = HTTP::Request->new(GET => $URI);

	# authenticate
	$request->authorization_basic($EMAIL, $API_TOKEN);

	# except response
	my $response = $ua->request($request);

	# get content of response
	return parse_json($response->content());
}

# check condition
if (!$EMAIL) {
	error("Missing EMAIL");
	pod2usage(q(-verbose) => 1);
}
if (!$API_TOKEN) {
	error("Missing API TOKEN");
	pod2usage(q(-verbose) => 1);
}

my $content = request();
if ($content->{"status"} eq "ok") {

	# query projects
	my @projects = @{$content->{"projects"}};

	if (!$PROJECT_ID) {

		# listing projects
		print "Projects:\tID\t\tNamespace\t\t\tName\n";
		for my $i (0 .. $#projects) {
			print "\t\t[" . ($i + 1) . "]\t\t" . $projects[$i]{"packageName"} . "\t\t" . $projects[$i]{"name"} . "\n";
		}

	} else {

		# query project builds
		my $project = $projects[($PROJECT_ID - 1)];
		$URI .= "/" . $project->{"id"} . "/builds";
		$content = request();
		my @builds = @{$content->{"builds"}};

		if (!$BUILD_ID) {

			# listing builds
			print "Builds:\t\tID\t\tAppname\t\t\tuploadDate\n";
			for my $i (0 .. $#builds) {
				print "\t\t[" . ($i + 1) . "]\t\t" . $builds[$i]{"appName"} . "\t\t" . $builds[$i]{"uploadDate"} . "\n";
			}

		} else {

			# query build sessions
			my $build = $builds[($BUILD_ID - 1)];
			$URI .= "/" . $build->{"id"} . "/sessions";
			$content = request();
			my @sessions = @{$content->{"sessions"}};

			if (!$SESSION_ID) {

				# listings sessions
				print "Sessions:\tID\t\tDevice\t\t\tTester\n";
				for my $i (0 .. $#sessions) {
					print "\t\t[" . ($i + 1) . "]\t\t" . $sessions[$i]{"device"} . "\t\t" . $sessions[$i]{"testerEmail"} . "\n";
				}

			} else {

				if (!$FILE_NAME) {
					error("Please specify output filename");
					pod2usage(q(-verbose) => 1);
				}
				if (!$CONTENT_TYPE) {
					error("Please specify output content type");
					pod2usage(q(-verbose) => 1);
 				}

				info("Obtain session..");
	
				# query build sessions
				my $session = $sessions[($SESSION_ID - 1)];
				$URI .= "/" . $session->{"id"};
				$content = request();

				# get sessions data
				my $data = $content->{"session"}->{"events"};
				
				info("Open output file: " . $FILE_NAME);
				open (my $OUT, ">", $FILE_NAME) or die "Could not open file '$FILE_NAME' $!";

				info("Obtaining data: " . $CONTENT_TYPE);

				if ($CONTENT_TYPE eq "cpu") {
					note("CPU data requested..");
					# read dataset
					my @dataset = @{$data->{"cpuInfoEvents"}};
					print $OUT "stime;utime;threads;ts\n";
					for my $i (0 .. $#dataset) {
						print $OUT $dataset[$i]{"stime"}.";".$dataset[$i]{"utime"}.";".$dataset[$i]{"threads"}.";".$dataset[$i]{"ts"}."\n";
					}
				}
				if ($CONTENT_TYPE eq "memory") {
					note("Memory data requested..");
					# read dataset
					my @dataset = @{$data->{"memoryInfo"}};
					print $OUT "shared;pss;private;ts\n";
					for my $i (0 .. $#dataset) {
						print $OUT $dataset[$i]{"shared"}.";".$dataset[$i]{"pss"}.";".$dataset[$i]{"private"}.";".$dataset[$i]{"ts"}."\n";
					}
				}
				if ($CONTENT_TYPE eq "opengl") {
					note("OpenGL data requested..");
					# read dataset
					my @dataset = @{$data->{"openglEvents"}};
					print $OUT "triangles;drawCalls;fps;ts\n";
					for my $i (0 .. $#dataset) {
						print $OUT $dataset[$i]{"triangles"}.";".$dataset[$i]{"drawCalls"}.";".$dataset[$i]{"fps"}.";".$dataset[$i]{"ts"}."\n";
					}
				}
				if ($CONTENT_TYPE eq "battery") {
					note("Battery data requested..");
					# read dataset
					my @dataset = @{$data->{"batteryInfoEvents"}};
					print $OUT "present;scale;technology;status;voltage;plugged;health;temperature;ts\n";
					for my $i (0 .. $#dataset) {
						print $OUT $dataset[$i]{"present"}.";".$dataset[$i]{"scale"}.";".$dataset[$i]{"technology"}.";".$dataset[$i]{"status"}
						.";".$dataset[$i]{"voltage"}.";".$dataset[$i]{"plugged"}.";".$dataset[$i]{"health"}.";".$dataset[$i]{"temperature"}.";"
						.$dataset[$i]{"ts"}."\n";
					}
				}

				info("Closing output file..");
				close $OUT;
				success("done..");

			}
		}
	}
	
} else {
	error("Ups.. API says STATUS: " . $content->{"status"});
	die ("Something went wrong..");
}


