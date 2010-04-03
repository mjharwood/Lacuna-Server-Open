package Lacuna::DB::Building::Water::Reclamation;

use Moose;
extends 'Lacuna::DB::Building::Water';

around 'build_tags' => sub {
    my ($orig, $class) = @_;
    return ($orig->($class), qw(Waste));
};

use constant controller_class => 'Lacuna::Building::WaterReclamation';

use constant university_prereq => 7;

use constant image => 'waterreclamation';

use constant name => 'Water Reclamation Facility';

use constant food_to_build => 175;

use constant energy_to_build => 191;

use constant ore_to_build => 175;

use constant water_to_build => 175;

use constant waste_to_build => 20;

use constant time_to_build => 180;

use constant food_consumption => 1;

use constant energy_consumption => 19;

use constant ore_consumption => 3;

use constant water_production => 60;

use constant water_consumption => 6;

use constant waste_consumption => 50;

use constant waste_production => 9;


no Moose;
__PACKAGE__->meta->make_immutable;
