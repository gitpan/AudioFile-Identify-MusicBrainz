    use ExtUtils::MakeMaker;
    WriteMakefile
      ('DISTNAME' => 'AudioFile-Identify-MusicBrainz',
       'VERSION' => '0.2',
       'PL_FILES' => {},
       'PREREQ_PM' => {
			'LWP' => '0',
			'Test::More' => '0',
			'XML::DOM' => '0',

		      },
      );
