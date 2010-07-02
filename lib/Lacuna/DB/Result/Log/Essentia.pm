package Lacuna::DB::Result::Log::Essentia;

use Moose;
extends 'Lacuna::DB::Result::Log';
use Lacuna::Util;

__PACKAGE__->table('essentia_log');
__PACKAGE__->add_columns(
    api_key             => { data_type => 'varchar', size => 40, is_nullable => 1 },
    amount              => { data_type => 'int', size => 11, is_nullable => 0 },
    description         => { data_type => 'varchar', size => 90, is_nullable => 0 },
    transaction_id      => { data_type => 'varchar', size => 32, is_nullable => 1 },
);

after 'sqlt_deploy_hook' => sub {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_api_key', fields => ['api_key']);
    $sqlt_table->add_index(name => 'idx_transaction_id', fields => ['transaction_id']);
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
