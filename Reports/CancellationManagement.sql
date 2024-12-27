SET serveroutput on
SET PAGESIZE 100
SET LINESIZE 200 
SET UNDERLINE =
SET VERIFY OFF

PROMPT Cancellation Management
PROMPT =======================
PROMPT 1. INSERT NEW CANCELLATION 
PROMPT 2. UPDATE CANCELLATION 

ACCEPT IN_ACTION NUMBER PROMPT 'Choose a number: '
ACCEPT IN_ORDER_ID PROMPT 'Enter Order ID: '

PROMPT Cancellation Reasons 
PROMPT =====================
PROMPT WEATHER CONDITIONS
PROMPT PRICE 
PROMPT MODIFY ORDER

ACCEPT IN_REASON PROMPT 'REASON: ' 

CREATE OR REPLACE PROCEDURE CancellationManagement(IN_ACTION IN NUMBER, IN_ORDER_ID IN VARCHAR, IN_REASON IN VARCHAR) IS
    v_order_id ORDERS.ORDERID%TYPE := IN_ORDER_ID;
    v_cancel_id CANCELLATION.CANCELID%TYPE;
    v_reason CANCELLATION.REASON%TYPE;
    v_time CANCELLATION.CANCELCREATIONTIME%TYPE;
    v_max_cancel_id CANCELLATION.CANCELID%TYPE;
    v_payment PAYMENT.PAYMENTID%TYPE;
    v_cancel CANCELLATION.CANCELID%TYPE;

CURSOR CANCELLATION_CUR IS
    SELECT O.ORDERID, C.CANCELID, C.REASON, C.CANCELCREATIONTIME
    FROM ORDERS O
    LEFT JOIN CANCELLATION C ON C.CANCELID = O.CANCELID
    WHERE UPPER(O.ORDERID) = UPPER(v_order_id);

    t_rec CANCELLATION_CUR%ROWTYPE;
    
BEGIN
    OPEN CANCELLATION_CUR;
        FETCH CANCELLATION_CUR INTO v_order_id, v_cancel_id, v_reason, v_time;
    CLOSE CANCELLATION_CUR;

    DBMS_OUTPUT.PUT_LINE('Original: ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-', 160, '-'));
    DBMS_OUTPUT.PUT_LINE('Order ID: ' || v_order_id);
    DBMS_OUTPUT.PUT_LINE('Cancel ID: ' || v_cancel_id);
    DBMS_OUTPUT.PUT_LINE('Reason: ' || v_reason);
    DBMS_OUTPUT.PUT_LINE('Cancellation Time: ' || TRUNC(to_timestamp(v_time,'DD/MM/RRRR HH24:MI:SSXFF')));
    
    IF IN_ACTION = 1 THEN
        BEGIN
            SELECT P.PAYMENTID INTO v_payment 
            FROM PAYMENT P
            INNER JOIN ORDERS O ON O.ORDERID = P.ORDERID
            WHERE O.ORDERID = UPPER(v_order_id);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_payment := NULL;
        END;

        IF v_payment IS NULL THEN
            SELECT MAX(CANCELID) INTO v_max_cancel_id FROM CANCELLATION;
            INSERT INTO CANCELLATION VALUES('CL' || TO_CHAR(TO_NUMBER(SUBSTR(v_max_cancel_id, 3)) + 1, 'FM000'),
            to_date(SYSDATE,'DD/MM/RRRR'), 
            to_timestamp(SYSDATE,'DD/MM/RRRR HH24:MI:SSXFF'), UPPER(IN_REASON));

            UPDATE ORDERS
            SET CANCELID = 'CL' || TO_CHAR(TO_NUMBER(SUBSTR(v_max_cancel_id, 3)) + 1, 'FM000')
            WHERE ORDERID = v_order_id;
        END IF;
    ELSE
        BEGIN
            SELECT C.CANCELID INTO v_cancel 
            FROM ORDERS O
            INNER JOIN CANCELLATION C ON O.CANCELID = C.CANCELID
            WHERE O.ORDERID = UPPER(v_order_id);

            UPDATE CANCELLATION
            SET REASON = UPPER(IN_REASON)
            WHERE CANCELID = UPPER(v_cancel_id);

            SELECT CANCELID, REASON, CANCELCREATIONTIME INTO v_cancel_id, v_reason, v_time
            FROM CANCELLATION
            WHERE CANCELID = UPPER(v_cancel_id);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('=============================');
                DBMS_OUTPUT.PUT_LINE('No Cancellation Made Before.');
                DBMS_OUTPUT.PUT_LINE('=============================');
        END;
    END IF;

    SELECT O.ORDERID, C.CANCELID, C.REASON, C.CANCELCREATIONTIME INTO v_order_id, v_cancel_id, v_reason, v_time
    FROM ORDERS O
    LEFT JOIN CANCELLATION C ON C.CANCELID = O.CANCELID
    WHERE UPPER(O.ORDERID) = UPPER(v_order_id);

    DBMS_OUTPUT.PUT_LINE(chr(10));
    DBMS_OUTPUT.PUT_LINE('Updated: ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-', 160, '-'));
    DBMS_OUTPUT.PUT_LINE('Order ID: ' || v_order_id);
    DBMS_OUTPUT.PUT_LINE('Cancel ID: ' || v_cancel_id);
    DBMS_OUTPUT.PUT_LINE('Reason: ' || v_reason);
    DBMS_OUTPUT.PUT_LINE('Cancellation Time: ' || TRUNC(to_timestamp(v_time,'DD/MM/RRRR HH24:MI:SSXFF')));
END;
/

EXEC CancellationManagement(&IN_ACTION, UPPER('&IN_ORDER_ID'), UPPER('&IN_REASON'));