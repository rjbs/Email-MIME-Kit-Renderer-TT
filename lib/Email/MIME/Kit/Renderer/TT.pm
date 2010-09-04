package Email::MIME::Kit::Renderer::TT;
use Moose;
with 'Email::MIME::Kit::Role::Renderer';
# ABSTRACT: render parts of your mail with Template-Toolkit

use Template 2.1;

=head1 DESCRIPTION

This is a renderer plugin for L<Email::MIME::Kit>, and renders message parts
using L<Template Toolkit 2|Template>.  When specifying a renderer in
F<manifest.json>, you might write something like this:

  { ..., "renderer": "TT" }

Or, to supply options:

  {
    ...,
    "renderer": [
      "TT",
      { ...params go here... }
    ]
  }

There are only three parameters that can be supplied right now:

C<strict> sets the C<STRICT> Template parameter.  It defaults to 1.

C<eval_perl> sets the C<EVAL_PERL> Template parameter.  It defaults to 0.

C<template_parameters> can be a hashref of any parameters to be passed to the
Template constructor.  Setting C<STRICT> or C<EVAL_PERL> here overrides the
C<strict> and C<eval_perl> options.

=cut

# XXX: _include_path or something
# XXX: we can maybe default to the kit dir if the KitReader is Dir

sub render {
  my ($self, $input_ref, $stash) = @_;
  $stash ||= {};

  my $output;
  $self->tt->process($input_ref, $stash, \$output)
    or die $self->tt->error;

  return \$output;
}

has eval_perl => (
  is   => 'ro',
  isa  => 'Bool',
  default => 0,
);

has strict => (
  is   => 'ro',
  isa  => 'Bool',
  default => 1,
);

has template_parameters => (
  is  => 'ro',
  isa => 'HashRef',
  default => sub { {} },
);

has tt => (
  is   => 'ro',
  isa  => 'Template',
  lazy => 1,
  init_arg => undef,
  default  => sub {
    my ($self) = @_;
    Template->new({
      ABSOLUTE  => 0,
      RELATIVE  => 0,
      STRICT    => $self->strict,
      EVAL_PERL => $self->eval_perl,
      %{ $self->template_parameters },
    });
  },
);

1;
