SET serveroutput on
SET PAGESIZE 100
SET LINESIZE 200 
SET UNDERLINE =
SET VERIFY OFF

PROMPT Reservations Management
PROMPT =======================
ACCEPT IN_CUST_ID PROMPT 'Enter Customer ID: '
ACCEPT IN_PAX_NUM NUMBER PROMPT 'Enter Pax Num: '
ACCEPT IN_DATE PROMPT 'Enter Reservation Date: '
ACCEPT IN_TIME PROMPT 'Enter Reservation Time: '

SELECT TABLEID, TABLESIZE FROM TABLES WHERE TABLESIZE >= &IN_PAX_NUM;

ACCEPT IN_TABLE_ID PROMPT 'Enter Table ID: '

CREATE OR REPLACE PROCEDURE ReservationsManagement(IN_CUST_ID IN VARCHAR, IN_PAX_NUM IN NUMBER, IN_DATE IN VARCHAR, IN_TIME IN VARCHAR, IN_TABLE_ID IN VARCHAR) IS
    v_reservation_date RESERVATIONDETAILS.RESERVATIONDATE%TYPE;
    v_reservation_time RESERVATIONDETAILS.RESERVATIONTIME%TYPE;
    v_pax_num RESERVATIONDETAILS.PAXNUM%TYPE;
    v_max_id RESERVATION.RESERVATIONID%TYPE;
    v_table_id RESERVATIONDETAILS.TABLEID%TYPE;
    v_reservation_id RESERVATIONDETAILS.RESERVATIONID%TYPE;
    v_cust_id RESERVATION.CUSTID%TYPE;
    v_table_size TABLES.TABLESIZE%TYPE;
    v_reservation_creation_time RESERVATION.RESERVATIONCREATIONTIME%TYPE;
    v_converted_diff NUMBER := 0;
    v_time_diff INTERVAL DAY TO SECOND;

BEGIN
    BEGIN
        v_reservation_date := TO_DATE(IN_DATE, 'DD/MM/YYYY');
        v_reservation_time := to_timestamp(v_reservation_date || ' ' || IN_TIME, 'DD/MM/RRRR HH24:MI:SSXFF');
        
        SELECT MAX(RESERVATIONID) INTO v_max_id FROM RESERVATION;
        --     SELECT RD.RESERVATIONTIME, RD.RESERVATIONDATE, RD.PAXNUM, RD.TABLEID, RD.RESERVATIONID
        --     INTO v_reservation_time, v_reservation_date, v_pax_num, v_table_id, v_reservation_id
        --     FROM RESERVATIONDETAILS RD
        --     INNER JOIN RESERVATION R ON R.RESERVATIONID = RD.RESERVATIONID
        --     INNER JOIN TABLES T ON T.TABLEID = RD.TABLEID
        --     WHERE RD.RESERVATIONID = v_reservation_id;
        -- EXCEPTION
        --     WHEN NO_DATA_FOUND THEN
        --         v_reservation_id := NULL;
        INSERT INTO RESERVATION (RESERVATIONID, STATUS, CUSTID) 
        VALUES('RS' || TO_CHAR(TO_NUMBER(SUBSTR(v_max_id, 3)) + 1, 'FM000'), 'PENDING', IN_CUST_ID);

        -- CHECK TABLE SIZE AND PAX SIZE
        SELECT TABLESIZE INTO v_table_size FROM TABLES WHERE TABLEID = IN_TABLE_ID;
        SELECT RESERVATIONCREATIONTIME INTO v_reservation_creation_time FROM RESERVATION
        WHERE RESERVATIONID = 'RS' || TO_CHAR(TO_NUMBER(SUBSTR(v_max_id, 3)) + 1, 'FM000');

        -- CHECK WHETHER IS THE RESERVATION MADE BEFORE 2 HOURS
        v_time_diff := v_reservation_time - v_reservation_creation_time;


        IF IN_PAX_NUM >= v_table_size AND (v_time_diff >= INTERVAL '0 02:00:00' DAY TO SECOND) THEN
            
            DBMS_OUTPUT.PUT_LINE('The time difference is greater than 2 hours.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('The time difference is not greater than 2 hours.');


            -- CHECK IF THE TABLE AND TIME FRAME IS FREE OR NOT



            -- IF CAN, THEN INSERT INTO NEW RESERVATION DETAILS


        END IF;
    END;
END;
/

EXEC ReservationsManagement(UPPER('&IN_CUST_ID'), &IN_PAX_NUM, UPPER('&IN_DATE'), UPPER('&IN_TIME'), UPPER('&IN_TABLE_ID'));
  