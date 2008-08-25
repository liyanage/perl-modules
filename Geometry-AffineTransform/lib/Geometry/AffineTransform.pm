package Geometry::AffineTransform;

use strict;
use warnings;

use Carp;
use Hash::Util;
use Data::Dumper;
use Math::Trig;

our $VERSION = '1.0';


=head1 NAME

Geometry::AffineTransform - Represents a 2D affine transform to map 2D coordinates to other 2D coordinates.

=head1 SYNOPSIS

	use Geometry::AffineTransform;
	
	my $t = Geometry::AffineTransform->new();
	$t->translate($delta_x, $delta_y);
	$t->shear(...);
	$t->rotate(...);
	$t->concatenate($t2);
	my ($x_t, $y_t) = $t->transform($x, $y);
	
=head1 DESCRIPTION

Geometry::AffineTransform Represents a 2D affine transform to map 2D coordinates
to other 2D coordinates.

=cut


=head1 METHODS

=head2 new

Constructor, creates a new instance with the identity transform.

=cut

sub new {
	my $self = shift @_;
	my (%args) = @_;
	
	my $class = ref($self) || $self;
	$self = bless {%args}, $class;
	$self->{$_} ||= undef foreach qw(m11 m12 m21 m22 tx ty);
	$self->init();
	Hash::Util::lock_keys(%$self);
	
	return $self;
}


sub rotate {
	my $self = shift;
	my ($degrees) = @_;
	my $rad = deg2rad($degrees);
	return $self->concatenate_matrix_2x3(cos($rad), sin($rad), -sin($rad), cos($rad), 0, 0);
}



sub init {
	my $self = shift;
	($self->{m11}, $self->{m12},
	$self->{m21}, $self->{m22},
	$self->{tx}, $self->{ty}) = (1, 0, 0, 1, 0, 0);
}



sub transform {
	my $self = shift;
	my ($x, $y) = @_;
	
	my $x2 = $self->{m11} * $x + $self->{m21} * $y + $self->{tx};
	my $y2 = $self->{m12} * $x + $self->{m22} * $y + $self->{ty};

	return $x2, $y2;
}



sub concatenate_matrix_2x3 {
	my $self = shift;
	my ($m11, $m12, $m21, $m22, $tx, $ty) = @_;
	
	my $a = [$self->matrix_2x3()];
	my $b = [$m11, $m12, $m21, $m22, $tx, $ty];

	$self->set_matrix_2x3($self->matrix_multiply($a, $b));

	return $self;
}



sub concatenate {
	my $self = shift;
	my ($t) = @_;
	croak "Expecting argument of type Geometry::AffineTransform" unless eval {eval {$t->isa('Geometry::AffineTransform')}};
	return $self->concatenate_matrix_2x3($t->matrix_2x3());
}





sub matrix_2x3 {
	my $self = shift;
	return $self->{m11}, $self->{m12}, $self->{m21}, $self->{m22}, $self->{tx}, $self->{ty};
}


sub set_matrix_2x3 {
	my $self = shift;
	my ($m11, $m12, $m21, $m22, $tx, $ty) = @_;
	($self->{m11}, $self->{m12}, $self->{m21}, $self->{m22}, $self->{tx}, $self->{ty})
		= ($m11, $m12, $m21, $m22, $tx, $ty);
	return $self;
}


sub matrix {
	my $self = shift;
	return $self->{m11}, $self->{m12}, 0, $self->{m21}, $self->{m22}, 0, $self->{tx}, $self->{ty}, 1;
}




# a simplified multiply that leaves away the third column
sub matrix_multiply {
	my $self = shift;
	my ($a, $b) = @_;
	
	my ($a11, $a12, $a21, $a22, $a31, $a32) = @$a;
	my ($b11, $b12, $b21, $b22, $b31, $b32) = @$b;
	
# 	a11 a12 0
# 	a21 a22 0
# 	a31 a32 1
# 	
# 	b11 b12 0
# 	b21 b22 0
# 	b31 b32 1

	return
		($a11 * $b11 + $a12 * $b21),        ($a11 * $b12 + $a12 * $b22),
		($a21 * $b11 + $a22 * $b21),        ($a21 * $b12 + $a22 * $b22),
		($a31 * $b11 + $a32 * $b21 + $b31), ($a31 * $b12 + $a32 * $b22 + $b32),
	;

}








1;

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Marc Liyanage.

=cut
