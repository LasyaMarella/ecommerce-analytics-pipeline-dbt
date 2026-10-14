-- Versions of the same listing must not overlap, and only the latest may be open-ended.
select
    a.listing_id,
    a.dbt_valid_from as earlier_version_start,
    b.dbt_valid_from as later_version_start
from {{ ref('snap_listing_prices') }} as a
inner join {{ ref('snap_listing_prices') }} as b
    on a.listing_id = b.listing_id
   and a.dbt_valid_from < b.dbt_valid_from
   and b.dbt_valid_from < coalesce(a.dbt_valid_to, '9999-12-31'::timestamp_tz)
