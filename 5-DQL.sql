

/* (i)*/

CREATE OR REPLACE TRIGGER booking_upd_cascade AFTER
    INSERT OR DELETE ON booking
    FOR EACH ROW
BEGIN
    IF inserting THEN
        UPDATE booking_completed
        SET
            number_of_booking = number_of_booking + 1
        WHERE
            guest_no = :new.guest_no;

    END IF;

    IF deleting THEN
        UPDATE booking_completed
        SET
            number_of_booking = number_of_booking - 1
        WHERE
            guest_no = :old.guest_no;

    END IF;

END;
/   

/* Test Harness*/

SET ECHO ON

SELECT
    *
FROM
    booking_completed
WHERE
    guest_no = 1;

/*test trigger*/

INSERT INTO booking VALUES (
    99,
    TO_DATE('30-Oct-2019', 'DD-Mon-YYYY'),
    TO_DATE('31-Oct-2019', 'DD-Mon-YYYY'),
    2,
    2,
    951.78,
    1,
    8,
    3
);

/*post state */

SELECT
    *
FROM
    booking_completed
WHERE
    guest_no = 1;

/*test trigger*/

DELETE FROM booking
WHERE
    booking_id = '99'
    AND guest_no = 1;

/*post state */

SELECT
    *
FROM
    booking_completed
WHERE
    guest_no = 1;

/*close transaction*/

ROLLBACK;

SET ECHO OFF


/* (ii)*/



CREATE OR REPLACE TRIGGER check_review BEFORE
    INSERT ON review
    FOR EACH ROW
DECLARE
    start_review     DATE;
    stay_completed   DATE;
BEGIN
    SELECT
        booking_to
    INTO stay_completed
    FROM
        booking
    WHERE
        guest_no = :new.guest_no;

    SELECT
        review_date
    INTO start_review
    FROM
        review
    WHERE
        guest_no = :new.guest_no;

    IF start_review > stay_completed THEN
        raise_application_error(-404,('Review can only be made after completed stay'
        ));
    END IF;
END;
/

/*test harness*/

SET ECHO ON

/*test trigger*/

INSERT INTO review VALUES (
    99,
    'damn',
    TO_DATE('05-Sep-2019', 'DD-Mon-YYYY'),
    4,
    2,
    5
);

/*close transaction*/

ROLLBACK;

SET ECHO OFF



/* (iii)*/

CREATE OR REPLACE TRIGGER check_booking BEFORE
    INSERT ON booking
    FOR EACH ROW
DECLARE
    occupied_status DATE;
BEGIN
    SELECT
        booking_flag
    INTO occupied_status
    FROM
        booking
    WHERE
        resort_id = :new.resort_id
        AND cabin_no = :new.cabin_no;

    IF occupied_status IN 'P' THEN
        raise_application_error(-999,('Cabin in the resort is occupied'));
    END IF;
END;
/


/*test harness*/

set echo on

/*test trigger*/
INSERT INTO booking VALUES (
    30,
    '27-Oct-2019',
    '29-Oct-2019',
    2,
    2,
    350.55,
    2,
    4,
    5
);

/*close transaction*/

ROLLBACK;

SET ECHO OFF;






