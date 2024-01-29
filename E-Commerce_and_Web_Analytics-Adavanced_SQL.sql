use mavenfuzzyfactory;

/* 1. Analyze monthly trends for Gsearch sessions and orders to showcase growth. */

SELECT
-- 	YEAR(created_at),
 -- MONTH(created_at),
	MIN(DATE(ws.created_at)) AS month_start_date,
	COUNT(DISTINCT(ws.website_session_id)) AS total_sessions,
	COUNT(DISTINCT(o.order_id)) AS total_orders,
	COUNT(DISTINCT(o.order_id))/ COUNT(DISTINCT(ws.website_session_id)) AS conv_rate
FROM website_sessions AS ws
LEFT JOIN orders AS o
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-11-27' AND ws.utm_source = 'gsearch'
GROUP BY 
	YEAR(ws.created_at),
	MONTH(ws.created_at);



/* 2. Assess the performance of Gsearch campaigns, specifically nonbrand and brand campaigns, by monthly trends. */

SELECT
	-- YEAR(created_at),
	-- MONTH(created_at),
	MIN(DATE(ws.created_at)) AS month_start_date,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders
FROM website_sessions AS ws
LEFT JOIN orders AS o
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-11-27' AND ws.utm_source = 'gsearch'
GROUP BY 
	YEAR(ws.created_at),
	MONTH(ws.created_at);



/* 3. Dive into nonbrand Gsearch sessions and orders, segmented by device type, to understand traffic sources. */

SELECT
	-- YEAR(created_at),
	-- MONTH(created_at),
	MIN(DATE(ws.created_at)) AS month_start_date,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS nonbrand_desktop_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND device_type = 'desktop' THEN o.order_id ELSE NULL END) AS nonbrand_desktop_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS nonbrand_mobile_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND device_type = 'mobile' THEN o.order_id ELSE NULL END) AS nonbrand_mobile_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' AND device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS brand_desktop_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' AND device_type = 'desktop' THEN o.order_id ELSE NULL END) AS brand_desktop_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' AND device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS brand_mobile_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' AND device_type = 'mobile' THEN o.order_id ELSE NULL END) AS brand_mobile_orders
FROM website_sessions AS ws
LEFT JOIN orders AS o
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-11-27' AND ws.utm_source = 'gsearch'
GROUP BY 
	YEAR(ws.created_at),
	MONTH(ws.created_at);


/* 4. Compare monthly trends for Gsearch with other marketing channels to address concerns about traffic dependency. */

SELECT
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mon,
	COUNT(website_session_id) AS total_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS total_gsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS total_bsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'socialbook' THEN website_session_id ELSE NULL END) AS total_socialbook_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS total_organic_search_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS total_direct_typein_sessions
FROM website_sessions
WHERE created_at < '2012-11-27'
GROUP BY 1,2;


/* 5. Evaluate website performance improvements over eight months by analyzing session-to-order conversion rates. */

SELECT
	YEAR(ws.created_at) AS yrs,
	MONTH(ws.created_at) AS mon,
	COUNT(DISTINCT ws.website_session_id) AS total_sessions,
	COUNT(DISTINCT o.order_id) AS total_orders,
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM website_sessions AS ws
LEFT JOIN orders AS o
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-11-27'
GROUP BY 
	YEAR(created_at),
	MONTH(created_at);


/* 6. Estimate revenue generated from a Gsearch lander test and assess its incremental value. */

WITH lander_test_filter AS(
SELECT 
	wp.website_session_id,
	wp.created_at,
	wp.pageview_url,
	o.order_id,
	o.price_usd,
	o.cogs_usd
FROM website_pageviews AS wp
LEFT JOIN orders AS o
ON wp.website_session_id = o.website_session_id
LEFT JOIN website_sessions AS ws
ON ws.website_session_id = wp.website_session_id
WHERE wp.created_at > '2012-06-19' 
AND wp.created_at < '2012-07-28' 
 AND wp.pageview_url IN ('/home', '/lander-1')
 AND ws.utm_source = 'gsearch'
 AND ws.utm_campaign = 'nonbrand'
)
SELECT
	pageview_url,
	COUNT(DISTINCT website_session_id) AS total_sessions,
	COUNT(DISTINCT order_id) AS total_order,
	COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conversion_rate
FROM lander_test_filter
GROUP BY 1;



/* 7. Showcase a full conversion funnel from landing pages to orders for a previous landing page test. */

WITH all_filtered_data AS(
SELECT
	ws.website_session_id,
	wp.pageview_url,
	CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
	CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
	CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_pageviews AS wp
LEFT JOIN website_sessions AS ws
ON wp.website_session_id = ws.website_session_id
WHERE wp.created_at > '2012-06-19'
AND wp.created_at < '2012-07-28'
 AND ws.utm_source = 'gsearch'
 AND ws.utm_campaign = 'nonbrand'),
 
 max_data AS(
SELECT 
	website_session_id,
	MAX(home_page) AS max_home_page,
	MAX(lander_page) AS max_lander_page,
	MAX(products_page) AS max_product_page,
	MAX(mrfuzzy_page) AS max_mrfuzzy_page,
	MAX(cart_page) AS max_cart_page,
	MAX(shipping_page) AS max_shipping_page,
	MAX(billing_page) AS max_billing_page,
	MAX(thankyou_page) AS max_thankyou_page
FROM all_filtered_data
GROUP BY 1),

max_home_filtered_data AS (
SELECT *
FROM max_data
WHERE max_home_page = 1),
max_lander_filtered_data AS (
SELECT *
FROM max_data
WHERE max_lander_page = 1),

home_clicks AS(
SELECT
	CASE WHEN max_home_page = 1 THEN 'home_page' ELSE NULL END AS segment,
	COUNT(CASE WHEN max_home_page = 1 THEN website_session_id ELSE NULL END) AS click_home_page,
	COUNT(CASE WHEN max_product_page = 1 THEN website_session_id ELSE NULL END) AS click_product_page,
	COUNT(CASE WHEN max_mrfuzzy_page = 1 THEN website_session_id ELSE NULL END) AS click_mrfuzzy_page,
	COUNT(CASE WHEN max_cart_page = 1 THEN website_session_id ELSE NULL END) AS click_cart_page,
	COUNT(CASE WHEN max_shipping_page = 1 THEN website_session_id ELSE NULL END) AS click_shipping_page,
	COUNT(CASE WHEN max_billing_page = 1 THEN website_session_id ELSE NULL END) AS click_billing_page,
	COUNT(CASE WHEN max_thankyou_page = 1 THEN website_session_id ELSE NULL END) AS click_thankyou_page
FROM max_home_filtered_data),
 
lander_clicks AS(
SELECT
	CASE WHEN max_lander_page =1 THEN 'lander_page' ELSE NULL END AS segment,
	COUNT(CASE WHEN max_lander_page = 1 THEN website_session_id ELSE NULL END) AS click_home_page,
	COUNT(CASE WHEN max_product_page = 1 THEN website_session_id ELSE NULL END) AS click_product_page,
	COUNT(CASE WHEN max_mrfuzzy_page = 1 THEN website_session_id ELSE NULL END) AS click_mrfuzzy_page,
	COUNT(CASE WHEN max_cart_page = 1 THEN website_session_id ELSE NULL END) AS click_cart_page,
	COUNT(CASE WHEN max_shipping_page = 1 THEN website_session_id ELSE NULL END) AS click_shipping_page,
	COUNT(CASE WHEN max_billing_page = 1 THEN website_session_id ELSE NULL END) AS click_billing_page,
	COUNT(CASE WHEN max_thankyou_page = 1 THEN website_session_id ELSE NULL END) AS click_thankyou_page
FROM max_lander_filtered_data),

click_funnels AS(
SELECT *
FROM home_clicks
UNION ALL
SELECT *
FROM lander_clicks)

SELECT 
	segment,
	click_home_page AS home_clicks,
	click_product_page/click_home_page AS product_click_rate,
	click_mrfuzzy_page/click_product_page AS mrfuzzy_click_rate,
	click_cart_page/click_mrfuzzy_page AS cart_click_rate,
	click_shipping_page/click_cart_page AS shipping_click_rate,
	click_billing_page/click_shipping_page AS billing_click_rate,
	click_thankyou_page/click_billing_page AS thankyou_click_rate
FROM click_funnels
;




/* 8. Quantify the impact of a billing test in terms of revenue per billing page session and monthly impact. */

WITH filtered_data AS (
SELECT 
	wp.website_session_id,
	wp.pageview_url,
	o.price_usd
FROM website_pageviews AS wp
LEFT JOIN orders AS o
ON wp.website_session_id = o.website_session_id
WHERE wp.created_at > '2012-09-10'
AND wp.created_at < '2012-11-10'
 AND wp.pageview_url IN ('/billing', '/billing-2')),

avg_prices AS (
SELECT 
	pageview_url,
	COUNT( DISTINCT website_session_id) AS sessions,
	SUM(price_usd)/ COUNT( DISTINCT website_session_id) AS avg_price_per_billing_pg
FROM filtered_data
GROUP BY pageview_url)

-- Avergae price with the billing-2 increased from 22.8 for billing to 31.3 for billing-2 a differnce of 8.5 was seen
-- Total Revenue after the billing test we need to calculate the total sessions after the test

SELECT
	COUNT( DISTINCT website_session_id) AS total_sessions
FROM website_pageviews
WHERE created_at > '2012-10-27'
AND created_at < '2012-11-27'
 AND pageview_url IN ('/billing' , '/billing-2');
 
-- Total revenue for the last month will be 8.5 * total_sessions i.e 1193


/* 9. Track overall session and order volume trended by quarter to demonstrate volume growth. */

SELECT
	YEAR(ws.created_at) AS yr,
	QUARTER(ws.created_at) AS qtr,
	COUNT(ws.website_session_id) AS total_sessions,
	COUNT(o.order_id) AS total_orders
FROM website_sessions AS ws
LEFT JOIN orders AS o
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at <'2015-03-20' 
GROUP BY 1,2;

/* 10. Present quarterly figures for session-to-order conversion rate, revenue per order, and revenue per session to highlight efficiency improvements. */

SELECT
	YEAR(ws.created_at) AS yr,
	QUARTER(ws.created_at) AS qtr,
	COUNT(ws.website_session_id) AS total_sessions,
	COUNT(o.order_id) AS total_orders,
	COUNT(o.order_id)/COUNT(ws.website_session_id) AS conv_rate,
	SUM(o.price_usd) AS total_revenue,
	SUM(o.price_usd)/COUNT(o.order_id) AS revenue_per_order,
	SUM(o.price_usd)/COUNT(ws.website_session_id) AS revenue_per_session
FROM website_sessions AS ws
LEFT JOIN orders AS o
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at <'2015-03-20' 
GROUP BY 1,2;

/* 11. Analyze quarterly orders from specific channels to demonstrate channel growth. */

SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(ws.created_at) AS qtr,
	COUNT( CASE WHEN ws.utm_source = 'gsearch' and utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
	COUNT( CASE WHEN ws.utm_source = 'bsearch' and utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
	COUNT( CASE WHEN ws.utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders,
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN o.order_id ELSE NULL END) AS organic_search_orders,
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN o.order_id ELSE NULL END) AS direct_typein_orders
FROM website_sessions AS ws
LEFT JOIN orders AS o
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at <'2015-03-20' 
GROUP BY 1,2;

/* 12. Evaluate session-to-order conversion rate trends for channels by quarter, noting major improvements. */

SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(ws.created_at) AS qtr,
	COUNT( CASE WHEN ws.utm_source = 'gsearch' and utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
	COUNT( CASE WHEN ws.utm_source = 'gsearch' and utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS gsearch_nonbrand_sessions,
	COUNT( CASE WHEN ws.utm_source = 'gsearch' and utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)/
	COUNT( CASE WHEN ws.utm_source = 'gsearch' and utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rate,
	COUNT( CASE WHEN ws.utm_source = 'bsearch' and utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
	COUNT( CASE WHEN ws.utm_source = 'bsearch' and utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS bsearch_nonbrand_sessions,
	COUNT( CASE WHEN ws.utm_source = 'bsearch' and utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)/
	COUNT( CASE WHEN ws.utm_source = 'bsearch' and utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rate,
	COUNT( CASE WHEN ws.utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders,
	COUNT( CASE WHEN ws.utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT( CASE WHEN ws.utm_campaign = 'brand' THEN o.order_id ELSE NULL END)/COUNT( CASE WHEN ws.utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_session_conv_rate,
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN o.order_id ELSE NULL END) AS organic_search_orders,
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN o.order_id ELSE NULL END)/
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_search_conv_rate,
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN o.order_id ELSE NULL END) AS direct_typein_orders,
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_typein_sessions,
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN o.order_id ELSE NULL END)/
	COUNT( CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_typein_conv_rate
FROM website_sessions AS ws
LEFT JOIN orders AS o
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at <'2015-03-20' 
GROUP BY 1,2;

/* 13. Analyze monthly revenue and margin by product, along with total sales and revenue, noting seasonality trends. */

SELECT *
FROM ORDERS;

SELECT
	YEAR(created_at) AS yrs,
	MONTH(created_at) AS mnth,
	SUM(price_usd) AS total_revenue,
	SUM(price_usd)-SUM(cogs_usd) AS total_margin,
	SUM( CASE WHEN primary_product_id = 1 THEN price_usd ELSE NULL END) AS product_1_revenue,
	SUM( CASE WHEN primary_product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS product_1_margin,
	SUM( CASE WHEN primary_product_id = 2 THEN price_usd ELSE NULL END) AS product_2_revenue,
	SUM( CASE WHEN primary_product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS product_2_margin,
	SUM( CASE WHEN primary_product_id = 3 THEN price_usd ELSE NULL END) AS product_3_revenue,
	SUM( CASE WHEN primary_product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS product_3_margin,
	SUM( CASE WHEN primary_product_id = 4 THEN price_usd ELSE NULL END) AS product_4_revenue,
	SUM( CASE WHEN primary_product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS product_4_margin
FROM ORDERS
WHERE created_at <'2015-03-20' 
GROUP BY 1,2;

/* 14. Assess the impact of introducing new products by tracking sessions to product pages and conversion rates over time. */

WITH product_pageviews AS(
SELECT
	website_session_id,
	website_pageview_id,
	created_at AS saw_product_page_at
FROM website_pageviews
WHERE pageview_url = '/products')
SELECT 
	YEAR(pp.saw_product_page_at) AS yr,
	MONTH(pp.saw_product_page_at) AS mth,
	COUNT(DISTINCT pp.website_session_id) AS sessions_to_product_page,
	COUNT(DISTINCT wp.website_session_id) AS clicked_to_next_page,
	COUNT(DISTINCT wp.website_session_id)/COUNT(DISTINCT pp.website_session_id) AS clickthrough_rt,
	COUNT(o.order_id) AS orders,
	COUNT(o.order_id)/COUNT(DISTINCT pp.website_session_id) AS product_to_order_rt
FROM product_pageviews AS pp
LEFT JOIN website_pageviews AS wp
ON wp.website_session_id = pp.website_session_id
 AND wp.website_pageview_id > pp.website_pageview_id
LEFT JOIN orders AS o
ON o.website_session_id = pp.website_session_id
GROUP BY 1,2;

/* 15. Evaluate cross-selling performance since the introduction of a new primary product in December 2014. */

WITH data AS(
SELECT 
	o.order_id,
	o.primary_product_id,
	o.created_at,
	oi.product_id,
	oi.is_primary_item
FROM orders AS o
LEFT JOIN order_items AS oi
ON o.order_id = oi.order_id
WHERE o.created_at > '2014-12-05')
SELECT
	primary_product_id,
	COUNT(DISTINCT order_id) AS total_orders,
	COUNT(CASE WHEN product_id = 1 AND is_primary_item = 0 THEN order_id ELSE NULL END) AS _xsold_p1,
	COUNT(CASE WHEN product_id = 2 AND is_primary_item = 0 THEN order_id ELSE NULL END) AS _xsold_p2,
	COUNT(CASE WHEN product_id = 3 AND is_primary_item = 0 THEN order_id ELSE NULL END) AS _xsold_p3,
	COUNT(CASE WHEN product_id = 4 AND is_primary_item = 0 THEN order_id ELSE NULL END) AS _xsold_p4,
	COUNT(CASE WHEN product_id = 1 AND is_primary_item = 0 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
	COUNT(CASE WHEN product_id = 2 AND is_primary_item = 0 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
	COUNT(CASE WHEN product_id = 3 AND is_primary_item = 0 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
	COUNT(CASE WHEN product_id = 4 AND is_primary_item = 0 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM data
GROUP BY 1
ORDER BY 1;


