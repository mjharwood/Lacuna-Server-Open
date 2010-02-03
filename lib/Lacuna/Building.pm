package Lacuna::Building;

use Moose;
extends 'JSON::RPC::Dispatcher::App';

has simpledb => (
    is      => 'ro',
    required=> 1,
);

with 'Lacuna::Role::Sessionable';

sub domain_name {
    return 'building';
}

sub has_resources_to_operate {
    my ($self, $building) = @_;
    my $after = $building->stats_after_upgrade;
    foreach my $resource (qw(food energy ore water)) {
        my $method = $resource.'_hour';
        if (($after->{$method} - $building->$method) < 0) {
            confess [1012, "Not enough resources being produced to build this.", $resource];
        }
    }
    return 1;
}

sub has_resources_to_build {
    my ($self, $building, $body) = @_;
    my $cost = $building->cost_to_upgrade;
    foreach my $resource (qw(food energy ore water)) {
        my $stored = $resource.'_stored';
        if ($body->$stored >= $cost->{$resource}) {
            confess [1011, "Not enough resources in storage to build this.", $resource];
        }
    }
    return 1;
}

sub can_upgrade {
    my ($self, $building, $body) = @_;
    return $self->has_resources_to_build($building, $body)
        && $self->has_resources_to_operate($building);
}

sub get_body {
    my ($self, $building, $body) = @_;
    if ($body) {
        return $body;
    }
    else {
        return $building->body;
    }
}

sub get_building {
    my ($self, $building_id) = @_;
    if ($building_id->isa('Lacuna::DB::Building')) {
        return $building_id;
    }
    else {
        my $building = $self->simpledb->domain($self->domain_name)->find($building_id);
        if (defined $building) {
            return $building;
        }
        else {
            confess [1002, 'Building does not exist.', $building_id];
        }
    }
}

sub upgrade {
    my ($self, $session_id, $building_id) = @_;
    my $building = $self->get_building($building_id);
    my $empire = $self->get_empire_by_session($session_id);
    if ($building->empire_id eq $empire->id) {
        my $body = $building->body;
        $body->recalc_stats;
        $self->can_upgrade($building);
        # spend resources
        # add upgrade to queue
        return { success=>1, status=>$empire->get_status};
    }
    else {
        confess [1010, "Can't upgrade a building that you don't own.", $building_id];
    }
}

sub view {
    my ($self, $session_id, $building_id) = @_;
    my $building = $self->get_building($building_id);
    my $empire = $self->get_empire_by_session($session_id);
    if ($building->empire_id eq $empire->id) {
        return { 
            building    => {
                name        => $building->name,
                image       => $building->image,
                x           => $building->x,
                y           => $building->y,
                level       => $building->level,
                can_upgrade => (eval{$self->can_upgrade} ? 1 : 0),
            }
            status      => $empire->get_status,
        };
    }
    else {
        confess [1010, "Can't view a building that you don't own.", $building_id];
    }
}

sub create {
    my ($self, $session_id, $body_id, $x, $y) = @_;
}


__PACKAGE__->register_rpc_method_names(qw(upgrade));

no Moose;
__PACKAGE__->meta->make_immutable;

