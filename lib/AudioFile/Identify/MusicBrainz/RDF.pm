=head1 NAME

AudioFile::Identify::MusicBrainz::RDF

=head2 DESCRIPTION

MusicBrainz does all its RPC stuff by posting and returning RDF. Which is an
odd approach, but it seems to work, so what the hell. The C client libraries take
the same general approach as I'm using here - they parse incoming RDF with proper
XML libraries, but the outgoing stuff is all boilerplate RDF taken from a file
'queries.h' in the distro.

Rather than generate outgoing RDF properly, we have generated this file from
queries.h, converting it into somewhat ugly perl, and sticking a wrapper
function at the bottom. queries.h contains the following text:

   MusicBrainz -- The Internet music metadatabase

   Copyright (C) 2000 Robert Kaye
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

This package implements one method.

=cut

package AudioFile::Identify::MusicBrainz::RDF;


use strict;
use warnings::register;

use Exporter;
use base qw(Exporter);

our @EXPORT_OK = qw(rdf rdf_raw);

my $headers = {};


  # The MusicBrainz artist id used to indicate that an album is a various artist
  # album.
  $headers->{MBI_VARIOUS_ARTIST_ID} = 
          "http://mm.musicbrainz.org/artist/89ad4ac3-39f7-470e-963a-56509c546377";
  # Use this query to reset the current context back to the top level of
  # the response.
  $headers->{MBS_Rewind} = 
          "[REWIND]";
  # Use this query to change the current context back one level.
  $headers->{MBS_Back} = 
          "[BACK]";
  # Use this Select Query to select an artist from an query that returns
  # a list of artists. Giving the argument 1 for the ordinal selects 
  # the first artist in the list, 2 the second and so on. Use 
  # MBE_ArtistXXXXXX queries to extract data after the select.
  # @param ordinal This select requires one ordinal argument
  $headers->{MBS_SelectArtist} = 
          "http://musicbrainz.org/mm/mm-2.1#artistList []";
  # Use this Select Query to select an album from an query that returns
  # a list of albums. Giving the argument 1 for the ordinal selects 
  # the first album in the list, 2 the second and so on. Use
  # MBE_AlbumXXXXXX queries to extract data after the select.
  # @param ordinal This select requires one ordinal argument
  $headers->{MBS_SelectAlbum} = 
          "http://musicbrainz.org/mm/mm-2.1#albumList []";
  # Use this Select Query to select a track from an query that returns
  # a list of tracks. Giving the argument 1 for the ordinal selects 
  # the first track in the list, 2 the second and so on. Use
  # MBE_TrackXXXXXX queries to extract data after the select.
  # @param ordinal This select requires one ordinal argument
  $headers->{MBS_SelectTrack} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList []";
  # Use this Select Query to select an the corresponding artist from a track 
  # context. MBE_ArtistXXXXXX queries to extract data after the select.
  # @param ordinal 
  $headers->{MBS_SelectTrackArtist} = 
          "http://purl.org/dc/elements/1.1/creator";
  # Use this Select Query to select an the corresponding artist from a track 
  # context. MBE_ArtistXXXXXX queries to extract data after the select.
  # @param ordinal 
  $headers->{MBS_SelectTrackAlbum} = 
          "http://musicbrainz.org/mm/mq-1.1#album";
  # Use this Select Query to select a trmid from the list. 
  # @param ordinal This select requires one ordinal argument
  $headers->{MBS_SelectTrmid} = 
          "http://musicbrainz.org/mm/mm-2.1#trmidList []";
  # Use this Select Query to select a CD Index id from the list. 
  # @param ordinal This select requires one ordinal argument
  $headers->{MBS_SelectCdindexid} = 
          "http://musicbrainz.org/mm/mm-2.1#cdindexidList []";
  # Use this Select Query to select a result from a lookupResultList.
  # This select will be used in conjunction with MBQ_FileLookup.
  # @param ordinal This select requires one ordinal argument
  $headers->{MBS_SelectLookupResult} = 
          "http://musicbrainz.org/mm/mq-1.1#lookupResultList []";
  # Use this Select Query to select the artist from a lookup result.
  # This select will be used in conjunction with MBQ_FileLookup.
  $headers->{MBS_SelectLookupResultArtist} = 
          "http://musicbrainz.org/mm/mq-1.1#artist";
  # Use this Select Query to select the album from a lookup result.
  # This select will be used in conjunction with MBQ_FileLookup.
  $headers->{MBS_SelectLookupResultAlbum} = 
          "http://musicbrainz.org/mm/mq-1.1#album";
  # Use this Select Query to select the track from a lookup result.
  # This select will be used in conjunction with MBQ_FileLookup.
  $headers->{MBS_SelectLookupResultTrack} = 
          "http://musicbrainz.org/mm/mq-1.1#track";

  $headers->{MBE_QuerySubject} = 
          "http://musicbrainz.org/mm/mq-1.1#Result";
          
  # Internal use only.
  $headers->{MBE_GetError} = 
          "http://musicbrainz.org/mm/mq-1.1#error";
  
  $headers->{MBE_GetNumArtists} = 
          "http://musicbrainz.org/mm/mm-2.1#artistList [COUNT]";
  # Return the number of albums returned in this query.
  $headers->{MBE_GetNumAlbums} = 
          "http://musicbrainz.org/mm/mm-2.1#albumList [COUNT]";
  # Return the number of tracks returned in this query.
  $headers->{MBE_GetNumTracks} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [COUNT]";
  # Return the number of trmids returned in this query.
  $headers->{MBE_GetNumTrmids} = 
          "http://musicbrainz.org/mm/mm-2.1#trmidList [COUNT]";
  # Return the number of lookup results returned in this query.
  $headers->{MBE_GetNumLookupResults} = 
          "http://musicbrainz.org/mm/mm-2.1#lookupResultList [COUNT]";
  
  # Return the name of the currently selected Album
  $headers->{MBE_ArtistGetArtistName} = 
          "http://purl.org/dc/elements/1.1/title";
  # Return the name of the currently selected Album
  $headers->{MBE_ArtistGetArtistSortName} = 
          "http://musicbrainz.org/mm/mm-2.1#sortName";
  # Return the ID of the currently selected Album. The value of this
  # query is indeed empty!
  $headers->{MBE_ArtistGetArtistId} = 
          ""; # yes, empty!
  
  # Return the name of the nth album. Requires an ordinal argument to select
  # an album from a list of albums in the current artist
  # @param ordinal This select requires one ordinal argument to select an album
  $headers->{MBE_ArtistGetAlbumName} = 
          "http://musicbrainz.org/mm/mm-2.1#albumList [] http://purl.org/dc/elements/1.1/title";
  # Return the ID of the nth album. Requires an ordinal argument to select
  # an album from a list of albums in the current artist
  # @param ordinal This select requires one ordinal argument to select an album
  $headers->{MBE_ArtistGetAlbumId} = 
          "http://musicbrainz.org/mm/mm-2.1#albumList []";
  
  # Return the name of the currently selected Album
  $headers->{MBE_AlbumGetAlbumName} = 
          "http://purl.org/dc/elements/1.1/title";
  # Return the ID of the currently selected Album. The value of this
  # query is indeed empty!
  $headers->{MBE_AlbumGetAlbumId} = 
          ""; # yes, empty!
  
  # Return the release status of the currently selected Album.
  $headers->{MBE_AlbumGetAlbumStatus} = 
          "http://musicbrainz.org/mm/mm-2.1#releaseStatus";
  # Return the release type of the currently selected Album.
  $headers->{MBE_AlbumGetAlbumType} = 
          "http://musicbrainz.org/mm/mm-2.1#releaseType";
  # Return the number of cdindexds returned in this query.
  $headers->{MBE_AlbumGetNumCdindexIds} = 
          "http://musicbrainz.org/mm/mm-2.1#cdindexidList [COUNT]";
  # Return the Artist ID of the currently selected Album. This may return 
  # the artist id for the Various Artists" artist, and then you should 
  # check the artist for each track of the album seperately with MBE_AlbumGetArtistName,
  # MBE_AlbumGetArtistSortName and MBE_AlbumGetArtistId.
  $headers->{MBE_AlbumGetAlbumArtistId} = 
          "http://purl.org/dc/elements/1.1/creator";
  # Return the mumber of tracks in the currently selected Album
  $headers->{MBE_AlbumGetNumTracks} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [COUNT]";
  # Return the Id of the nth track in the album. Requires a
  # track index ordinal. 1 for the first track, etc...
  # @param ordinal This select requires one ordinal argument to select a track
  $headers->{MBE_AlbumGetTrackId} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [] ";
  # Return the track list of an album. This extractor should only be used
  # to specify a list for GetOrdinalFromList().
  # @see mb_GetOrdinalFromList
  $headers->{MBE_AlbumGetTrackList} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList";
  # Return the track number of the nth track in the album. Requires a
  # track index ordinal. 1 for the first track, etc...
  # @param ordinal This select requires one ordinal argument to select a track
  $headers->{MBE_AlbumGetTrackNum} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [?] http://musicbrainz.org/mm/mm-2.1#trackNum";
  # Return the track name of the nth track in the album. Requires a
  # track index ordinal. 1 for the first track, etc...
  # @param ordinal This select requires one ordinal argument to select a track
  $headers->{MBE_AlbumGetTrackName} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [] http://purl.org/dc/elements/1.1/title";
  # Return the track duration of the nth track in the album. Requires a
  # track index ordinal. 1 for the first track, etc...
  # @param ordinal This select requires one ordinal argument to select a track
  $headers->{MBE_AlbumGetTrackDuration} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [] http://musicbrainz.org/mm/mm-2.1#duration";
  # Return the artist name of the nth track in the album. Requires a
  # track index ordinal. 1 for the first track, etc...
  # @param ordinal This select requires one ordinal argument to select a track
  $headers->{MBE_AlbumGetArtistName} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [] http://purl.org/dc/elements/1.1/creator http://purl.org/dc/elements/1.1/title";
  # Return the artist sortname of the nth track in the album. Requires a
  # track index ordinal. 1 for the first track, etc...
  # @param ordinal This select requires one ordinal argument to select a track
  $headers->{MBE_AlbumGetArtistSortName} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [] http://purl.org/dc/elements/1.1/creator http://musicbrainz.org/mm/mm-2.1#sortName";
  # Return the artist Id of the nth track in the album. Requires a
  # track index ordinal. 1 for the first track, etc...
  # @param ordinal This select requires one ordinal argument to select a track
  $headers->{MBE_AlbumGetArtistId} = 
          "http://musicbrainz.org/mm/mm-2.1#trackList [] http://purl.org/dc/elements/1.1/creator";
  
  # Return the name of the currently selected track
  $headers->{MBE_TrackGetTrackName} = 
          "http://purl.org/dc/elements/1.1/title";
  # Return the ID of the currently selected track. The value of this
  # query is indeed empty!
  $headers->{MBE_TrackGetTrackId} = 
          ""; # yes, empty!
  
  # Return the track number in the currently selected track
  $headers->{MBE_TrackGetTrackNum} = 
          "http://musicbrainz.org/mm/mm-2.1#trackNum";
  # Return the track duration in the currently selected track
  $headers->{MBE_TrackGetTrackDuration} = 
          "http://musicbrainz.org/mm/mm-2.1#duration";
  # Return the name of the artist for this track. 
  $headers->{MBE_TrackGetArtistName} = 
          "http://purl.org/dc/elements/1.1/creator http://purl.org/dc/elements/1.1/title";
  # Return the sortname of the artist for this track. 
  $headers->{MBE_TrackGetArtistSortName} = 
          "http://purl.org/dc/elements/1.1/creator http://musicbrainz.org/mm/mm-2.1#sortName";
  # Return the Id of the artist for this track. 
  $headers->{MBE_TrackGetArtistId} = 
          "http://purl.org/dc/elements/1.1/creator";
  
  # Return the name of the aritst
  $headers->{MBE_QuickGetArtistName} = 
          "http://musicbrainz.org/mm/mq-1.1#artistName";
  # Return the name of the aritst
  $headers->{MBE_QuickGetAlbumName} = 
          "http://musicbrainz.org/mm/mq-1.1#albumName";
  # Return the name of the aritst
  $headers->{MBE_QuickGetTrackName} = 
          "http://musicbrainz.org/mm/mq-1.1#trackName";
  # Return the name of the aritst
  $headers->{MBE_QuickGetTrackNum} = 
          "http://musicbrainz.org/mm/mm-2.1#trackNum";
  # Return the MB track id
  $headers->{MBE_QuickGetTrackId} = 
          "http://musicbrainz.org/mm/mm-2.1#trackid";
  # Return the track duration
  $headers->{MBE_QuickGetTrackDuration} = 
          "http://musicbrainz.org/mm/mm-2.1#duration";
  
  # Return the type of the lookup result
  $headers->{MBE_LookupGetType} = 
          "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";
  # Return the relevance of the lookup result
  $headers->{MBE_LookupGetRelevance} = 
          "http://musicbrainz.org/mm/mq-1.1#relevance";
  # Return the artist id of the lookup result
  $headers->{MBE_LookupGetArtistId} = 
          "http://musicbrainz.org/mm/mq-1.1#artist";
  # Return the artist id of the lookup result
  $headers->{MBE_LookupGetAlbumId} = 
          "http://musicbrainz.org/mm/mq-1.1#album";
  # Return the artist id of the lookup result
  $headers->{MBE_LookupGetAlbumArtistId} = 
          "http://musicbrainz.org/mm/mq-1.1#album" .
          "http://purl.org/dc/elements/1.1/creator";
  # Return the track id of the lookup result
  $headers->{MBE_LookupGetTrackId} = 
          "http://musicbrainz.org/mm/mq-1.1#track";
  # Return the artist id of the lookup result
  $headers->{MBE_LookupGetTrackArtistId} = 
          "http://musicbrainz.org/mm/mq-1.1#track " .
          "http://purl.org/dc/elements/1.1/creator";

  # return the CDIndex ID from the table of contents from the CD
  $headers->{MBE_TOCGetCDIndexId} = 
          "http://musicbrainz.org/mm/mm-2.1#cdindexid";
  # return the first track number from the table of contents from the CD
  $headers->{MBE_TOCGetFirstTrack} = 
          "http://musicbrainz.org/mm/mm-2.1#firstTrack";
  # return the last track number (total number of tracks on the CD) 
  # from the table of contents from the CD
  $headers->{MBE_TOCGetLastTrack} = 
          "http://musicbrainz.org/mm/mm-2.1#lastTrack";
  # return the sector offset from the nth track. One ordinal argument must
  # be given to specify the track. Track 1 is a special lead-out track,
  # and the actual track 1 on a CD can be retrieved as track 2 and so forth.
  $headers->{MBE_TOCGetTrackSectorOffset} = 
          "http://musicbrainz.org/mm/mm-2.1#toc [] http://musicbrainz.org/mm/mm-2.1#sectorOffset";
  # return the number of sectors for the nth track. One ordinal argument must
  # be given to specify the track. Track 1 is a special lead-out track,
  # and the actual track 1 on a CD can be retrieved as track 2 and so forth.
  $headers->{MBE_TOCGetTrackNumSectors} = 
          "http://musicbrainz.org/mm/mm-2.1#toc [] http://musicbrainz.org/mm/mm-2.1#numSectors";

  # return the Session Id from the Auth Query. This query will be used 
  # internally by the client library.
  $headers->{MBE_AuthGetSessionId} = 
          "http://musicbrainz.org/mm/mq-1.1#sessionId";
  # return the Auth Challenge data from the Auth Query This query will be used 
  # internally by the client library.
  $headers->{MBE_AuthGetChallenge} = 
          "http://musicbrainz.org/mm/mq-1.1#authChallenge";

  # Use this query to look up a CD from MusicBrainz. This query will
  # examine the CD-ROM in the CD-ROM drive specified by mb_SetDevice
  # and then send the CD-ROM data to the server. The server will then
  # find any matching CDs and return then as an albumList.
  $headers->{MBQ_GetCDInfo} = 
          "£CDINFO£";
  # Use this query to examine the table of contents of a CD. This query will
  # examine the CD-ROM in the CD-ROM drive specified by mb_SetDevice, and
  # then let the use extract data from the table of contents using the
  # MBQ_TOCXXXXX functions. No live net connection is required for this query.
  $headers->{MBQ_GetCDTOC} = 
          "£LOCALCDINFO£";
  # Internal use only. (For right now)
  $headers->{MBQ_AssociateCD} = 
          "£CDINFOASSOCIATECD£";
  
  # This query is use to start an authenticated session with the MB server.
  # The username is sent to the server, and the server responds with 
  # session id and a challenge sequence that the client needs to use to create 
  # a session key. The session key and session id need to be provided with
  # the MBQ_SubmitXXXX functions in order to give moderators/users credit
  # for their submissions. This query will be carried out by the client
  # libary automatically -- you should not need to use it.
  # £param username -- the name of the user who would like to submit data.
  $headers->{MBQ_Authenticate} = 
      "<mq:AuthenticateQuery>\n" .
      "   <mq:username>£1£</mq:username>\n" .
      "</mq:AuthenticateQuery>\n";
  
  # Use this query to return an albumList for the given CD Index Id
  # £param cdindexid The cdindex id to look up at the remote server.
  $headers->{MBQ_GetCDInfoFromCDIndexId} = 
      "<mq:GetCDInfo>\n" .
      "   <mq:depth>£DEPTH£</mq:depth>\n" .
      "   <mm:cdindexid>£1£</mm:cdindexid>\n" .
      "</mq:GetCDInfo>\n";
  
  # Use this query to return the metadata information (artistname,
  # albumname, trackname, tracknumber) for a given trm id. Optionally, 
  # you can also specifiy the basic artist metadata, so that if the server
  # cannot match on the TRM id, it will attempt to match based on the basic
  # metadata.
  # In case of a TRM collision (where one TRM may point to more than one track)
  # this function will return more than on track. The user (or tagging app)
  # must decide which track information is correct.
  # £param trmid The TRM id for the track to be looked up
  # £param artistName The name of the artist
  # £param albumName The name of the album
  # £param trackName The name of the track
  # £param trackNum The number of the track
  $headers->{MBQ_TrackInfoFromTRMId} = 
      "<mq:TrackInfoFromTRMId>\n" .
      "   <mm:trmid>£1£</mm:trmid>\n" .
      "   <mq:artistName>£2£</mq:artistName>\n" .
      "   <mq:albumName>£3£</mq:albumName>\n" .
      "   <mq:trackName>£4£</mq:trackName>\n" .
      "   <mm:trackNum>£5£</mm:trackNum>\n" .
      "   <mm:duration>£6£</mm:duration>\n" .
      "</mq:TrackInfoFromTRMId>\n";
  
  # Use this query to return the basic metadata information (artistname,
  # albumname, trackname, tracknumber) for a given track mb id
  # £param trackid The MB track id for the track to be looked up
  $headers->{MBQ_QuickTrackInfoFromTrackId} = 
      "<mq:QuickTrackInfoFromTrackId>\n" .
      "   <mm:trackid>£1£</mm:trackid>\n" .
      "   <mm:albumid>£2£</mm:albumid>\n" .
      "</mq:QuickTrackInfoFromTrackId>\n";
  
  # Use this query to find artists by name. This function returns an artistList 
  # for the given artist name.
  # £param artistName The name of the artist to find.
  $headers->{MBQ_FindArtistByName} = 
      "<mq:FindArtist>\n" .
      "   <mq:depth>£DEPTH£</mq:depth>\n" .
      "   <mq:artistName>£1£</mq:artistName>\n" .
      "   <mq:maxItems>£MAX_ITEMS£</mq:maxItems>\n" .
      "</mq:FindArtist>\n";
  
  # Use this query to find albums by name. This function returns an albumList 
  # for the given album name. 
  # £param albumName The name of the album to find.
  $headers->{MBQ_FindAlbumByName} = 
      "<mq:FindAlbum>\n" .
      "   <mq:depth>£DEPTH£</mq:depth>\n" .
      "   <mq:maxItems>£MAX_ITEMS£</mq:maxItems>\n" .
      "   <mq:albumName>£1£</mq:albumName>\n" .
      "</mq:FindAlbum>\n";
  
  # Use this query to find tracks by name. This function returns a trackList 
  # for the given track name. 
  # £param trackName The name of the track to find.
  $headers->{MBQ_FindTrackByName} = 
      "<mq:FindTrack>\n" .
      "   <mq:depth>£DEPTH£</mq:depth>\n" .
      "   <mq:maxItems>£MAX_ITEMS£</mq:maxItems>\n" .
      "   <mq:trackName>£1£</mq:trackName>\n" .
      "</mq:FindTrack>\n";
  
  # Use this function to find TRM Ids that match a given artistName
  # and trackName, This query returns a trmidList.
  # £param artistName The name of the artist to find.
  # £param trackName The name of the track to find.
  $headers->{MBQ_FindDistinctTRMId} = 
      "<mq:FindDistinctTRMID>\n" .
      "   <mq:depth>£DEPTH£</mq:depth>\n" .
      "   <mq:artistName>£1£</mq:artistName>\n" .
      "   <mq:trackName>£2£</mq:trackName>\n" .
      "</mq:FindDistinctTRMID>\n";
  
  # Retrieve an artistList from a given Artist id 
  $headers->{MBQ_GetArtistById} = 
      "http://£URL£/mm-2.1/artist/£1£/£DEPTH£";
  
  # Retrieve an albumList from a given Album id 
  $headers->{MBQ_GetAlbumById} = 
      "http://£URL£/mm-2.1/album/£1£/£DEPTH£";
  
  # Retrieve an trackList from a given Track id 
  $headers->{MBQ_GetTrackById} = 
      "http://£URL£/mm-2.1/track/£1£/£DEPTH£";
  
  # Retrieve an trackList from a given TRM Id 
  $headers->{MBQ_GetTrackByTRMId} = 
      "http://£URL£/mm-2.1/trmid/£1£/£DEPTH£";
  
  # Internal use only.
  $headers->{MBQ_SubmitTrack} = 
      "<mq:SubmitTrack>\n" .
      "   <mq:artistName>£1£</mq:artistName>\n" .
      "   <mq:albumName>£2£</mq:albumName>\n" .
      "   <mq:trackName>£3£</mq:trackName>\n" .
      "   <mm:trmid>£4£</mm:trmid>\n" .
      "   <mm:trackNum>£5£</mm:trackNum>\n" .
      "   <mm:duration>£6£</mm:duration>\n" .
      "   <mm:issued>£7£</mm:issued>\n" .
      "   <mm:genre>£8£</mm:genre>\n" .
      "   <dc:description>£9£</dc:description>\n" .
      "   <mm:link>£10£</mm:link>\n" .
      "   <mq:sessionId>£SESSID£</mq:sessionId>\n" .
      "   <mq:sessionKey>£SESSKEY£</mq:sessionKey>\n" .
      "</mq:SubmitTrack>\n";
  
  # Submit a single TrackId, TRM Id pair to MusicBrainz. This query can
  # handle only one pair at a time, which is inefficient. The user may wish
  # to create the query RDF text by hand and provide more than one pair
  # in the rdf:Bag, since the server can handle up to 1000 pairs in one
  # query.
  # £param TrackGID  The Global ID field of the track
  # £param trmid     The TRM Id of the track.
  $headers->{MBQ_SubmitTrackTRMId} = 
      "<mq:SubmitTRMList>\n" .
      " <mm:trmidList>\n" .
      "  <rdf:Bag>\n" .
      "   <rdf:li>\n" .
      "    <mq:trmTrackPair>\n" .
      "     <mm:trackid>£1£</mm:trackid>\n" .
      "     <mm:trmid>£2£</mm:trmid>\n" .
      "    </mq:trmTrackPair>\n" .
      "   </rdf:li>\n" .
      "  </rdf:Bag>\n" .
      " </mm:trmidList>\n" .
      " <mq:sessionId>£SESSID£</mq:sessionId>\n" .
      " <mq:sessionKey>£SESSKEY£</mq:sessionKey>\n" .
      " <mq:clientVersion>£CLIENTVER£</mq:clientVersion>\n" .
      "</mq:SubmitTRMList>\n";
  
  # Lookup metadata for one file. This function can be used by tagging applications
  # to attempt to match a given track with a track in the database. The server will
  # attempt to match an artist, album and track during three phases. If 
  # at any one lookup phase the server finds ONE item only, it will move on to
  # to the next phase. If no items are returned, an error message is returned. If 
  # more then one item is returned, the end-user will have to choose one from
  # the returned list and then make another call to the server. To express the
  # choice made by a user, the client should leave the artistName/albumName empty and 
  # provide the artistId and/or albumId empty on the subsequent call. Once an artistId
  # or albumId is provided the server will pick up from the given Ids and attempt to
  # resolve the next phase.
  # £param ArtistName The name of the artist, gathered from ID3 tags or user input
  # £param AlbumName  The name of the album, also from ID3 or user input
  # £param TrackName  The name of the track
  # £param TrackNum   The track number of the track being matched
  # £param Duration   The duration of the track being matched
  # £param FileName   The name of the file that is being matched. This will only be used
  #                   if the ArtistName, AlbumName or TrackName fields are blank. 
  # £param ArtistId   The AritstId resolved from an earlier call. 
  # £param AlbumId    The AlbumId resolved from an earlier call. 
  # £param MaxItems   The maximum number of items to return if the server cannot
  #                   determine an exact match.
  $headers->{MBQ_FileInfoLookup} = 
      "<mq:FileInfoLookup>\n" .
      "   <mm:trmid>£1£</mm:trmid>\n" .
      "   <mq:artistName>£2£</mq:artistName>\n" .
      "   <mq:albumName>£3£</mq:albumName>\n" .
      "   <mq:trackName>£4£</mq:trackName>\n" .
      "   <mm:trackNum>£5£</mm:trackNum>\n" .
      "   <mm:duration>£6£</mm:duration>\n" .
      "   <mq:fileName>£7£</mq:fileName>\n" .
      "   <mm:artistid>£8£</mm:artistid>\n" .
      "   <mm:albumid>£9£</mm:albumid>\n" .
      "   <mm:trackid>£10£</mm:trackid>\n" .
      "   <mq:maxItems>£MAX_ITEMS£</mq:maxItems>\n" .
      "</mq:FileInfoLookup>\n";

  my $rdf_h = <<RDF_H;
<rdf:RDF xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:dc  = "http://purl.org/dc/elements/1.1/"
         xmlns:mq  = "http://musicbrainz.org/mm/mq-1.1#"
         xmlns:mm  = "http://musicbrainz.org/mm/mm-2.1#">
RDF_H

  my $rdf_f = <<RDF_F;
</rdf:RDF>
RDF_F

no warnings 'uninitialized';

=head2 rdf($name, $values)

Get the RDF boilerplate named '$name' from the file, and substitute in the
vaules from $vaules, a hashref. For example:

  use AudioFile::Identify::MusicBrainz::RDF qw(rdf); # export the rdf function
  my $query = rdf("MBQ_GetTrackById", { 1 => "http://musicbrainz.url", DEPTH => '4' } );

The boilerplate stuff annoyingly uses numbered values. Look at the source of this
file if you want to use any of the queries directly.

=cut

sub rdf {
  my $name = shift;
  my $substitute = shift;
  my $val = $headers->{$name};
  $substitute->{URL} ||= 'http://mm.musicbrainz.org';
  for (keys(%$substitute)) {
    $val =~ s/£$_£/$substitute->{$_}/g;
  }
#  $val =~ s/£[\w_]+£//g;
  $val = $rdf_h.$val.$rdf_f unless $val =~ /^http/;
  return $val;
}

1;

__END__

=head1 SEE ALSO

See also queries.h in the MusicBrainz client library.
http://musicbrainz.org/products/client/download.html
