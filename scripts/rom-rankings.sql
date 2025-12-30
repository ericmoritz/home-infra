-- This updated my top roms collection with the top roms for every platform.
delete from collections_roms where collection_id = 4;

with latest_roms as (
        select r.igdb_id,
               r.id,
               r.name,
               p.slug as platform,
               md.average_rating as rating,
               row_number() over (partition by r.igdb_id
                                      order by r.revision desc,
                                               r.id desc) as rom_order
          from roms r
    inner join roms_metadata md on r.id = md.rom_id
    inner join platforms p on p.id = r.platform_id),

     ranked_roms as (
       select id as rom_id,
              name as rom_name,
              rating,
              platform,
              row_number() over (partition by platform
                                     order by rating desc) as rank
         from latest_roms
        where rom_order = 1
          and rating > 0
          and rating <> 100)

--   select *
--     from ranked_roms
--    where rank <= 10
-- order by platform, rank;

insert into collections_roms
(collection_id, rom_id)
select 4 as collection_id,
       rom_id
 from ranked_roms
where rank <= 25;
