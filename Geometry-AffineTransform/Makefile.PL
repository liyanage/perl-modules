use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
#
WriteMakefile(
	NAME          => 'Geometry::AffineTransform',
	VERSION_FROM  => 'lib/Geometry/AffineTransform.pm', # finds $VERSION
	ABSTRACT_FROM => 'lib/Geometry/AffineTransform.pm', # retrieve abstract from module
	PREREQ_PM     => {}, # e.g., Module::Name => 1.1
	AUTHOR        => 'futureLAB AG <info@futurelab.ch>',
);
