use ExtUtils::MakeMaker;
WriteMakefile(
	NAME          => 'Geometry::AffineTransform',
	VERSION_FROM  => 'lib/Geometry/AffineTransform.pm', # finds $VERSION
	ABSTRACT_FROM => 'lib/Geometry/AffineTransform.pm', # retrieve abstract from module
	PREREQ_PM     => {'Test::Class' => 0.28},
	AUTHOR        => 'Marc Liyanage <reg.cpan@entropy.ch>',
);
