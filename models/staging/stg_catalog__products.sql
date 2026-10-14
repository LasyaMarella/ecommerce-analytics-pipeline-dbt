with source as (

    select * from {{ source('raw_catalog', 'products') }}

),

renamed as (

    select
        -- keys
        trim(product_id)                    as product_id,

        -- attributes
        trim(brand_name)                    as brand_name,
        lower(trim(category))               as category,

        -- measures
        base_cost_eur::number(18,4)         as base_cost_eur,

        -- timestamps
        created_at::timestamp_tz            as created_at,
        updated_at::timestamp_tz            as updated_at

    from source

)

select * from renamed
