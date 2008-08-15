use inc::Module::Install;

name 'Hash-Param';
all_from 'lib/Hash/Param.pm';

build_requires 'Test::More';

auto_install;

WriteAll;

