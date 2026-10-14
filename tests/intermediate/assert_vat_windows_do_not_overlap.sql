-- Two rules for the same country and category must never overlap.
-- This also catches two open-ended rules, since an open rule covers any later start.
select
    a.country_code,
    a.tax_category,
    a.valid_from as earlier_rule_start,
    b.valid_from as later_rule_start
from {{ ref('stg_tax__vat_rules') }} as a
inner join {{ ref('stg_tax__vat_rules') }} as b
    on a.country_code = b.country_code
   and a.tax_category = b.tax_category
   and a.valid_from < b.valid_from
   and b.valid_from <= coalesce(a.valid_to, '9999-12-31'::date)
