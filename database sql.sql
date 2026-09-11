USE discount_system;

SELECT
    pr.product_name,
    pr.category,
    pr.price,
    d.discount_percent,
    CalculateDiscountedPrice(pr.price, d.discount_percent) AS final_price
FROM products pr
JOIN discounts d
    ON pr.product_id = d.product_id
ORDER BY final_price;