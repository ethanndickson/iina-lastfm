#!/usr/bin/perl

use JSON::PP;
use Data::Dumper;
use LWP::UserAgent;
use Digest::MD5 qw(md5_hex);
use Encode qw(encode);

sleep(3);
$ua = LWP::UserAgent->new();
$lfmUrl = "http://ws.audioscrobbler.com/2.0";

$USERNAME = ''; # CHANGE ME
$PASSWORD = ''; # CHANGE ME
$APIKEY = "3176eb0bd0ff5d1c8f15d94e3b3c98a8"; # Change this if it stops working
$APISECRET = "2918fac730f44f543d2568f9976ec276"; # Change this if it stops working


# read from socket
$metaDataRaw = `echo '{ "command": ["get_property", "metadata"] }' | nc -U  /tmp/mpv-socket`; 
$durationRaw = `echo '{ "command": ["get_property", "duration"] }' | nc -U  /tmp/mpv-socket`;
$metaData = decode_json $metaDataRaw;
$durationData = decode_json $durationRaw; 
$mediaTitle = $metaData->{'data'}->{'Title'};
if (not $mediaTitle) {
	$mediaTitle = $metaData->{'data'}->{'title'};
}
if (not $mediaTitle) {
	$mediaTitle = $metaData->{'data'}->{'TITLE'};
}
$mediaArtist = $metaData->{'data'}->{'Artist'};
if (not $mediaArtist) {
	$mediaArtist = $metaData->{'data'}->{'artist'};
}
if (not $mediaArtist) {
	$mediaArtist = $metaData->{'data'}->{'ARTIST'};
}
$mediaAlbum = $metaData->{'data'}->{'Album'};
if (not $mediaAlbum) {
	$mediaAlbum = $metaData->{'data'}->{'album'};
}
if (not $mediaAlbum) {
	$mediaAlbum = $metaData->{'data'}->{'ALBUM'};
}
$mediaAlbumArtist = $metaData->{'data'}->{'album_artist'};
if (not $mediaAlbumArtist) {
	$mediaAlbumArtist = $metaData->{'data'}->{'Album_artist'};
}
if (not $mediaAlbumArtist) {
	$mediaAlbumArtist = $metaData->{'data'}->{'ALBUM_ARTIST'};
}
if (not $mediaAlbumArtist) {
	$mediaAlbumArtist = $metaData->{'data'}->{'albumArtist'};
}
if (not $mediaAlbumArtist) {
	$mediaAlbumArtist = $metaData->{'data'}->{'albumartist'};
}
$mediaDuration = $durationData->{'data'};
$mediaTimestamp = time();
if (not $mediaTitle) {
	die("Couldn't find a title for this track in metadata, not scrobbling");
}
if (not $mediaArtist) {
	die("Couldn't find an artist for this track in metadata, not scrobbling")
}
if (not $mediaDuration) {
	die("Couldn't get track duration")
}
$authSig = md5_hex(Encode::encode_utf8("api_key".$APIKEY."method"."auth.getMobileSession"."password".$PASSWORD."username".$USERNAME.$APISECRET));
$PASSWORD =~ s/([^-A-Za-z0-9_.!~*'() ])/sprintf("%%%02X", ord($1))/eg;
$auth = $lfmUrl."?method=auth.getMobileSession&username=".$USERNAME."&password=".$PASSWORD."&api_key=".$APIKEY."&api_sig=".$authSig;
$authOutput = $ua->post($auth);
$authOutput = Dumper($authOutput);
if ($authOutput =~ /<key>(.*?)<\/key>/) {
	$sessionKey = $1;
} else {
	die("Failed auth, make sure you entered your login details correctly");
}

$scrobbleSig = "api_key".$APIKEY."artist".$mediaArtist."method"."track.scrobble"."sk".$sessionKey."timestamp".$mediaTimestamp."track".$mediaTitle.$APISECRET;
$scrobbleSig = "albumArtist".$mediaAlbumArtist.$scrobbleSig if $mediaAlbumArtist;
$scrobbleSig = "album".$mediaAlbum.$scrobbleSig if $mediaAlbum;
$scrobbleSig = md5_hex(Encode::encode_utf8($scrobbleSig));

$mediaArtist = Encode::encode_utf8($mediaArtist);
$mediaTitle = Encode::encode_utf8($mediaTitle);
$mediaAlbum = Encode::encode_utf8($mediaAlbum) if $mediaAlbum;
$mediaAlbumArtist = Encode::encode_utf8($mediaAlbumArtist) if $mediaAlbumArtist;

$mediaArtist =~ s/([^-A-Za-z0-9_.!~*'() ])/sprintf("%%%02X", ord($1))/eg;
$mediaTitle =~ s/([^-A-Za-z0-9_.!~*'() ])/sprintf("%%%02X", ord($1))/eg;
$mediaAlbum =~ s/([^-A-Za-z0-9_.!~*'() ])/sprintf("%%%02X", ord($1))/eg if $mediaAlbum;
$mediaAlbumArtist =~ s/([^-A-Za-z0-9_.!~*'() ])/sprintf("%%%02X", ord($1))/eg if $mediaAlbumArtist;

$scrobbleUrl = $lfmUrl."?method=track.scrobble&artist=".$mediaArtist."&track=".$mediaTitle."&timestamp=".$mediaTimestamp."&api_key=".$APIKEY."&api_sig=".$scrobbleSig."&sk=".$sessionKey;
$scrobbleUrl = $scrobbleUrl."&album=".$mediaAlbum if $mediaAlbum;
$scrobbleUrl = $scrobbleUrl."&albumArtist=".$mediaAlbumArtist if $mediaAlbumArtist;
$scrobbleOutput = $ua->post($scrobbleUrl);
exit();