SELECT
    ROUND(
        (SUM(p.amount * d.discount_percent / 100) / SUM(p.amount)) * 100,
        2
    ) AS overall_discount_percentage
FROM purchases p
LEFT JOIN discounts d
    ON p.discount_id = d.discount_id;