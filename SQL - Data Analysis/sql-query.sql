
 /* 
 1. Conducting a quarterly analysis of the business's growth by capturing the expansion 
 in both overall sessions and order volumes. 
 */
 
 SELECT 
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/* 
2. Illustrating the efficiency improvements by analysing quarterly metrics such as session to 
order conversion rate, revenue per order, and revenue per session.
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate,
    SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/* 
3. Examining the channel-specific growth by analysing the quarterly orders from various 
sources, including Gsearch nonbrand, Bsearch nonbrand, total brand search, organic search, 
and direct type-in.
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) as gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) as bsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) as brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) as organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) as direct_type_in_orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/*
4. Examining quarterly trends in the overall session to order conversion rates across 
different channels.
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) gsearch_nonbrand_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/*
5. Conducting monthly analysis of revenue and margin trends by product, together with 
total sales, to identify seasonal patterns.
*/

SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
	SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd-cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd-cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd-cogs_usd ELSE NULL END) AS birthdaybeary_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd-cogs_usd ELSE NULL END) AS minibear_marg,
	SUM(price_usd) AS total_rev,
    SUM(price_usd-cogs_usd) AS total_marg
FROM order_items
GROUP BY 1,2
ORDER BY 1,2;

/* 
6. Assessing the monthly sessions directed to the product page, the click-through rate 
from those sessions to the next page, and the conversion rates from the product page 
to completed orders.
*/

CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at AS saw_product_page_at
FROM website_pageviews
WHERE pageview_url = '/products';

SELECT 
	YEAR(saw_product_page_at) AS yr,
    MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS click_through_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
	LEFT JOIN orders
		ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2;

/*
7. Examining the monthly sessions and orders by device type to delve deeper into the 
sources of traffic.
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1, 2;

/*
8. Assessing the impact of the billing page test (from 10 Sep 2012 to 10 Nov 2012) by 
quantifying the revenue generated per billing page session.
*/

SELECT
	billing_version,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page
FROM(
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10'
	AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1;

/* 
9. Analysing sales data to assess the effectiveness of cross-selling between the four 
products since the introduction of the fourth product (5th Decemeber 2014).
*/

CREATE TEMPORARY TABLE primary_product
SELECT 
	order_id,
    primary_product_id, 
    created_at AS ordered_at
FROM orders
WHERE created_at > '2014-12-05';

SELECT 
	primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM 
(	
SELECT 
		primary_product.*,
        order_items.product_id AS cross_sell_product_id
FROM primary_product
	LEFT JOIN order_items
		ON order_items.order_id = primary_product.order_id
        AND order_items.is_primary_item = 0
) AS primary_w_cross_sell
GROUP BY 1;

/* 
10. 
Examining the monthly product refund rates by product to assess customer satisfaction 
with each product and identify notable product issues.
*/

SELECT 
	YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_id ELSE NULL END) AS p1_orders,
	COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_item_refunds.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_id ELSE NULL END) AS p1_refund_rt,
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_id ELSE NULL END) AS p2_orders,
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_item_refunds.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_id ELSE NULL END) AS p2_refund_rt,
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_id ELSE NULL END) AS p3_orders,
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_item_refunds.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_id ELSE NULL END) AS p3_refund_rt,
	COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_id ELSE NULL END) AS p4_orders,
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_item_refunds.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_id ELSE NULL END) AS p4_refund_rt
FROM order_items
	LEFT JOIN order_item_refunds
		ON order_items.order_item_id = order_item_refunds.order_item_id
GROUP BY 1,2;
