=head1 LICENSE

See the NOTICE file distributed with this work for additional information
regarding copyright ownership.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

=head1 NAME

Bio::EnsEMBL::Compara::PipeConfig::SyntenyStats_conf

=head1 SYNOPSIS

    init_pipeline.pl Bio::EnsEMBL::Compara::PipeConfig::SyntenyStats_conf -host mysql-ens-compara-prod-X -port XXXX \
        -division $COMPARA_DIV

=head1 DESCRIPTION  

Calculate synteny coverage statistics across a whole division (or any Registry alias).

=cut

package Bio::EnsEMBL::Compara::PipeConfig::SyntenyStats_conf;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Compara::PipeConfig::ComparaGeneric_conf');

sub default_options {
    my ($self) = @_;
    return {
        %{$self->SUPER::default_options},   # inherit the generic ones

        'compara_db'    => 'compara_curr',
    };
}

sub no_compara_schema {}    # Tell the base class not to create the Compara tables in the database

sub pipeline_wide_parameters {
  my ($self) = @_;
  return {
    %{ $self->SUPER::pipeline_wide_parameters() },
    'compara_db' => $self->o('compara_db'),
  };
}

sub pipeline_analyses {
  my ($self) = @_;
  
  return [
    {
      -logic_name      => 'FetchMLSS',
      -module          => 'Bio::EnsEMBL::Compara::RunnableDB::MLSSIDFactory',
      -parameters      => {
          'methods' => {
              'SYNTENY' => 1,
          },
      },
      -max_retry_count => 0,
      -input_ids       => [ {} ],
      -flow_into       => ['SyntenyStats'],
    },
    
    {
      -logic_name      => 'SyntenyStats',
      -module          => 'Bio::EnsEMBL::Compara::RunnableDB::Synteny::SyntenyStats',
      -max_retry_count => 0,
      -flow_into       => {-1 => 'synteny_stats_himem'},
      -rc_name         => '1Gb_job',
    },

    {
      -logic_name      => 'synteny_stats_himem',
      -module          => 'Bio::EnsEMBL::Compara::RunnableDB::Synteny::SyntenyStats',
      -max_retry_count => 0,
      -rc_name         => '4Gb_job',
    },
    
  ];
}

1;
