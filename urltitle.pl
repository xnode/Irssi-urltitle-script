#
# Fetches title for URLs Irssi Script
#
use strict;
use Irssi;
use Irssi::Irc;
use LWP::UserAgent;
use HTML::Entities;
use vars qw($VERSION %IRSSI $PRINT_ORIGINAL_URL);

$VERSION = '0.3';
$PRINT_ORIGINAL_URL = 0;

%IRSSI = (
    authors     => 'Toni Ahola',
    contact     => 'tkahola@gmail.com',
    name        => 'urltitle',
    description => 'Prints titles from URLs',
    license     => 'Public Domain',
    url         => '',
);

sub urltitle_public {
    my ($server, $data, $nick, $mask, $target) = @_;
    my $retval = urltitle_get($data);
    my $win    = $server->window_item_find($target);
    if ($win) {
        $win->print("[%Gurltitle%n] $retval", MSGLEVEL_CRAP) if $retval;
    } else {
        Irssi::print("[%Gurltitle%n] $retval") if $retval;
    }
}

sub urltitle_private {
    my ($server, $data, $nick, $mask) = @_;
    my $retval = urltitle_get($data);
    my $win    = $server->window_item_find($nick);
    if ($win) {
        $win->print("[%Gurltitle%n] $retval", MSGLEVEL_CRAP) if $retval;
    } else {
        Irssi::print("[%Gurltitle%n] $retval") if $retval;
    }
}

sub urltitle_parse {
    my ($url) = @_;
    if ( $url =~ m|(http://[\w\.\-/\?\&=%\+]+)| ) {
        return $1;
    }
    return 0;
}

sub urltitle_get {
    my ($data) = @_;

    my $url = urltitle_parse($data);

	# this check is from similar script (http://paste.lisp.org/display/58040)
	if($url !~ m{\.(?:jpe?g|gif|png|tiff?|m?pkg|zip|sitx?|.ar|pdf|gz|bz2|7z|txt|js|css|mp.|aiff?|wav|snd|mod|m4a|m4p|wma|wmv|ogg|swf|mov|mpe?g|avi)$}i) {
    	my $ua = LWP::UserAgent->new(env_proxy=>1, 
			keep_alive=>1, 
			timeout=>5, 
			protocols_allowed => ['http']
			);
    		$ua->agent("irssi-urltitle/$VERSION " . $ua->agent());
    		my $req = HTTP::Request->new('GET', $url);
    		my $res = $ua->request($req);
    		if ($res->is_success()) {
				my($title) = decode_entities($res->title());
				$title =~ s/\s+/ /g;
        		return ($PRINT_ORIGINAL_URL?$url." => %c":"%c").$title."%n";
    		}
	}
    return 0;
}

Irssi::signal_add_last('message public', 'urltitle_public');
Irssi::signal_add_last('message private', 'urltitle_private');
