#!/usr/bin/env perl
# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Release Coordinator, please update this file before starting every release
# and check the changes back into GIT for everyone's benefit.

# Things that normally need updating are:
#
# 1. Reused databases
# 2. MySQL servers for core and taxonomy databases
#     2.1. Swap between sta-X and sta-X-b every release
#     2.2. Core databases may not always be available in vertannot

use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Compara::Utils::Registry;

my $curr_release = $ENV{'CURR_ENSEMBL_RELEASE'};
my $prev_release = $curr_release - 1;
my $curr_eg_release = $curr_release - 53;
my $prev_eg_release = $curr_eg_release - 1;

# ---------------------- DATABASE HOSTS -----------------------------------------

my ($curr_nv_host, $curr_nv_port) = $curr_release % 2 == 0
    ? ('mysql-ens-sta-3', 4160)
    : ('mysql-ens-sta-3-b', 4686);

my ($prev_nv_host, $prev_nv_port) = $prev_release % 2 == 0
    ? ('mysql-ens-sta-3', 4160)
    : ('mysql-ens-sta-3-b', 4686);

# ---------------------- CURRENT CORE DATABASES----------------------------------

# Ensure we are using the correct cores for species that overlap with vertebrates
my @overlap_species = qw(caenorhabditis_elegans drosophila_melanogaster saccharomyces_cerevisiae);
Bio::EnsEMBL::Compara::Utils::Registry::suppress_overlap_species_warnings(\@overlap_species);

# Use our mirror (which has all the databases)
Bio::EnsEMBL::Registry->load_registry_from_url("mysql://ensro\@mysql-ens-vertannot-staging:4573/$curr_release");

Bio::EnsEMBL::Compara::Utils::Registry::remove_species(\@overlap_species);
my $overlap_cores = {
    'caenorhabditis_elegans'  => [ 'mysql-ens-vertannot-staging', "caenorhabditis_elegans_core_${curr_eg_release}_${curr_release}_282" ],
    'drosophila_melanogaster' => [ 'mysql-ens-vertannot-staging', "drosophila_melanogaster_core_${curr_eg_release}_${curr_release}_11" ],
};
Bio::EnsEMBL::Compara::Utils::Registry::add_core_dbas( $overlap_cores );

# ---------------------- CURRENT CORE DATABASES : ALTERNATE HOSTS ----------------

# Official staging servers
#Bio::EnsEMBL::Registry->load_registry_from_url("mysql://ensro\@$curr_nv_host:$curr_nv_port/$curr_release");
#Bio::EnsEMBL::Compara::Utils::Registry::remove_multi();

# ---------------------- PREVIOUS CORE DATABASES---------------------------------

# previous release core databases will be required by PrepareMasterDatabaseForRelease and LoadMembers only
*Bio::EnsEMBL::Compara::Utils::Registry::load_previous_core_databases = sub {
    Bio::EnsEMBL::Registry->load_registry_from_db(
        -host   => $prev_nv_host,
        -port   => $prev_nv_port,
        -user   => 'ensro',
        -pass   => '',
        -db_version     => $prev_release,
        -species_suffix => Bio::EnsEMBL::Compara::Utils::Registry::PREVIOUS_DATABASE_SUFFIX,
    );
};
#------------------------COMPARA DATABASE LOCATIONS----------------------------------


my $compara_dbs = {
    # general compara dbs
    'compara_master' => [ 'mysql-ens-compara-prod-6', 'ensembl_compara_master_metazoa' ],
    'compara_curr'   => [ 'mysql-ens-compara-prod-6', "ensembl_compara_metazoa_${curr_eg_release}_${curr_release}" ],
    'compara_prev'   => [ 'mysql-ens-compara-prod-6', "ensembl_compara_metazoa_${prev_eg_release}_${prev_release}" ],

    # homology dbs
    'compara_members'    => [ 'mysql-ens-compara-prod-6', 'sbotond_metazoa_load_members_115' ],
    'compara_ptrees'     => [ 'mysql-ens-compara-prod-6', 'sbhurji_default_metazoa_protein_trees_114' ],
    'protostomes_ptrees' => [ 'mysql-ens-compara-prod-10', 'sbhurji_protostomes_metazoa_protein_trees_114' ],
    'insects_ptrees'     => [ 'mysql-ens-compara-prod-6', 'sbotond_insects_metazoa_protein_trees_115' ],
    'drosophila_ptrees'  => [ 'mysql-ens-compara-prod-8', 'sbotond_pangenome_drosophila_metazoa_protein_trees_115' ],

    # prev homology dbs required for ReindexMembers
    #'default_ptrees_prev'               => [ 'mysql-ens-compara-prod-X', '' ],
    #'protostomes_ptrees_prev'           => [ 'mysql-ens-compara-prod-X', '' ],
    #'insects_ptrees_prev'               => [ 'mysql-ens-compara-prod-X', '' ],
    #'pangenome_drosophila_ptrees_prev'  => [ 'mysql-ens-compara-prod-X', '' ],

    'drosophila_cactus'  => [ 'mysql-ens-compara-prod-6', 'sbotond_pangenome_drosophila_metazoa_load_cactus_115_take2' ],
};

Bio::EnsEMBL::Compara::Utils::Registry::add_compara_dbas( $compara_dbs );

# ----------------------NON-COMPARA DATABASES------------------------
# NCBI taxonomy database (maintained by production team):
Bio::EnsEMBL::Compara::Utils::Registry::add_taxonomy_dbas({
    'ncbi_taxonomy' => [ $curr_nv_host, "ncbi_taxonomy_$curr_release" ],
});

# -------------------------------------------------------------------

1;
