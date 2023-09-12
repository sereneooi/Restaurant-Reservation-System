-- Cancellation Report
SET serveroutput on
SET PAGESIZE 100
SET LINESIZE 200 
SET UNDERLINE =
SET VERIFY OFF

PROMPT Cancellation Report
PROMPT ===================
ACCEPT IN_YEAR NUMBER PROMPT 'Enter Year: '

-- PREVIOUS YEAR CANCELLATION
CREATE OR REPLACE VIEW PREVIOUS_CANCELLATION AS
    SELECT EXTRACT(YEAR FROM TO_DATE(C.CANCELCREATIONDATE)) AS YR, SUM(O.TOTALAMOUNT) AS TOTAL
    FROM ORDERS O
    INNER JOIN CANCELLATION C ON C.CANCELID = O.CANCELID
    WHERE EXTRACT(YEAR FROM TO_DATE(C.CANCELCREATIONDATE)) = &IN_YEAR - 1
    GROUP BY EXTRACT(YEAR FROM TO_DATE(C.CANCELCREATIONDATE));

CREATE OR REPLACE VIEW CANCELLATION_REASON AS
    SELECT * FROM (
        SELECT C.REASON, COUNT(O.CANCELID) AS FREQ
        FROM ORDERS O
        INNER JOIN CANCELLATION C ON C.CANCELID = O.CANCELID
        WHERE EXTRACT(YEAR FROM TO_DATE(C.CANCELCREATIONDATE)) = &IN_YEAR
        GROUP BY EXTRACT(YEAR FROM TO_DATE(C.CANCELCREATIONDATE)), C.REASON
        ORDER BY FREQ DESC
    )
    WHERE ROWNUM = 1;
    
CREATE OR REPLACE PROCEDURE CancellationReport(IN_YEAR IN NUMBER) IS
    v_count NUMBER(2) := 1;
    v_overall NUMBER(25, 2) := 0;
    v_prev_amount NUMBER(25, 2) := 0;
    v_prev_year NUMBER(4);
    v_price NUMBER(6, 2) := 0;
    v_name VARCHAR(50);
    v_reason VARCHAR(50);
    v_freq NUMBER(3) := 0;

CURSOR CANCELLATION_CUR IS
    SELECT SM.SETNAME, MI.ITEMNAME, SUM(O.TOTALAMOUNT) AS TOTAL_CANCELED_AMOUNT, 
    COUNT(*) AS CANCELLED_ORDERS, EXTRACT(YEAR FROM TO_DATE(C.CANCELCREATIONDATE)) AS YR, 
    MI.PRICE AS MENU_PRICE, SM.PRICE AS SET_PRICE, SUM(OD.ITEMQTY) AS QTY
    FROM ORDERS O
    INNER JOIN CANCELLATION C ON C.CANCELID = O.CANCELID
    INNER JOIN ORDERDETAILS OD ON O.ORDERID = OD.ORDERID
    LEFT JOIN MENUITEM MI ON OD.ITEMID = MI.ITEMID
    LEFT JOIN SETMENU SM ON SM.SETID = OD.SETID
    WHERE EXTRACT(YEAR FROM TO_DATE(C.CANCELCREATIONDATE)) = IN_YEAR
    GROUP BY EXTRACT(YEAR FROM TO_DATE(C.CANCELCREATIONDATE)),  SM.SETNAME, MI.ITEMNAME,MI.PRICE, SM.PRICE
    ORDER BY CANCELLED_ORDERS DESC;

    t_rec CANCELLATION_CUR%ROWTYPE;

BEGIN
    BEGIN
        SELECT * INTO v_prev_year, v_prev_amount FROM PREVIOUS_CANCELLATION;
        SELECT * INTO v_reason, v_freq FROM CANCELLATION_REASON;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_prev_amount := 0;
    END;
    
    DBMS_OUTPUT.PUT_LINE(LPAD ('-', 160, '-'));
    DBMS_OUTPUT.PUT_LINE(' | '|| LPAD('OT COMPANY ', 80, ' ') || LPAD(' | ', 79));
    DBMS_OUTPUT.PUT_LINE(' | '|| LPAD('---------- ', 80, ' ') || LPAD(' | ', 79));
    DBMS_OUTPUT.PUT_LINE(' | '|| LPAD('CANCELLATION REPORT IN ', 85, ' ') || IN_YEAR || LPAD(' | ', 70));
    DBMS_OUTPUT.PUT_LINE(' | '|| LPAD('DATE: ', 73, ' ') || SYSDATE || LPAD(' | ', 77));
    DBMS_OUTPUT.PUT_LINE(LPAD ('-', 160, '-'));
    
    DBMS_OUTPUT.PUT_LINE(
        RPAD('| ' || 'NO', 8) ||
        RPAD('| ' || 'MENU', 59) ||
        RPAD('| ' || 'UNIT PRICE', 20) ||
        RPAD('| ' || 'TOTAL QUANTITY', 19) ||
        RPAD('| ' || 'TOTAL CANCELED ORDER', 23) ||
        RPAD('| ' || 'TOTAL CANCELED AMOUNT', 30) || '|'
    );
    DBMS_OUTPUT.PUT_LINE(LPAD ('-', 160, '-'));

    FOR t_rec IN CANCELLATION_CUR LOOP
        IF t_rec.SETNAME IS NOT NULL THEN 
            v_name := t_rec.SETNAME;
            v_price := t_rec.SET_PRICE;
        ELSE
            v_name := t_rec.ITEMNAME;
            v_price := t_rec.MENU_PRICE;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD('| ' || v_count, 8) ||
            RPAD('| ' || v_name, 59) ||
            RPAD('| RM ' || TO_CHAR(v_price, '999,999.99'), 20) ||
            RPAD('| ' || t_rec.QTY, 19) ||
            RPAD('| ' || t_rec.CANCELLED_ORDERS, 23) ||
            RPAD('| RM ' || TO_CHAR(t_rec.TOTAL_CANCELED_AMOUNT, '9999,999,999,999,999.99'), 30) || '|'
        );

    v_overall := v_overall + t_rec.TOTAL_CANCELED_AMOUNT;
    v_count := v_count + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(LPAD ('-', 160, '-'));
    DBMS_OUTPUT.PUT_LINE(LPAD ('|', 160, ' ') || LPAD('============================' || '|', 159));
    DBMS_OUTPUT.PUT_LINE(LPAD ('|', 160, ' ') || LPAD('TOTAL: RM ' || TO_CHAR(v_overall, '999,999,999.99') || ' |', 159));
    DBMS_OUTPUT.PUT_LINE(LPAD ('-', 160, '-'));
    DBMS_OUTPUT.PUT_LINE(chr(10));
    
    IF v_prev_amount != 0 THEN
        DBMS_OUTPUT.PUT_LINE('COMPARE WITH PREVIOUS YEAR: ' || v_prev_year);
        DBMS_OUTPUT.PUT_LINE('PREVIOUS CANCELLATION AMOUNT: RM ' || TO_CHAR(v_prev_amount, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('PERCENTAGE: ' || TO_CHAR(((v_overall-v_prev_amount)/(v_prev_amount))*100, '000.00') || '%');
    END IF;
    DBMS_OUTPUT.PUT_LINE(chr(10));

    DBMS_OUTPUT.PUT_LINE('HIGHEST FREQUENCY CANCELLATION REASONS: ' || v_reason);
    DBMS_OUTPUT.PUT_LINE('FREQUENCY: ' || v_freq);
    DBMS_OUTPUT.PUT_LINE(' . '|| LPAD('End Of Report. ', 80, ' ') || LPAD(' . ', 79));
END;
/

EXEC CancellationReport(&IN_YEAR);


