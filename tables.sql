DROP TABLE ReservationDetails;
DROP TABLE Reservation;
DROP TABLE Tables;
DROP TABLE Rating;
DROP TABLE OrderDetails;
DROP TABLE Payment;
DROP TABLE Orders;
DROP TABLE SetMenuDetails;
DROP TABLE SetMenu;
DROP TABLE IngredientItem;
DROP TABLE MenuItem;
DROP TABLE Coupon;
DROP TABLE Customer;
DROP TABLE Membership;
DROP TABLE Staff;
DROP TABLE Delivery;
DROP TABLE DeliveryCompany;
DROP TABLE Cancellation;
DROP TABLE Ingredient;
DROP TABLE Supplier;

CREATE TABLE Supplier (
    supplierId      VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (supplierId, '[A-Z]{2}[0-9]{3}')),
    supplierName    VARCHAR(50) NOT NULL CHECK (supplierName NOT LIKE '%[^A-Z]%'),
    PRIMARY KEY (supplierId)
);

CREATE TABLE Ingredient (
    ingredientId    VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (ingredientId, '[A-Z]{2}[0-9]{3}')),
    ingredientName  VARCHAR(50) NOT NULL, 
    ingredientQty   NUMBER(4)   NOT NULL CHECK (ingredientQty > 0),
    price           NUMBER(8,2) NOT NULL CHECK (price >= 0),
    supplierId      VARCHAR(5),
    PRIMARY KEY (ingredientId),
    FOREIGN KEY (supplierId) REFERENCES Supplier (supplierId)
);

CREATE TABLE Cancellation (
    cancelId            VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (cancelId, '[A-Z]{2}[0-9]{3}')),
    cancelCreationDate  DATE        DEFAULT CURRENT_DATE NOT NULL,
    cancelCreationTime  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    reason              VARCHAR(50) NOT NULL CHECK (upper(reason) = 'WEATHER CONDITIONS' OR upper(reason) = 'MODIFY ORDER' or upper(reason) = 'PRICE'),
    PRIMARY KEY (cancelId)
);

CREATE TABLE DeliveryCompany (
    companyId       VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (companyId, '[A-Z]{2}[0-9]{3}')),
    companyName     VARCHAR(50) NOT NULL,
    PRIMARY KEY (companyId)
);

CREATE TABLE Delivery (
    deliveryId      VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (deliveryId, '[A-Z]{2}[0-9]{3}')),
    driverName      VARCHAR(50) CHECK (driverName NOT LIKE '%[^A-Z]%'),
    deliveryTime    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    deliveryAddress VARCHAR(100) NOT NULL,
    companyId       VARCHAR(5),
    PRIMARY KEY (deliveryId),
    FOREIGN KEY (companyId) REFERENCES DeliveryCompany (companyId)
);

CREATE TABLE Staff(
    staffId       VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (staffId, '[A-Z]{2}[0-9]{3}')),
    staffName     VARCHAR(50) NOT NULL CHECK (staffName NOT LIKE '%[^A-Z]%'),
    email         VARCHAR(50) CHECK (email like '%_@__%.__%'),
    staffContact  VARCHAR(11) CHECK (staffContact not like '%[^0-9]%'), 
    jobTitle      VARCHAR(50) NOT NULL, 
    PRIMARY KEY(staffId)
);

CREATE TABLE Membership (
    memberId      VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (memberId, '[A-Z]{2}[0-9]{3}')),
    memberType    VARCHAR(50) DEFAULT 'BASIC' NOT NULL CHECK (upper(memberType) = 'BASIC' or upper(memberType) = 'STANDARD' or upper(memberType) = 'PREMIUM'),
    memberPoint   NUMBER(5)   DEFAULT 0 NOT NULL CHECK (memberPoint >= 0),
    PRIMARY KEY (memberId)
);

CREATE TABLE Customer (
    custId        VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (custId, '[A-Z]{2}[0-9]{3}')),
    custName      VARCHAR(50) NOT NULL CHECK (custName NOT LIKE '%[^A-Z]%'),
    custEmail     VARCHAR(50) CHECK (custEmail like '%_@__%.__%'),
    custContact   VARCHAR(11) NOT NULL CHECK (custContact not like '%[^0-9]%'),
    gender        CHAR        CHECK (upper(gender) = 'F' or upper(gender) = 'M'),
    address       VARCHAR(100) NOT NULL,
    memberId      VARCHAR(5)  CHECK (REGEXP_LIKE (memberId, '[A-Z]{2}[0-9]{3}')),
    PRIMARY KEY (custId),
    FOREIGN KEY (memberId) REFERENCES Membership (memberId)
);

CREATE TABLE Coupon(
    couponCode          VARCHAR(5)  NOT NULL,
    discount            NUMBER(3,2) NOT NULL,
    codeAvailability    CHAR        DEFAULT 'Y' NOT NULL CHECK (upper(codeAvailability) = 'Y' or upper(codeAvailability) = 'N'),
    description         VARCHAR(50),
    PRIMARY KEY(couponCode)
);

CREATE TABLE MenuItem (
    itemId    VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (itemId, '[A-Z]{2}[0-9]{3}')),
    itemName  VARCHAR(50) NOT NULL,
    price     NUMBER(5,2) NOT NULL CHECK (price > 0),
    PRIMARY KEY (itemId)
);

CREATE TABLE IngredientItem (
    ingredientItemId VARCHAR(5) NOT NULL CHECK (REGEXP_LIKE (ingredientItemId, '[A-Z]{2}[0-9]{3}')),
    ingredientId     VARCHAR(5) NOT NULL CHECK (REGEXP_LIKE (ingredientId, '[A-Z]{2}[0-9]{3}')),
    itemId           VARCHAR(5) NOT NULL CHECK (REGEXP_LIKE (itemId, '[A-Z]{2}[0-9]{3}')),
    PRIMARY KEY (ingredientItemId),
    FOREIGN KEY (itemId) REFERENCES MenuItem (itemId),
    FOREIGN KEY (ingredientId) REFERENCES Ingredient (ingredientId)
);

CREATE TABLE SetMenu (
    setId   VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (setId, '[A-Z]{2}[0-9]{3}')),
    setName VARCHAR(50) NOT NULL,
    price   NUMBER(5,2) NOT NULL CHECK (price > 0),
    PRIMARY KEY (setId)
);

CREATE TABLE SetMenuDetails (
    setId   VARCHAR(5) NOT NULL CHECK (REGEXP_LIKE (setId, '[A-Z]{2}[0-9]{3}')),
    itemId  VARCHAR(5) NOT NULL CHECK (REGEXP_LIKE (itemId, '[A-Z]{2}[0-9]{3}')),
    PRIMARY KEY (setId, itemId),
    FOREIGN KEY (itemId) REFERENCES MenuItem (itemId),
    FOREIGN KEY (setId) REFERENCES SetMenu (setId)
);

CREATE TABLE Orders (
    orderId            VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (orderId, '[A-Z]{2}[0-9]{3}')),
    orderCreationDate  DATE        DEFAULT CURRENT_DATE NOT NULL,
    orderCreationTime  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    orderStatus        VARCHAR(20) NOT NULL,
    totalAmount        NUMBER(8,2) CHECK (totalAmount > 0),
    custId             VARCHAR(5)  CHECK (REGEXP_LIKE (custId, '[A-Z]{2}[0-9]{3}')),
    staffId            VARCHAR(5)  CHECK (REGEXP_LIKE (staffId, '[A-Z]{2}[0-9]{3}')),
    deliveryId         VARCHAR(5)  CHECK (REGEXP_LIKE (deliveryId, '[A-Z]{2}[0-9]{3}')),
    couponCode         VARCHAR(5),
    cancelId           VARCHAR(5)  CHECK (REGEXP_LIKE (cancelId, '[A-Z]{2}[0-9]{3}')),       
    PRIMARY KEY (orderId),
    FOREIGN KEY (custId) REFERENCES Customer (custId),
    FOREIGN KEY (staffId) REFERENCES Staff (staffId),
    FOREIGN KEY (deliveryId) REFERENCES Delivery (deliveryId),
    FOREIGN KEY (couponCode) REFERENCES Coupon (couponCode),
    FOREIGN KEY (cancelId) REFERENCES Cancellation (cancelId)
);

CREATE TABLE Payment(
    paymentId        VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (paymentId, '[A-Z]{2}[0-9]{3}')),
    paymentDate      DATE        DEFAULT CURRENT_DATE NOT NULL,
    paymentTime      TIMESTAMP   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    paymentMethod    VARCHAR(30) DEFAULT 'DEBIT CARD' CHECK (upper(paymentMethod) = 'DEBIT CARD' or upper(paymentMethod) = 'ONLINE BANKING') NOT NULL, 
    orderId          VARCHAR(5)  NOT NULL,
    PRIMARY KEY(paymentId),
    FOREIGN KEY(orderId) REFERENCES Orders (orderId)
);

CREATE TABLE OrderDetails (
    orderItemId VARCHAR(5) NOT NULL CHECK (REGEXP_LIKE (orderItemId, '[A-Z]{2}[0-9]{3}')),
    itemQty     NUMBER(3)  NOT NULL CHECK (itemQty > 0),
    orderId     VARCHAR(5) CHECK (REGEXP_LIKE (orderId, '[A-Z]{2}[0-9]{3}')),
    itemId      VARCHAR(5) CHECK (REGEXP_LIKE (itemId, '[A-Z]{2}[0-9]{3}')),
    setId       VARCHAR(5) CHECK (REGEXP_LIKE (setId, '[A-Z]{2}[0-9]{3}')),
    subtotal    NUMBER(8,2) NOT NULL,
    PRIMARY KEY (orderItemId),
    FOREIGN KEY (orderId) REFERENCES Orders (orderId),
    FOREIGN KEY (itemId) REFERENCES MenuItem (itemId),
    FOREIGN KEY (setId) REFERENCES SetMenu (setId)
);

CREATE TABLE Rating (
    ratingId    VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (ratingId, '[A-Z]{2}[0-9]{3}')),
    rating      NUMBER(1)   DEFAULT 5 NOT NULL CHECK (rating >= 1 and rating <= 5),
    orderId     VARCHAR(5)  CHECK (REGEXP_LIKE (orderId, '[A-Z]{2}[0-9]{3}')),
    PRIMARY KEY (ratingId),
    FOREIGN KEY (orderId) REFERENCES Orders (orderId)
);

CREATE TABLE Tables (
    tableId         VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (tableId, '[A-Z]{2}[0-9]{3}')),
    tableName       VARCHAR(3)  NOT NULL,
    tableSize       NUMBER(2)   NOT NULL CHECK (tableSize > 4 and tableSize <= 10),
    availability    CHAR        NOT NULL CHECK (upper(availability) = 'Y' or upper(availability) = 'N'),
    orderId         VARCHAR(5)  CHECK (REGEXP_LIKE (orderId, '[A-Z]{2}[0-9]{3}')),
    PRIMARY KEY (tableId),
    FOREIGN KEY (orderId) REFERENCES Orders (orderId)
);

CREATE TABLE Reservation (
    reservationId            VARCHAR(5)     NOT NULL CHECK (REGEXP_LIKE (reservationId, '[A-Z]{2}[0-9]{3}')),
    reservationCreationDate  DATE           DEFAULT CURRENT_DATE NOT NULL,
    reservationCreationTime  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status                   VARCHAR(20)    NOT NULL,
    custId                   VARCHAR(5)     CHECK (REGEXP_LIKE (custId, '[A-Z]{2}[0-9]{3}')),
    PRIMARY KEY (reservationId),
    FOREIGN KEY (custId) REFERENCES Customer (custId)
);

CREATE TABLE ReservationDetails (
    reservationId           VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (reservationId, '[A-Z]{2}[0-9]{3}')),
    tableId                 VARCHAR(5)  NOT NULL CHECK (REGEXP_LIKE (tableId, '[A-Z]{2}[0-9]{3}')),
    reservationDate         DATE        DEFAULT CURRENT_DATE NOT NULL,
    reservationTime        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    paxNum                  NUMBER(3)   CHECK (paxNum > 0),
    PRIMARY KEY (reservationId, tableId),
    FOREIGN KEY (reservationId) REFERENCES Reservation (reservationId),
    FOREIGN KEY (tableId) REFERENCES Tables (tableId)
);