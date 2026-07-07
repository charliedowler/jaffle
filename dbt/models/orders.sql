{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

order_payments as (

    select
        order_id,

        {% for payment_method in payment_methods -%}
        sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount,
        {% endfor -%}

        sum(amount) as total_amount

    from payments

    group by 1

),

customer_max_other_amounts as (

    select
        o1.order_id,
        max(op2.total_amount) as customer_max_other_order_amount
    from orders o1
    left join orders o2
        on o1.customer_id = o2.customer_id
        and o1.order_id != o2.order_id
    left join order_payments op2
        on o2.order_id = op2.order_id
    group by o1.order_id

),

final as (

    select
        -- Athena/Trino: USING joins create unqualified columns, can't reference as table.col
        {% if target.type == 'trino' or target.type == 'athena' %}
        order_id,
        {% else %}
        orders.order_id,
        {% endif %}
        orders.customer_id,
        orders.order_date,
        orders.status,
        case when status = 'completed' then TRUE else FALSE end AS is_completed,
        orders.order_source,
        orders.shipping_method,
        orders.promo_code,
        orders.order_priority,
        orders.estimated_delivery_days,
        orders.shipping_cost,
        orders.tax_rate,
        orders.currency,
        orders.fulfillment_center,
        orders.order_notes,

        {% for payment_method in payment_methods -%}

        order_payments.{{ payment_method }}_amount,

        {% endfor -%}

        order_payments.total_amount as amount,

        customer_max_other_amounts.customer_max_other_order_amount

    from orders

    left join order_payments using (order_id)
    left join customer_max_other_amounts using (order_id)

)

select * from final
