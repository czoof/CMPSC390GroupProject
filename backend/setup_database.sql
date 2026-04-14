-- ============================================================
-- LEGACY AUTO CUSTOMIZATION - FULL DATABASE SETUP
-- Run this entire file in MySQL Workbench to set up everything.
-- This script resets the DB to a known good state.
-- ============================================================

DROP DATABASE IF EXISTS legautocustDB;
CREATE DATABASE legautocustDB;
USE legautocustDB;

-- ========================
-- CUSTOMER TABLES
-- ========================

CREATE TABLE `User` (
    UserID    INT NOT NULL AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName  VARCHAR(50) NOT NULL,
    Password  VARCHAR(50) NOT NULL,
    UserName  VARCHAR(50) NOT NULL,
    ZipCode   INT NOT NULL,
    Birthdate DATE NOT NULL,
    PRIMARY KEY (UserID),
    UNIQUE KEY uq_user_username (UserName)
);

CREATE TABLE Parts (
    PartID       INT NOT NULL,
    Name         VARCHAR(100),
    Stock        INT NOT NULL DEFAULT 0,
    Availability VARCHAR(30) NOT NULL DEFAULT 'Available',
    Category     VARCHAR(100),
    Image        VARCHAR(2048),
    Price        DECIMAL(10,2),
    PRIMARY KEY (PartID)
);

CREATE TABLE Customized_car (
    CarID       INT NOT NULL AUTO_INCREMENT,
    BaseCar     VARCHAR(100) NOT NULL,
    TotalPrice  DECIMAL(10,2) NOT NULL DEFAULT 0,
    PartID      INT NULL DEFAULT NULL,
    BuildStatus VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    UserID      INT NOT NULL,
    PRIMARY KEY (CarID),
    KEY idx_customized_car_user (UserID),
    KEY idx_customized_car_part (PartID),
    CONSTRAINT fk_customized_car_user
        FOREIGN KEY (UserID) REFERENCES `User`(UserID),
    CONSTRAINT fk_customized_car_part
        FOREIGN KEY (PartID) REFERENCES Parts(PartID)
);

CREATE TABLE Customized_car_parts (
    CarID   INT NOT NULL,
    PartID  INT NOT NULL,
    PRIMARY KEY (CarID, PartID),
    KEY idx_ccp_part (PartID),
    CONSTRAINT fk_ccp_car
        FOREIGN KEY (CarID) REFERENCES Customized_car(CarID) ON DELETE CASCADE,
    CONSTRAINT fk_ccp_part
        FOREIGN KEY (PartID) REFERENCES Parts(PartID)
);

CREATE TABLE partsreviews (
    PartReviewID INT NOT NULL AUTO_INCREMENT,
    PartID       INT NOT NULL,
    UserID       INT NULL,
    PartRating   INT NOT NULL,
    comment      TEXT,
    posted       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (PartReviewID),
    KEY idx_partsreviews_part (PartID),
    KEY idx_partsreviews_user (UserID),
    CONSTRAINT fk_partsreviews_part
        FOREIGN KEY (PartID) REFERENCES Parts(PartID),
    CONSTRAINT fk_partsreviews_user
        FOREIGN KEY (UserID) REFERENCES `User`(UserID)
);

-- ========================
-- TRADE TABLES
-- ========================

CREATE TABLE Trades (
    TradeID              INT NOT NULL AUTO_INCREMENT,
    OwnerUserID          INT NOT NULL,
    OfferedPartID        INT,
    DesiredMinPrice      DECIMAL(10,2),
    DesiredMaxPrice      DECIMAL(10,2),
    ConditionDescription TEXT,
    ImageURL             VARCHAR(2048),
    Status               VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    PRIMARY KEY (TradeID),
    KEY idx_trades_owner (OwnerUserID),
    CONSTRAINT fk_trades_owner
        FOREIGN KEY (OwnerUserID) REFERENCES `User`(UserID)
);

CREATE TABLE TradeOffers (
    OfferID                 INT NOT NULL AUTO_INCREMENT,
    TradeID                 INT NOT NULL,
    OfferingUserID          INT NOT NULL,
    OfferedPartDescription  TEXT,
    PRIMARY KEY (OfferID),
    KEY idx_tradeoffers_trade (TradeID),
    KEY idx_tradeoffers_user (OfferingUserID),
    CONSTRAINT fk_tradeoffers_trade
        FOREIGN KEY (TradeID) REFERENCES Trades(TradeID),
    CONSTRAINT fk_tradeoffers_user
        FOREIGN KEY (OfferingUserID) REFERENCES `User`(UserID)
);

-- ========================
-- DISCUSSION / FORUM TABLES
-- ========================

CREATE TABLE Discussions (
    DiscussionID INT NOT NULL AUTO_INCREMENT,
    UserID       INT NOT NULL,
    Title        VARCHAR(255) NOT NULL,
    Content      TEXT NOT NULL,
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (DiscussionID),
    KEY idx_discussions_user (UserID),
    CONSTRAINT fk_discussions_user
        FOREIGN KEY (UserID) REFERENCES `User`(UserID)
);

CREATE TABLE DiscussionReplies (
    ReplyID      INT NOT NULL AUTO_INCREMENT,
    DiscussionID INT NOT NULL,
    UserID       INT NOT NULL,
    Content      TEXT NOT NULL,
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ReplyID),
    KEY idx_replies_discussion (DiscussionID),
    KEY idx_replies_user (UserID),
    CONSTRAINT fk_replies_discussion
        FOREIGN KEY (DiscussionID) REFERENCES Discussions(DiscussionID) ON DELETE CASCADE,
    CONSTRAINT fk_replies_user
        FOREIGN KEY (UserID) REFERENCES `User`(UserID)
);

CREATE TABLE Bookmarks (
    BookmarkID   INT NOT NULL AUTO_INCREMENT,
    UserID       INT NOT NULL,
    DiscussionID INT NOT NULL,
    PRIMARY KEY (BookmarkID),
    UNIQUE KEY uq_bookmark (UserID, DiscussionID),
    KEY idx_bookmarks_user (UserID),
    KEY idx_bookmarks_discussion (DiscussionID),
    CONSTRAINT fk_bookmarks_user
        FOREIGN KEY (UserID) REFERENCES `User`(UserID),
    CONSTRAINT fk_bookmarks_discussion
        FOREIGN KEY (DiscussionID) REFERENCES Discussions(DiscussionID) ON DELETE CASCADE
);

-- ========================
-- EMPLOYEE TABLES
-- ========================

CREATE TABLE Employees (
    EmployeeID VARCHAR(4)   NOT NULL,
    FirstName  VARCHAR(25)  NOT NULL,
    LastName   VARCHAR(25)  NOT NULL,
    Management BOOLEAN      NOT NULL DEFAULT FALSE,
    HireDate   DATE         NOT NULL,
    Password   VARCHAR(50)  NOT NULL,
    HourlyPay  DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (EmployeeID)
);

CREATE TABLE EmployeeContactInfo (
    EmployeeID           VARCHAR(4) NOT NULL,
    PhoneNumber          VARCHAR(12),
    EmergencyPhoneNumber VARCHAR(12),
    Address              VARCHAR(100),
    PersonalEmail        VARCHAR(40),
    WorkEmail            VARCHAR(50),
    PRIMARY KEY (EmployeeID),
    CONSTRAINT fk_contactinfo_employee
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Schedule (
    ScheduleID VARCHAR(4) NOT NULL,
    EmployeeID VARCHAR(4) NOT NULL,
    MonthNum   INT NOT NULL DEFAULT 1,
    WeekNum    INT NOT NULL DEFAULT 1,
    Sun        BOOLEAN NOT NULL DEFAULT 0,
    Mon        BOOLEAN NOT NULL DEFAULT 0,
    Tue        BOOLEAN NOT NULL DEFAULT 0,
    Wed        BOOLEAN NOT NULL DEFAULT 0,
    Thu        BOOLEAN NOT NULL DEFAULT 0,
    Fri        BOOLEAN NOT NULL DEFAULT 0,
    Sat        BOOLEAN NOT NULL DEFAULT 0,
    PRIMARY KEY (ScheduleID),
    KEY idx_schedule_employee (EmployeeID),
    CONSTRAINT fk_schedule_employee
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE EmployeePerformance (
    PerformanceID    VARCHAR(4) NOT NULL,
    EmployeeID       VARCHAR(4) NOT NULL,
    ActivelyEmployed BOOLEAN NOT NULL DEFAULT TRUE,
    Points           INT NOT NULL DEFAULT 0,
    Comments         TEXT,
    PRIMARY KEY (PerformanceID),
    KEY idx_performance_employee (EmployeeID),
    CONSTRAINT fk_performance_employee
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE TimeOffRequests (
    RequestID   INT NOT NULL AUTO_INCREMENT,
    EmployeeID  VARCHAR(4) NOT NULL,
    MonthNum    INT NOT NULL,
    WeekNum     INT NOT NULL,
    DayOfWeek   VARCHAR(10) NOT NULL,
    Type        VARCHAR(10) NOT NULL DEFAULT 'off',
    Reason      TEXT,
    Status      VARCHAR(20) NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (RequestID),
    KEY idx_timeoff_employee (EmployeeID),
    CONSTRAINT fk_timeoff_employee
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- ========================
-- SAMPLE DATA: CUSTOMERS
-- ========================

INSERT INTO `User` (UserID, FirstName, LastName, Password, UserName, ZipCode, Birthdate)
VALUES
(1, 'Good', 'Mann', 'Manpas303', 'Goodman', 30314, '2000-02-12'),
(2, 'John', 'Smith', 'Johnpas303', 'JohnSmith', 60629, '1990-05-20');
-- ========================
-- SAMPLE DATA: PARTS
-- ========================

INSERT INTO Parts (PartID, Name, Stock, Availability, Category, Image, Price) VALUES
(800210234, 'Universal Performance Bushing',                  20, 'Available',    'suspension',    'https://dummyimage.com/900x600/111827/d1d5db.png&text=Performance+Bushing', 65.00),
(900810524, 'Graphite Gray Metallic Acrylic Urethane Paint',  2,  'Available',    'paint',         'https://dummyimage.com/900x600/334155/e2e8f0.png&text=Graphite+Paint', 180.99),
(800832124, 'Ryobi 10in Speed Random Orbit',                  0,  'Out of Stock', 'buffer',        'https://dummyimage.com/900x600/0f172a/93c5fd.png&text=Ryobi+Buffer', 59.97),
(300432111, 'Orange Forged Wheel 4-Piece',                    24, 'Available',    'wheel',         'https://dummyimage.com/900x600/7c2d12/fde68a.png&text=Orange+Forged+Wheel', 8000.99),
(200761731, '376 CI Whipple 3.0L Supercharged LS',            8,  'Available',    'engine',        'https://dummyimage.com/900x600/1f2937/ffffff.png&text=Whipple+3.0L+LS', 33225.00),
(400204631, 'The La Cucaracha Musical Horn',                  25, 'Available',    'horn',          'https://dummyimage.com/900x600/1e293b/f8fafc.png&text=La+Cucaracha+Horn', 49.99),
(500467921, 'American Thunder Axle-back Exhaust System',      0,  'Out of Stock', 'exhaust system','https://dummyimage.com/900x600/0b1324/e5e7eb.png&text=Thunder+Exhaust', 1500.95),
(900467921, 'Urethane Basecoat - Purple Metallic 1 Gallon',   43, 'Available',    'paint',         'https://dummyimage.com/900x600/4c1d95/e9d5ff.png&text=Purple+Metallic+Paint', 144.48),
(17277633, 'Muscle Base',                               9, 'Available', 'car',            'https://dummyimage.com/1280x720/0f172a/93c5fd.png&text=Muscle+Base',  32000.00),
(83451953, 'SUV Base',                                  7, 'Available', 'car',            'https://dummyimage.com/1280x720/111827/93c5fd.png&text=SUV+Base',     30000.00),
(93469582, 'Truck Base',                                6, 'Available', 'car',            'https://dummyimage.com/1280x720/1f2937/93c5fd.png&text=Truck+Base',   32000.00),
(22782485, 'Coupe Base',                                4, 'Available', 'car',            'https://dummyimage.com/1280x720/0b1220/93c5fd.png&text=Coupe+Base',   28000.00),
(26501480, 'White Paint',                              20, 'Available', 'paint',          '/Sprint4-Alberto/car-paints/white.png',                                 100.00),
(18066938, 'Black Paint',                              20, 'Available', 'paint',          '/Sprint4-Alberto/car-paints/black.png',                                 115.00),
(29367808, 'Neon Purple Paint',                        15, 'Available', 'paint',          '/Sprint4-Alberto/car-paints/purple.png',                                130.00),
(28056391, 'Neon Green Paint',                         15, 'Available', 'paint',          '/Sprint4-Alberto/car-paints/green.png',                                 145.00),
(85052968, 'Black Sport Rims',                         15, 'Available', 'rims',           '/Sprint4-Alberto/car-rims/blackSport.png',                             1200.00),
(82890043, 'Grey Sport Rims',                          15, 'Available', 'rims',           '/Sprint4-Alberto/car-rims/greySport.png',                              1200.00),
(99057491, 'Bronze Offroad Rims',                      10, 'Available', 'rims',           '/Sprint4-Alberto/car-rims/bronzeOffRoad.png',                          1500.00),
(1779980,  'Offroad Black Rims',                       10, 'Available', 'rims',           '/Sprint4-Alberto/car-rims/offRoadBlack.png',                           1400.00),
(27277633, '6.7 Cummins Engine',                        5, 'Available', 'engine',         'https://dummyimage.com/900x600/1f2937/ffffff.png&text=6.7+Cummins+Engine',     5995.00),
(13277633, '6.4 PowerStroke Engine',                    3, 'Available', 'engine',         'https://dummyimage.com/900x600/1f2937/ffffff.png&text=6.4+PowerStroke+Engine', 6795.00),
(17477633, '3.6 V6 Engine',                             7, 'Available', 'engine',         'https://dummyimage.com/900x600/1f2937/ffffff.png&text=3.6+V6+Engine',          2578.00),
(17257633, 'Spring Suspension',                         7, 'Available', 'suspension',     'https://dummyimage.com/900x600/111827/d1d5db.png&text=Spring+Suspension',      156.79),
(17276633, 'Cush Suspension',                           3, 'Available', 'suspension',     'https://dummyimage.com/900x600/111827/d1d5db.png&text=Cush+Suspension',        256.89),
(17277733, 'Air Suspension',                            8, 'Available', 'suspension',     'https://dummyimage.com/900x600/111827/d1d5db.png&text=Air+Suspension',         329.87),
(17277683, 'Stainless Steel Cat-Back Exhaust System',   3, 'Available', 'exhaust system', 'https://dummyimage.com/900x600/0b1324/e5e7eb.png&text=Stainless+Exhaust',       1800.00),
(17277639, 'AWE Tuning Track Cat-Back Exhaust System',  5, 'Available', 'exhaust system', 'https://dummyimage.com/900x600/0b1324/e5e7eb.png&text=AWE+Track+Exhaust',       3200.00),
(17277631, 'Dual Exit Cat-Back Exhaust System',         2, 'Available', 'exhaust system', 'https://dummyimage.com/900x600/0b1324/e5e7eb.png&text=Dual+Exit+Exhaust',       1400.00),
(17277623, 'HornBlasters The Godfather Musical Air Horn', 3, 'Available', 'horn',        'https://dummyimage.com/900x600/1e293b/f8fafc.png&text=Godfather+Horn',          35.00),
(17277333, 'HornBlasters Dixie Musical Horn',           5, 'Available', 'horn',           'https://dummyimage.com/900x600/1e293b/f8fafc.png&text=Dixie+Horn',              47.00),
(17274633, 'HornBlasters Shocker XL Train Horn',        9, 'Available', 'horn',           'https://dummyimage.com/900x600/1e293b/f8fafc.png&text=Shocker+XL+Horn',        459.00);

-- ========================
-- SAMPLE DATA: EMPLOYEES
-- ========================

INSERT INTO Employees (EmployeeID, FirstName, LastName, Management, HireDate, Password, HourlyPay) VALUES
('A001', 'Mike',        'Myers',    TRUE,  '2000-10-11', 'Password0001', 25.00),
('A002', 'Eddie',       'Murphy',   TRUE,  '2003-11-12', 'Password0002', 26.00),
('A003', 'Conrad',      'Vernon',   TRUE,  '2015-12-13', 'Password0003', 28.00),
('A004', 'Chris',       'Miller',   FALSE, '2008-10-17', 'Password0004', 21.00),
('A005', 'John',        'Lithgow',  FALSE, '2001-07-19', 'Password0005', 21.00),
('A006', 'Christopher', 'Knights',  FALSE, '2015-04-13', 'Password0006', 13.00),
('A007', 'Aron',        'Warner',   FALSE, '2001-10-11', 'Password0007', 19.00),
('A008', 'Cody',        'Cameron',  FALSE, '1999-03-12', 'Password0008',  8.00),
('A009', 'Jim',         'Cummings', FALSE, '2012-07-13', 'Password0009', 16.00),
('A00A', 'Vincent',     'Cassel',   FALSE, '2016-01-01', 'Password000A', 18.00);

INSERT INTO EmployeeContactInfo (EmployeeID, PhoneNumber, EmergencyPhoneNumber, Address, PersonalEmail, WorkEmail) VALUES
('A001', '708-589-1444', '708-896-1851', '5601 S Harlem Ave, Chicago, IL 60638',       'Mike.Myers@gmail.com',          'Mike.Myers.A001@legacyautoCo.org'),
('A002', '773-421-5532', '312-774-1203', '3924 S Archer Ave, Chicago, IL 60632',       'eddie.murphy@yahoo.com',        'Eddie.Murphy.A002@legacyautoCo.org'),
('A003', '312-774-9982', '708-225-7712', '3225 W 47th Pl, Chicago, IL 60632',          'conrad.vernon@gmail.com',       'Conrad.Vernon.A003@legacyautoCo.org'),
('A004', '708-334-7812', '773-554-8821', '6928 S Pulaski Rd, Chicago, IL 60629',       'chris.miller@gmail.com',        'Chris.Miller.A004@legacyautoCo.org'),
('A005', '312-665-4410', '773-775-3321', '2906-08 W 63rd St, Chicago, IL 60629',       'john.lithgow@gmail.com',        'John.Lithgow.A005@legacyautoCo.org'),
('A006', '708-771-4420', '708-998-3210', '1406 W 47th St, Chicago, IL 60609',          'christopher.knights@gmail.com', 'Christopher.Knights.A006@legacyautoCo.org'),
('A007', '773-551-8922', '312-992-5511', '2849 W 95th St, Evergreen Park, IL 60805',   'aron.warner@gmail.com',         'Aron.Warner.A007@legacyautoCo.org'),
('A008', '312-441-2201', '773-445-6654', '11708 S Marshfield Ave, Chicago, IL 60643',  'cody.cameron@gmail.com',        'Cody.Cameron.A008@legacyautoCo.org'),
('A009', '773-228-3321', '708-443-2211', '7929 S Harlem Ave, Burbank, IL 60459',       'jim.cummings@gmail.com',        'Jim.Cummings.A009@legacyautoCo.org'),
('A00A', '312-558-4412', '773-221-4410', '8849 S Stony Island Ave, Chicago, IL 60617', 'vincent.cassel@gmail.com',      'Vincent.Cassel.A00A@legacyautoCo.org');

INSERT INTO Schedule (ScheduleID, EmployeeID, MonthNum, WeekNum, Sun, Mon, Tue, Wed, Thu, Fri, Sat) VALUES
('AA01','A001',1,1,0,1,1,1,1,1,0),('AA02','A001',1,2,0,1,1,1,1,1,0),('AA03','A001',1,3,0,1,1,1,1,1,0),('AA04','A001',1,4,0,1,1,1,1,1,0),('AA05','A001',1,5,0,1,1,1,1,1,0),
('AB01','A002',1,1,0,0,1,1,1,1,1),('AB02','A002',1,2,0,0,1,1,1,1,1),('AB03','A002',1,3,0,0,1,1,1,1,1),('AB04','A002',1,4,0,0,1,1,1,1,1),('AB05','A002',1,5,0,0,1,1,1,1,1),
('AC01','A003',1,1,1,1,0,0,1,1,1),('AC02','A003',1,2,1,1,0,0,1,1,1),('AC03','A003',1,3,1,1,0,0,1,1,1),('AC04','A003',1,4,1,1,0,0,1,1,1),('AC05','A003',1,5,1,1,0,0,1,1,1),
('AD01','A004',1,1,1,0,1,1,0,1,0),('AD02','A004',1,2,0,1,0,1,1,0,1),('AD03','A004',1,3,1,1,1,0,0,1,0),('AD04','A004',1,4,0,0,1,1,1,0,1),('AD05','A004',1,5,1,1,0,1,0,1,0),
('AE01','A005',1,1,0,1,1,0,1,0,1),('AE02','A005',1,2,1,0,1,1,0,1,0),('AE03','A005',1,3,0,1,0,1,1,1,0),('AE04','A005',1,4,1,1,0,0,1,0,1),('AE05','A005',1,5,0,0,1,1,1,1,0),
('AF01','A006',1,1,1,0,1,0,1,1,0),('AF02','A006',1,2,0,1,1,1,0,0,1),('AF03','A006',1,3,1,1,0,1,1,0,0),('AF04','A006',1,4,0,0,1,1,0,1,1),('AF05','A006',1,5,1,1,1,0,1,0,0),
('AG01','A007',1,1,0,1,0,1,1,1,0),('AG02','A007',1,2,1,0,1,1,0,1,0),('AG03','A007',1,3,0,1,1,0,1,0,1),('AG04','A007',1,4,1,1,0,1,0,1,0),('AG05','A007',1,5,0,0,1,1,1,0,1),
('AH01','A008',1,1,1,0,0,1,1,1,0),('AH02','A008',1,2,0,1,1,0,1,0,1),('AH03','A008',1,3,1,1,0,1,0,1,0),('AH04','A008',1,4,0,0,1,1,1,0,1),('AH05','A008',1,5,1,1,1,0,0,1,0),
('AI01','A009',1,1,0,1,1,0,1,1,0),('AI02','A009',1,2,1,0,1,1,0,0,1),('AI03','A009',1,3,0,1,0,1,1,1,0),('AI04','A009',1,4,1,1,1,0,0,1,0),('AI05','A009',1,5,0,0,1,1,1,0,1),
('AJ01','A00A',1,1,1,0,1,1,0,1,0),('AJ02','A00A',1,2,0,1,1,0,1,0,1),('AJ03','A00A',1,3,1,1,0,1,0,1,0),('AJ04','A00A',1,4,0,0,1,1,1,0,1),('AJ05','A00A',1,5,1,1,1,0,0,1,0);

/* This inserts 1 into everyone's schedule for months 2-6 */
INSERT INTO Schedule (ScheduleID, EmployeeID, MonthNum, WeekNum, Sun, Mon, Tue, Wed, Thu, Fri, Sat)
SELECT
    CONCAT(prefix, month, week) AS ScheduleID,
    empID,
    month AS MonthNum,
    week AS WeekNum,
    1, 1, 1, 1, 1, 1, 1
FROM (
    SELECT 'AA' AS prefix, 'A001' AS empID UNION
    SELECT 'AB', 'A002' UNION
    SELECT 'AC', 'A003' UNION
    SELECT 'AD', 'A004' UNION
    SELECT 'AE', 'A005' UNION
    SELECT 'AF', 'A006' UNION
    SELECT 'AG', 'A007' UNION
    SELECT 'AH', 'A008' UNION
    SELECT 'AI', 'A009' UNION
    SELECT 'AJ', 'A00A'
) employees
CROSS JOIN (
    SELECT 2 AS month UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
) months
CROSS JOIN (
    SELECT 1 AS week UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
) weeks;

INSERT INTO EmployeePerformance (PerformanceID, EmployeeID, ActivelyEmployed, Points, Comments) VALUES
('BA01','A001', TRUE,  0,  'Great Employee'),
('BA02','A002', TRUE,  1,  'Efficient'),
('BA03','A003', TRUE,  1,  'Next in line'),
('BA04','A004', FALSE, 10, 'Do Not Rehire'),
('BA05','A005', TRUE,  2,  'Great Employee'),
('BA06','A006', TRUE,  5,  'Attendance Issues'),
('BA07','A007', TRUE,  4,  'Hard Worker'),
('BA08','A008', TRUE,  1,  'Efficient'),
('BA09','A009', TRUE,  1,  'Fast Worker'),
('BA0A','A00A', FALSE, 10, 'Do Not Rehire');

-- ========================
-- VERIFY
-- ========================

SHOW TABLES;
SELECT COUNT(*) AS UserCount FROM `User`;
SELECT COUNT(*) AS PartCount FROM Parts;
SELECT COUNT(*) AS EmpCount FROM Employees;
SELECT COUNT(*) AS CarCount FROM Customized_car;
SELECT COUNT(*) AS CarPartsCount FROM Customized_car_parts;
SELECT COUNT(*) AS ReviewCount FROM partsreviews;
SELECT COUNT(*) AS DiscussionCount FROM Discussions;
SELECT COUNT(*) AS ReplyCount FROM DiscussionReplies;
SELECT COUNT(*) AS BookmarkCount FROM Bookmarks;
SELECT * FROM `User`;