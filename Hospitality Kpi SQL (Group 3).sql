Create database Projectp670;
use projectp670;

select * from dim_date;
select * from dim_hotels;
select * from dim_rooms;
select * from fact_aggregated_Bookings;
select * from fact_Bookings;
desc fact_bookings;




# 1--Total revenue
Select SUM(revenue_realized) AS Total_Revenue_Realized FROM fact_bookings;

# 2--Occupancy
Select sum(successful_bookings)/sum(capacity) * 100 as occupany_rate from fact_aggregated_Bookings;

# 3--Cancellation Rate
SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings)) AS Cancellation_Percentage FROM fact_bookings WHERE booking_status = 'Cancelled';

# 4--Total Booking
select count(*) as total_booking from fact_bookings;

# 5--Utilize capacity
SELECT SUM(capacity) AS Total_Room_Capacity FROM fact_aggregated_bookings;

# 6--Trend Analysis
SELECT 
    d.`mmm yy` AS month_year,
    h.property_name,
    r.room_class,
    COUNT(DISTINCT fb.booking_id) AS total_bookings,
    SUM(fb.revenue_generated) AS total_revenue,
    SUM(fb.revenue_realized) AS realized_revenue,
    SUM(fb.no_guests) AS total_guests,
    SUM(fab.successful_bookings) AS successful_bookings,
    SUM(fab.capacity) AS total_capacity,
    (SUM(fab.successful_bookings) * 1.0 / NULLIF(SUM(fab.capacity), 0)) * 100 AS occupancy_rate
FROM 
    dim_date d
JOIN 
    fact_bookings fb ON d.date = fb.booking_date
JOIN 
    dim_hotels h ON fb.property_id = h.property_id
JOIN 
    dim_rooms r ON fb.room_category = r.room_id
LEFT JOIN 
    fact_aggregated_bookings fab ON fb.property_id = fab.property_id
       AND fb.check_in_date = fab.check_in_date
       AND fb.room_category = fab.room_category
WHERE 
    fb.booking_status = 'successful'  -- Filter for successful bookings
GROUP BY 
    d.`mmm yy`, h.property_name, r.room_class
ORDER BY 
    d.`mmm yy`, h.property_name, r.room_class;
    

# 7--Weekdays and Weekend Revenue and Booking
SELECT 
    h.property_name,
    r.room_class,
    d.day_type,
    COUNT(DISTINCT fb.booking_id) AS total_bookings,
    SUM(fb.revenue_generated) AS total_revenue,
    SUM(fb.revenue_realized) AS realized_revenue
FROM 
    dim_date d
JOIN 
    fact_bookings fb ON d.date = fb.booking_date
JOIN 
    dim_hotels h ON fb.property_id = h.property_id
JOIN 
    dim_rooms r ON fb.room_category = r.room_id
GROUP BY 
    h.property_name, r.room_class, d.day_type
ORDER BY 
    h.property_name, r.room_class, d.day_type;

#8--Revenue By State and Hotel
SELECT 
    h.city AS state_city,
    h.property_name AS hotel_name,
    SUM(fb.revenue_generated) AS total_revenue,
    SUM(fb.revenue_realized) AS realized_revenue
FROM 
    fact_bookings fb
JOIN 
    dim_hotels h ON fb.property_id = h.property_id
GROUP BY 
    h.city, h.property_name
ORDER BY 
    h.city, h.property_name;
    
# 9--Class Wise Revenue
SELECT 
    r.room_class AS class,
    h.property_name AS hotel_name,
    SUM(fb.revenue_generated) AS total_revenue,
    SUM(fb.revenue_realized) AS realized_revenue,
    COUNT(DISTINCT fb.booking_id) AS total_bookings
FROM 
    fact_bookings fb
JOIN 
    dim_rooms r ON fb.room_category = r.room_id  -- Join on room category
JOIN 
    dim_hotels h ON fb.property_id = h.property_id  -- Join on hotel property ID
WHERE 
    fb.booking_status = 'Checked Out'  -- Filter for successful bookings
GROUP BY 
    r.room_class, h.property_name  -- Group by room class and hotel name
ORDER BY 
    r.room_class, h.property_name;  -- Order by room class and hotel name

# 10-- Checked out cancel No show
SELECT 
    h.property_name AS hotel_name,
    COUNT(CASE WHEN fb.booking_status = 'Checked Out' THEN 1 END) AS total_checked_out,
    COUNT(CASE WHEN fb.booking_status = 'Cancelled' THEN 1 END) AS total_canceled,
    COUNT(CASE WHEN fb.booking_status = 'No Show' THEN 1 END) AS total_no_show,
    SUM(no_guests) AS total_guests  -- Optional: Count of total guests for context
FROM 
    fact_bookings fb
JOIN 
    dim_hotels h ON fb.property_id = h.property_id  -- Join to get hotel names
GROUP BY 
    h.property_name  -- Group by hotel name
ORDER BY 
    h.property_name;  -- Order by hotel name

# 11--Weekly trend Key trend (Revenue, Total booking, Occupancy) 
SELECT 
    d.`week no` AS week_number,
    d.`mmm yy` AS month_year,
    SUM(fb.revenue_generated) AS total_revenue,
    COUNT(DISTINCT fb.booking_id) AS total_bookings,
    SUM(fa.successful_bookings) AS total_occupancy
FROM 
    dim_date d
LEFT JOIN 
    fact_bookings fb ON d.date = fb.booking_date  -- Join for revenue and bookings
LEFT JOIN 
    fact_aggregated_bookings fa ON d.date = fa.check_in_date  -- Join for occupancy data
WHERE 
    fb.booking_status = 'Checked Out'  -- Filter for successful bookings
GROUP BY 
    d.`week no`, d.`mmm yy`  -- Group by week number and month-year
ORDER BY 
    d.`week no`, d.`mmm yy`;  -- Order by week number and month-year









