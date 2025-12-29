-- This updated my top roms collection with the top roms for every platform.
delete from collections_roms where collection_id = 3;

with latest_roms as (select r.igdb_id,
                            r.id,
                            r.name,
                            p.slug as platform,
                            md.average_rating,
                            row_number() over (partition by r.igdb_id
                                                   order by r.revision desc,
                                                            r.id desc) as rom_order
                       from roms r
                 inner join roms_metadata md on r.id = md.rom_id
                 inner join platforms p on p.id = r.platform_id
                      where average_rating > 0),

     ranked_roms as (select id as rom_id,
                     row_number() over (partition by platform order by average_rating desc) as rank
                     from latest_roms
                     where rom_order = 1)


insert into collections_roms
(collection_id, rom_id)
select 3 as collection_id,
       rom_id
 from ranked_roms
where rank <= 10;
