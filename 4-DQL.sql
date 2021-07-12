
/* (i)*/


ALTER TABLE booking ADD (
    booking_flag CHAR(1)
);

ALTER TABLE booking
    ADD CONSTRAINT chk_booking_flag CHECK ( booking_flag IN (
        'C',
        'D',
        'F',
        'P'
    ) );

UPDATE booking
SET
    booking_flag = (
        SELECT
            (
                CASE
                    WHEN SYSDATE < booking_to THEN
                        'F'
                    WHEN SYSDATE > booking_to THEN
                        'C'
                    WHEN SYSDATE BETWEEN booking_from AND booking_to THEN
                        'P'
                    ELSE
                        'D'
                END
            )
        FROM
            dual
    );

ALTER TABLE booking MODIFY
    booking_flag DEFAULT 'F';


  
/* (ii)*/


CREATE TABLE booking_completed
    AS
        SELECT
            *
        FROM
            (
                SELECT
                    guest_no,
                    COUNT(*) AS booking_completed
                FROM
                    (
                        SELECT
                            guest_no,
                            COUNT(booking_to)
                        FROM
                            booking
                        WHERE
                            booking_to < SYSDATE
                        GROUP BY
                            booking_to,
                            guest_no
                        ORDER BY
                            guest_no
                    ) completed
                GROUP BY
                    guest_no
                ORDER BY
                    guest_no
            );


--or

ALTER TABLE guest ADD (
    completed_booking NUMBER(4)
);

UPDATE guest
SET
    completed_booking = (
        SELECT
            a.completed_booking
        FROM
            (
                SELECT
                    COUNT(booking_id)
                FROM
                    booking
                WHERE
                    booking_flag = 'C'
                GROUP BY
                    guest_no
            ) b
            JOIN guest                                                                      g
            ON g.guest_no = b.guest_no
    );



/* (iii)*/


ALTER TABLE resort ADD (
    id_bm NUMBER(4)
);

ALTER TABLE resort ADD (
    id_cm NUMBER(4)
);

ALTER TABLE resort ADD (
    id_mm NUMBER(4)
);

COMMENT ON COLUMN resort.id_bm IS
    'Bookings manager identifier';

COMMENT ON COLUMN resort.id_cm IS
    'Cleaning manager identifier';

COMMENT ON COLUMN resort.id_mm IS
    'Maintenance manager identifier';

ALTER TABLE resort
    ADD CONSTRAINT fk_bm FOREIGN KEY ( id_bm )
        REFERENCES manager ( manager_id );

ALTER TABLE resort
    ADD CONSTRAINT fk_cm FOREIGN KEY ( id_cm )
        REFERENCES manager ( manager_id );

ALTER TABLE resort
    ADD CONSTRAINT fk_mm FOREIGN KEY ( id_mm )
        REFERENCES manager ( manager_id );

UPDATE resort
SET
    id_bm = (
        SELECT
            manager_id
        FROM
            resort
        WHERE
            resort_name = 'Parkhouse Byron Bay Resort'
    )
WHERE
    resort_name = 'Parkhouse Byron Bay Resort';

UPDATE resort
SET
    id_cm = (
        SELECT
            manager_id
        FROM
            manager
        WHERE
            manager_phone = '6002318099'
    )
WHERE
    resort_name = 'Parkhouse Byron Bay Resort';

UPDATE resort
SET
    id_mm = (
        SELECT
            manager_id
        FROM
            manager
        WHERE
            manager_phone = '9636535741'
    )
WHERE
    resort_name = 'Parkhouse Byron Bay Resort';

COMMIT;





