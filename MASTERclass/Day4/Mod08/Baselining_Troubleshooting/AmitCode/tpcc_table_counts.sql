use tpcc
go

select 'customer' as table_name, count (*) as customer_count from customer
union all
select 'district' as table_name, count (*) as district_count from district
union all
select 'history' as table_name, count (*) as history_count from history
union all
select 'item' as table_name, count (*) as item_count from item
union all
select 'new_order' as table_name, count (*) as new_order_count from new_order
union all
select 'order_line' as table_name, count (*) as order_line_count from order_line
union all
select 'orders' as table_name, count (*) as orders_count from orders
union all
select 'stock' as table_name, count (*) as stock_count from stock
union all
select 'warehouse' as table_name, count (*) as warehouse_count from warehouse

