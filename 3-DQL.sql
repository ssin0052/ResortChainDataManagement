
/* (i)*/

SELECT
    r.resort_name,
    r.resort_street_address
    || ' '
    || t.town_name
    || ' '
    || r.resort_pcode AS "RESORT ADDRESS",
    m.manager_name,
    m.manager_phone
FROM
    resort    r
    JOIN manager   m
    ON r.manager_id = m.manager_id
    JOIN town      t
    ON r.town_id = t.town_id
WHERE
    r.resort_star_rating IS NULL
    AND r.resort_livein_manager = 'Y'
ORDER BY
    r.resort_pcode DESC,
    r.resort_name;



/* (ii)*/

SELECT 
    r.resort_id,
    r.resort_name,
    r.resort_street_address,
    t.town_name,
    t.town_state,
    r.resort_pcode,
    SUM(b.booking_charge) AS total_booking_charges
FROM
    resort    r
    JOIN town      t
    ON r.town_id = t.town_id
    JOIN booking   b
    ON r.resort_id = b.resort_id
GROUP BY
    r.resort_id,
    r.resort_name,
    r.resort_street_address,
    t.town_name,
    t.town_state,
    r.resort_pcode
HAVING
    SUM(b.booking_charge) > (
        SELECT 
            SUM(booking_charge) / COUNT(DISTINCT resort_id)
        FROM
            booking
    )
ORDER BY
    resort_id;


    
/* (iii)*/

    
SELECT
    rv.review_id,
    rv.guest_no,
    g.guest_name,
    ( rv.resort_id ),
    r.resort_name,
    rv.review_comment,
    TO_CHAR(rv.review_date, 'dd-Mon-yyyy') AS date_reviewed
FROM
    review   rv
    FULL OUTER JOIN guest    g
    ON g.guest_no = rv.guest_no
    JOIN resort   r
    ON rv.resort_id = r.resort_id
WHERE
    rv.review_id NOT IN (
        SELECT
            review_id
        FROM
            review    rv
            JOIN booking   b
            ON rv.guest_no = b.guest_no
               AND rv.resort_id = b.resort_id
    )
    OR rv.review_date < (
        SELECT
            stay_completed
        FROM
            (
                SELECT
                    rv.guest_no,
                    rv.resort_id,
                    rv.review_id,
                    MIN(b.booking_to) AS stay_completed
                FROM
                    review    rv
                    JOIN booking   b
                    ON rv.guest_no = b.guest_no
                       AND rv.resort_id = b.resort_id
                GROUP BY
                    rv.resort_id,
                    rv.guest_no,
                    rv.review_id
            ) rvb
        WHERE
            rv.review_id = rvb.review_id
    );



/* (iv)*/


SELECT
    r.resort_id,
    r.resort_name,
    'has'
    || ' '
    || tc.total_cabin
    || ' '
    || 'cabins in total with'
    || ' '
    || mt.more_than_two
    || ' '
    || 'having more that 2 bedrooms' AS accomodation_available
FROM
    resort                                                                                                           r
    JOIN (
        SELECT
            resort_id,
            COUNT(cabin_no) AS total_cabin
        FROM
            cabin
        GROUP BY
            resort_id
        ORDER BY
            resort_id
    )              tc
    ON r.resort_id = tc.resort_id
    JOIN (
        SELECT
            resort_id,
            COUNT(cabin_no) AS more_than_two
        FROM
            cabin
        WHERE
            cabin_bedrooms > 2
        GROUP BY
            resort_id
        ORDER BY
            resort_id
    ) mt
    ON r.resort_id = mt.resort_id
ORDER BY
    resort_name;


 
/* (v)*/

--if assuming that popularity is based on the number of bookings

 SELECT
    r.resort_id,
    r.resort_name,
    CASE
        WHEN r.resort_livein_manager = 'Y' THEN
            'Yes'
        ELSE
            'No'
    END AS live_in_manager,
    nvl(TO_CHAR(resort_star_rating), 'No Ratings') AS star_rating,
    m.manager_name,
    m.manager_phone,
    COUNT(b.booking_id) AS number_of_bookings
FROM
    resort    r
    JOIN manager   m
    ON r.manager_id = m.manager_id
    JOIN booking   b
    ON r.resort_id = b.resort_id

GROUP BY
    r.resort_id,
    r.resort_name,
    r.resort_livein_manager,
    r.resort_star_rating,
    m.manager_name,
    m.manager_phone
ORDER BY
    count(b.booking_id)desc, 
    r.resort_id;



/* (vi)*/

SELECT
    r.resort_id,
    r.resort_name,
    p.poi_name,
    p.poi_street_address,
    p.town_id,
    t.town_state AS poi_state,
    TO_CHAR(p.poi_open_time, 'HH24:MI')as poi_opening_time,
    geodistance(e1.town_lat, e1.town_long, e2.town_lat, e2.town_long) AS separation_in_kms
FROM
    resort              r
    JOIN town                t
    ON r.town_id = t.town_id
    JOIN point_of_interest   p
    ON t.town_id = p.town_id
    JOIN town                e1
    ON e1.town_id = t.town_id
    JOIN town                e2
    ON e1.town_id = e2.town_id
GROUP BY
    r.resort_id,
    r.resort_name,
    p.poi_name,
    p.poi_street_address,
    p.town_id,
    t.town_state,
    p.poi_open_time,
    e1.town_id,
    e1.town_lat,
    e1.town_long,
    e2.town_lat,
    e2.town_long
HAVING
    geodistance(e1.town_lat, e1.town_long, e2.town_lat, e2.town_long) < 100
ORDER BY
    r.resort_name,
    geodistance(e1.town_lat, e1.town_long, e2.town_lat, e2.town_long);

--

