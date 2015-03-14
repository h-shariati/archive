begin;
delete from planet_osm_polygon where "natural" = 'coastline';
update planet_osm_line set layer=0 where layer is null;
update planet_osm_line set layer=0 where layer is null or layer !~ '^[0-9+-]+$';
Update planet_osm_line set z_order= 10*int4(layer) + 9 where highway='motorway' or highway='motorway_link';
update planet_osm_line set z_order= 10*int4(layer) + 8 where highway='trunk' or highway='trunk_link';
update planet_osm_line set z_order= 10*int4(layer) + 7 where highway='primary' or highway='primary_link';
update planet_osm_line set z_order= 10*int4(layer) + 6 where highway='secondary' or highway='secondary_link';
update planet_osm_line set z_order= 10*int4(layer) + 5 where char_length(railway) > 0;
update planet_osm_line set z_order= 10*int4(layer) + 4 where highway='tertiary' or highway='tertiary_link';
update planet_osm_line set z_order= 10*int4(layer) + 3 where highway='residential' or highway='minor' or highway='unclassified';
update planet_osm_line set z_order= 10*int4(layer) + 1 where waterway='stream' or waterway='river';
update planet_osm_line set z_order= z_order + 10  where bridge = 'true';
update planet_osm_line set z_order= z_order + 10  where bridge = 'yes';
update planet_osm_line set z_order= z_order - 3 where highway like '%link';
commit;
begin;
insert into planet_osm_point(osm_id,name,amenity,way) select osm_id,name,amenity,centroid(way) from planet_osm_polygon where amenity='parking';
end;
delete from geometry_columns where f_table_name='planet_osm_roads';
drop table planet_osm_roads ;
create table planet_osm_roads as select * from planet_osm_line where highway='motorway' or highway='motorway_link' or highway='trunk' or highway='trunk_link' or highway='primary' or highway='primary_link' or highway='secondary' or highway='secondary_trunk' or char_length(railway) > 0;
insert into geometry_columns values('','public','planet_osm_roads','way',2,4326,'LINESTRING');
create index planet_osm_roads_spidx on planet_osm_roads using GIST (way GIST_GEOMETRY_OPS);
vacuum analyze planet_osm_roads;