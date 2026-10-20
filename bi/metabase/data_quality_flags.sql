select
    count_if(is_vat_rate_missing)      as lines_missing_vat_rate,
    count_if(is_base_cost_missing)     as lines_missing_base_cost,
    count_if(is_price_history_gap)     as lines_price_history_gap,
    count_if(is_listing_missing)       as lines_without_listing,
    count_if(is_rate_carried_forward)  as lines_on_carried_forward_fx,
    count_if(is_unknown_product)       as lines_unknown_product,
    count(*)                           as total_lines
from ECOMMERCE_DB.MARTS.rpt_order_items