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
	$t->rotate($degrees);
	my $t2 = Geometry::AffineTransform->new()->scale(3.1, 2.3);
	$t->concatenate($t2);
	my ($x1, $y1, $x2, $y2, ...) = $t->transform($x1, $y1, $x2, $y2, ...);
	
=head1 DESCRIPTION

Geometry::AffineTransform Represents a 2D affine transform to map 2D coordinates
to other 2D coordinates.

=cut


=head1 METHODS

=head2 new

Constructor, creates a new instance with its state representing an identity transform.

=cut

sub new {
	my $self = shift @_;
	my (%args) = @_;
	
	my $class = ref($self) || $self;
	$self = bless {m11 => 1, m12 => 0, m21 => 0, m22 => 1, tx => 0, ty => 0, %args}, $class;
	Hash::Util::lock_keys(%$self);
	
	return $self;
}



sub transform {
	my $self = shift;
	my (@pairs) = @_;
	
	my @result;
	while (my ($x, $y) = splice(@pairs, 0, 2)) {
		my $x2 = $self->{m11} * $x + $self->{m21} * $y + $self->{tx};
		my $y2 = $self->{m12} * $x + $self->{m22} * $y + $self->{ty};
		push @result, $x2, $y2;
	}
	
	return @result;
}



sub concatenate_matrix_2x3 {
	my $self = shift;
	my ($m11, $m12, $m21, $m22, $tx, $ty) = @_;
	my $a = [$self->matrix_2x3()];
	my $b = [$m11, $m12, $m21, $m22, $tx, $ty];
	return $self->set_matrix_2x3($self->matrix_multiply($a, $b));
}



sub concatenate {
	my $self = shift;
	my ($t) = @_;
	croak "Expecting argument of type Geometry::AffineTransform" unless (ref $t);
	return $self->concatenate_matrix_2x3($t->matrix_2x3());
}



sub scale {
	my $self = shift;
	my ($sx, $sy) = @_;
	return $self->concatenate_matrix_2x3($sx, 0, 0, $sy, 0, 0);
}



sub translate {
	my $self = shift;
	my ($tx, $ty) = @_;
	return $self->concatenate_matrix_2x3(1, 0, 0, 1, $tx, $ty);
}


sub rotate {
	my $self = shift;
	my ($degrees) = @_;
	my $rad = deg2rad($degrees);
	return $self->concatenate_matrix_2x3(cos($rad), sin($rad), -sin($rad), cos($rad), 0, 0);
}




sub matrix_2x3 {
	my $self = shift;
	return $self->{m11}, $self->{m12}, $self->{m21}, $self->{m22}, $self->{tx}, $self->{ty};
}


sub set_matrix_2x3 {
	my $self = shift;
	($self->{m11}, $self->{m12},
	 $self->{m21}, $self->{m22},
	 $self->{tx}, $self->{ty}) = @_;
	return $self;
}


sub matrix {
	my $self = shift;
	return $self->{m11}, $self->{m12}, 0, $self->{m21}, $self->{m22}, 0, $self->{tx}, $self->{ty}, 1;
}




# a simplified multiply that assumes the fixed 0 0 1 third column
sub matrix_multiply {
	my $self = shift;
	my ($a, $b) = @_;
	
# 	a11 a12 0
# 	a21 a22 0
# 	a31 a32 1
# 	
# 	b11 b12 0
# 	b21 b22 0
# 	b31 b32 1

	my ($a11, $a12, $a21, $a22, $a31, $a32) = @$a;
	my ($b11, $b12, $b21, $b22, $b31, $b32) = @$b;
	
	return
		($a11 * $b11 + $a12 * $b21),        ($a11 * $b12 + $a12 * $b22),
		($a21 * $b11 + $a22 * $b21),        ($a21 * $b12 + $a22 * $b22),
		($a31 * $b11 + $a32 * $b21 + $b31), ($a31 * $b12 + $a32 * $b22 + $b32),
	;

}








1;

=head1 SEE ALSO

=over

=item Apple Quartz 2D Programming Guide - The Math Behind the Matrices

http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_affine/chapter_6_section_7.html

=item Sun Java java.awt.geom.AffineTransform

http://java.sun.com/j2se/1.4.2/docs/api/java/awt/geom/AffineTransform.html

=item Wikipedia - Matrix Multiplication

http://en.wikipedia.org/wiki/Matrix_(mathematics)#Matrix_multiplication

=back





=head1 COPYRIGHT AND LICENSE

Copyright 2008 Marc Liyanage.

=cut
