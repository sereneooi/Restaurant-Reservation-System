SET LINESIZE 200
SET PAGESIZE 200

COLUMN "Reservation ID" FORMAT A15
COLUMN "Time" FORMAT A10
COLUMN "Table" FORMAT A10
COLUMN "Pax Num" FORMAT A7
COLUMN "Customer ID" FORMAT A15
COLUMN "Conctact No" FORMAT A20

TTITLE 'Reservation Availability Analysis (15/04/2023)' SKIP 2

WITH AllTimes (ReservationTime, MaxTime) AS (
    SELECT TO_DATE('15/04/2023 10:00:00', 'DD/MM/YYYY HH24:MI:SS') AS ReservationTime,
           TO_DATE('15/04/2023 22:00:00', 'DD/MM/YYYY HH24:MI:SS') AS MaxTime
    FROM DUAL
    UNION ALL
    SELECT ReservationTime + INTERVAL '60' MINUTE, MaxTime
    FROM AllTimes
    WHERE ReservationTime + INTERVAL '60' MINUTE <= MaxTime
)
SELECT
    TO_CHAR(AT.ReservationTime, 'HH24:MI') AS "Time",
    COALESCE(R.reservationId, '') AS "Reservation ID",
    COALESCE(RD.tableId, '') AS "Table ID",
    COALESCE(C.custId, '') AS "Customer ID",
    COALESCE(C.custContact, '') AS "Contact No",
    COALESCE(TO_CHAR(RD.paxNum), '') AS "Pax Num"
FROM AllTimes AT
LEFT JOIN ReservationDetails RD ON AT.ReservationTime = RD.reservationTime
LEFT JOIN Reservation R ON RD.reservationId = R.reservationId
LEFT JOIN Customer C ON R.custId = C.custId
WHERE TO_CHAR(AT.ReservationTime, 'HH24:MI') BETWEEN '10:00' AND '22:00'
ORDER BY AT.ReservationTime;


