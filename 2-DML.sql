
/* (i)*/
/*create sequence*/
CREATE SEQUENCE resort_seq START WITH 100 INCREMENT BY 1;

COMMIT;



/* (ii)*/
/*Insert Awesome Resort*/

INSERT INTO resort VALUES (
    resort_seq.NEXTVAL,
    'Awesome Resort',
    '50 Awesome Road',
    '4830',
    NULL,
    'N',
    (
        SELECT
            town_id
        FROM
            town
        WHERE
            town_lat = - 20.7256
    ),
    (
        SELECT
            manager_id
        FROM
            manager
        WHERE
            manager_phone = '6002318099'
    )
);

INSERT INTO cabin VALUES (
    1,
    resort_seq.CURRVAL,
    3,
    6,
    'Free Wi-Fi, Kitchen with 400 ltr refrigerator, stove, microwave, pots, pans, silverware, toaster, electric kettle, TV and utensils'
);

INSERT INTO cabin VALUES (
    2,
    resort_seq.CURRVAL,
    2,
    4,
    'Free Wi-Fi, Kitchen with 280 ltr refrigerator, stove, pots, pans, silverware, toaster, electric kettle, TV and utensils'
);

COMMIT;



/* (iii)*/
/*update RESORT*/

UPDATE resort
SET
    manager_id = (
        SELECT
            manager_id
        FROM
            manager
        WHERE
            manager_phone = '9636535741'
    )
WHERE
    resort_name = 'Awesome Resort';

COMMIT;


      
/* (iv)*/
/*delete RESORT*/

DELETE FROM cabin
WHERE
    resort_id = (
        SELECT
            resort_id
        FROM
            resort
        WHERE
            resort_name = 'Awesome Resort'
    );

DELETE FROM resort
WHERE
    resort_name = 'Awesome Resort';

COMMIT;