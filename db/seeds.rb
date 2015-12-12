# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

   Role.create(id: 1,name:'master');
   Role.create(id: 2,name:'admin');
   Role.create(id: 3,name:'leader');
    Role.create(id: 4,name: 'curator');
    Role.create(id: 5,name: 'hard input');
    Role.create(id: 6, name:'common');
    Role.create(id: 7, name:'favorited');
    Role.create(id: 8,name:'flagger');

