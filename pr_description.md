## Summary

- Updated the `order_date` dimension description in `dbt/models/orders.yml` from "Date (UTC) that the order was placed" to "Date (BST) that the order was placed" to reflect the correct British Summer Time (UTC+1) timezone.

## Details

The `order_date` field is a plain `DATE` type sourced from CSV data (no time-of-day component), so no SQL timezone conversion was needed in `orders.sql` or `stg_orders.sql`. The change is a description update only, consistent with the intent to document the timezone context as BST rather than UTC.

No granularity variants (day, week, month, quarter, year, bi-weekly, fiscal quarter, day of week name, month name) had individual UTC descriptions to update.

## Test plan

- [ ] Verify `order_date` dimension in the Orders explore shows "BST" in its description
- [ ] Confirm all time interval granularities for `order_date` still appear and function correctly
- [ ] Run `dbt test --select orders` to confirm no regressions
