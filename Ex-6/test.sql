SELECT c.cust_id as name, SUM(ol.qty) as total_qty
FROM customer c
JOIN orders o
ON c.cust_id = o.cust_id
JOIN order_list ol
ON ol.order_no = o.order_no
JOIN pizza p
ON p.pizza_id = ol.pizza_id
GROUP BY c.cust_id, p.pizza_type
HAVING p.pizza_type = 'pan'
ORDER BY SUM(ol.qty) DESC;