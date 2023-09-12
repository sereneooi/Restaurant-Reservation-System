SET LINESIZE 200
SET PAGESIZE 200

COLUMN "No" FORMAT 999 
COLUMN "Set ID" FORMAT A6
COLUMN "Set Name" FORMAT A30
COLUMN "Item" FORMAT A130
COLUMN "Rated By" FORMAT 9

TTITLE CENTER 'Top 10 Set Menu Selections Based on Customer Ratings' SKIP 1

SELECT 
    RN AS "No", "Set ID", "Set Name", "Item", "Average Rating", "Rated By"
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY "Average Rating" DESC) AS RN, "Set ID", "Set Name", "Average Rating", "Rated By", "Item"
    FROM (
        SELECT
            SM.setId AS "Set ID",
            SM.setname AS "Set Name",
            AVG(R.RATING) AS "Average Rating",
            COUNT(DISTINCT R.ratingId) AS "Rated By", -- get only the unique rating id 
            LISTAGG(MI.itemName, ', ') WITHIN GROUP (ORDER BY MI.itemName) AS "Item"
        FROM Orders O
        INNER JOIN Rating R ON R.orderId = O.orderId
        INNER JOIN OrderDetails OD ON OD.orderId = O.orderId
        INNER JOIN SetMenu SM ON SM.setId = OD.setId
        INNER JOIN SetMenuDetails SD ON SM.setId = SD.setId
        INNER JOIN MenuItem MI ON MI.itemId = SD.itemId
        GROUP BY SM.setId, SM.setname
    )
    WHERE ROWNUM <= 10
);


