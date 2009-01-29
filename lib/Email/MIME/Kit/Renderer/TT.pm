package Email::MIME::Kit::Renderer::TT;
use Moose;
with 'Email::MIME::Kit::Role::Renderer';
# ABSTRACT: render parts of your mail with Template-Toolkit

use Template;

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
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

has tt => (
  is   => 'ro',
  isa  => 'Template',
  lazy => 1,
  init_arg => undef,
  default  => sub {
    Template->new({
      ABSOLUTE  => 0,
      RELATIVE  => 0,
      EVAL_PERL => $_[0]->eval_perl,
    });
  },
);

sub tt {
  my $self = shift;
  return $self->_tt || $self->_tt(Template->new({
    ABSOLUTE => 1,
    RELATIVE => 1,
    INCLUDE_PATH => $self->_include_path_ref,
  }));
}

1;
