-- For lines that matched a snapshot window (not the gap fallback, not unlisted),
-- the order must fall inside [price_valid_from, price_valid_to).
select
    pricing.order_item_id,
    net.ordered_at,
    pricing.price_valid_from,
    pricing.price_valid_to
from {{ ref('int_orders__order_items_pricing') }} as pricing
inner join {{ ref('int_orders__order_items_net') }} as net
    on net.order_item_id = pricing.order_item_id
where not pricing.is_price_history_gap
  and not pricing.is_listing_missing
  and not (
        pricing.price_valid_from <= net.ordered_at
        and net.ordered_at < coalesce(pricing.price_valid_to, '9999-12-31'::timestamp_tz)
  )
