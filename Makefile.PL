use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'POE::Component::Algorithm::Evolutionary',
    AUTHOR              => 'JJ Merelo <jj@merelo.net>',
    VERSION_FROM        => 'lib/POE/Component/Algorithm/Evolutionary.pm',
    ABSTRACT_FROM       => 'lib/POE/Component/Algorithm/Evolutionary.pm',
    PL_FILES            => {},
    PREREQ_PM => {
		  'Test::More' => 0,
		  'version'    => 0,
		  'Algorithm::Evolutionary' => 0.61
		 },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'POE-Component-Algorithm-Evolutionary-*' },
);
