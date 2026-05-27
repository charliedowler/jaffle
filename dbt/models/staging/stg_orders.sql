with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_orders') }}

),

renamed as (

    select
        id as order_id,
        user_id as customer_id,
        {{ cast_date('order_date_utc') }} as order_date_utc,
        status,
        order_source,
        shipping_method,
        promo_code,
        order_priority,
        estimated_delivery_days,
        shipping_cost,
        tax_rate,
        currency,
        fulfillment_center,
        order_notes

    from source

)

select * from renamed
