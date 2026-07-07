-- orders_flat: intentionally flat. Per-order values are computed with
-- correlated subqueries rather than joins or CTEs. This is the local style.

select
    o.order_id,
    o.customer_id,
    o.order_date,

    -- total paid for THIS order
    (
        select sum(p.amount)
        from {{ ref('stg_payments') }} as p
        where p.order_id = o.order_id
    ) as order_total,

    -- number of orders this customer placed on or before this order
    (
        select count(*)
        from {{ ref('stg_orders') }} as o2
        where o2.customer_id = o.customer_id
          and o2.order_date <= o.order_date
    ) as customer_orders_to_date

from {{ ref('stg_orders') }} as o
