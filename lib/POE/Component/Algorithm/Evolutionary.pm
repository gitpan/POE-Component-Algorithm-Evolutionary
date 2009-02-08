package POE::Component::Algorithm::Evolutionary;

use lib qw( ../../../../../Algorithm-Evolutionary/lib ../Algorithm-Evolutionary/lib ); #For development and perl syntax mode

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;

use POE;
use Algorithm::Evolutionary;

# Module implementation here
sub new {
  my $class = shift;
  my %args = @_;

  my $fitness = delete $args{Fitness} || croak "Fitness required";
  my $creator = delete $args{Creator} || croak "Creator required";
  my $single_step = delete $args{Single_Step} || croak "Single_Step required";
  my $terminator = delete $args{Terminator} || croak "Terminator required";
  my $alias = delete $args{Alias} || croak "Alias required";

  my $self = { alias => $alias };
  bless $self, $class;

  my $session = POE::Session->create(inline_states => { _start => \&start,
						      generation => \&generation,
						      finish => \&finishing},
				     args  => [$alias, $creator, $single_step, 
					       $terminator, $fitness, $self]
				    );
  $self->{'session'} = $session;
  return $self;
}

sub start {
  my ($kernel, $heap, $alias, $creator, 
      $single_step, $terminator, $fitness,$self )= 
	@_[KERNEL, HEAP, ARG0, ARG1, ARG2, ARG3, ARG4, ARG5];
  $kernel->alias_set($alias);
  $heap->{'single_step'} = $single_step;
  $heap->{'terminator' } = $terminator;
  $heap->{'creator' } = $creator;
  $heap->{'fitness' } = $fitness;
  $heap->{'self'} = $self;
  my @pop;
  $creator->apply( \@pop );
  map( $_->evaluate($fitness), @pop );
  $heap->{'population'} = \@pop;
  $kernel->yield('generation');
}

sub generation {
  my ($kernel, $heap ) = @_[KERNEL, HEAP];
  $heap->{'single_step'}->apply( $heap->{'population'} );
  if ( ! $heap->{'terminator'}->apply( $heap->{'population'} ) ) {
    $kernel->yield( 'finish' );
  } else {
    $kernel->yield( 'generation' );
  }

}

sub finishing {
  my ($kernel, $heap ) = @_[KERNEL, HEAP];
  print "Best is:\n\t ",$heap->{'population'}->[0]->asString()," Fitness: ",
    $heap->{'population'}->[0]->Fitness(),"\n";
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Poe::Component::Algorithm::Evolutionary - Run evolutionary algorithms in a preemptive multitasking way.


=head1 VERSION

This document describes Poe::Component::Algorithm::Evolutionary version 0.0.3


=head1 SYNOPSIS

use Poe::Component::Algorithm::Evolutionary;

use Algorithm::Evolutionary qw( Individual::BitString Op::Creator 
				Op::CanonicalGA Op::Bitflip 
				Op::Crossover Op::GenerationalTerm
				Fitness::Royal_Road);

my $bits = shift || 64;
my $block_size = shift || 4;
my $pop_size = shift || 256; #Population size
my $numGens = shift || 200; #Max number of generations
my $selection_rate = shift || 0.2;

#Initial population
my $creator = new Algorithm::Evolutionary::Op::Creator( $pop_size, 'BitString', { length => $bits });

# Variation operators
my $m = Algorithm::Evolutionary::Op::Bitflip->new( 1 );
my $c = Algorithm::Evolutionary::Op::Crossover->new(2, 4);

# Fitness function: create it and evaluate
my $rr = new  Algorithm::Evolutionary::Fitness::Royal_Road( $block_size );

my $generation = Algorithm::Evolutionary::Op::CanonicalGA->new( $rr , $selection_rate , [$m, $c] ) ;
my $gterm = new Algorithm::Evolutionary::Op::GenerationalTerm 10;

POE::Component::Algorithm::Evolutionary->new( Fitness => $rr,
					      Creator => $creator,
					      Single_Step => $generation,
					      Terminator => $gterm,
					      Alias => 'Canonical' );


$poe_kernel->run();


=head1 DESCRIPTION

Not a lot here: it creates a component that uses POE to run an
evolutionary algorithm 

=head1 INTERFACE 

=head2 new

POE::Component::Algorithm::Evolutionary->new( Fitness => $rr,
					      Creator => $creator,
					      Single_Step => $generation,
					      Terminator => $gterm,
					      Alias => 'Canonical' );

It's called with all components needed to run an evolutionary
algorithm; to keep everything flexible they are created in
advance. See the C<scripts/> directory for an example.

=head2 start

Called internally for initializing population

=head2 generation

This is run once for each generation, until end condition is met

=head2 finishing

Called when everything is over. Prints winner

=head1 CONFIGURATION AND ENVIRONMENT

Poe::Component::Algorithm::Evolutionary requires no configuration files or environment variables.


=head1 DEPENDENCIES

Main dependence is L<Algorithm::Evolutionary>; however, it's not
included by default, since you must pick and choose the modules you
are going to actually use.


=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-poe-component-algorithm-evolutionary@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

JJ Merelo  C<< <jj@merelo.net> >>

=begin html 

Boilerplate taken from <a
href='http://perl.com/pub/a/2004/07/22/poe.html?page=2'>article in
perl.com</a> 

=end html


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, JJ Merelo C<< <jj@merelo.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
