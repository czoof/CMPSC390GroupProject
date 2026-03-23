-- ============================================================
-- LEGACY AUTO CUSTOMIZATION - FULL DATABASE SETUP
-- Run this entire file in MySQL Workbench to set up everything.
-- ============================================================

DROP DATABASE IF EXISTS legautocustDB;
CREATE DATABASE legautocustDB;
USE legautocustDB;

-- ========================
-- CUSTOMER TABLES
-- ========================

CREATE TABLE IF NOT EXISTS `User` (
    UserID    INT NOT NULL AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName  VARCHAR(50) NOT NULL,
    Password  VARCHAR(50) NOT NULL,
    UserName  VARCHAR(50) NOT NULL,
    ZipCode   INT NOT NULL,
    Birthdate DATE NOT NULL,
    PRIMARY KEY (UserID),
    UNIQUE (UserName)
);

CREATE TABLE IF NOT EXISTS Parts (
    PartID   INT NOT NULL,
    Name     VARCHAR(50),
    Stock    INT NOT NULL DEFAULT 0,
    Category VARCHAR(100),
    Image    VARCHAR(2048),
    Price    DECIMAL(10,2),
    PRIMARY KEY (PartID)
);

CREATE TABLE IF NOT EXISTS Customized_car (
    CarID      INT NOT NULL AUTO_INCREMENT,
    BaseCar    VARCHAR(50) NOT NULL,
    TotalPrice INT NOT NULL DEFAULT 0,
    PartID     INT,
    UserID     INT NOT NULL,
    PRIMARY KEY (CarID),
    FOREIGN KEY (UserID) REFERENCES `User`(UserID)
);

-- ========================
-- TRADE TABLES
-- ========================

CREATE TABLE IF NOT EXISTS Trades (
    TradeID              INT NOT NULL AUTO_INCREMENT,
    OwnerUserID          INT NOT NULL,
    OfferedPartID        INT,
    DesiredMinPrice      DECIMAL(10,2),
    DesiredMaxPrice      DECIMAL(10,2),
    ConditionDescription TEXT,
    ImageURL             VARCHAR(2048),
    Status               VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    PRIMARY KEY (TradeID),
    FOREIGN KEY (OwnerUserID) REFERENCES `User`(UserID)
);

CREATE TABLE IF NOT EXISTS TradeOffers (
    OfferID              INT NOT NULL AUTO_INCREMENT,
    TradeID              INT NOT NULL,
    OfferingUserID       INT NOT NULL,
    OfferedPartDescription TEXT,
    PRIMARY KEY (OfferID),
    FOREIGN KEY (TradeID) REFERENCES Trades(TradeID),
    FOREIGN KEY (OfferingUserID) REFERENCES `User`(UserID)
);

-- ========================
-- EMPLOYEE TABLES
-- ========================

CREATE TABLE IF NOT EXISTS Employees (
    EmployeeID VARCHAR(4)    PRIMARY KEY,
    FirstName  VARCHAR(25)   NOT NULL,
    LastName   VARCHAR(25)   NOT NULL,
    Management BOOLEAN       NOT NULL DEFAULT FALSE,
    HireDate   DATE          NOT NULL,
    Password   VARCHAR(50)   NOT NULL,
    HourlyPay  DECIMAL(5,2)  NOT NULL
);

CREATE TABLE IF NOT EXISTS EmployeeContactInfo (
    EmployeeID           VARCHAR(4) PRIMARY KEY,
    PhoneNumber          VARCHAR(12),
    EmergencyPhoneNumber VARCHAR(12),
    Address              VARCHAR(100),
    PersonalEmail        VARCHAR(40),
    WorkEmail            VARCHAR(50),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE IF NOT EXISTS Schedule (
    ScheduleID VARCHAR(4) PRIMARY KEY,
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
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE IF NOT EXISTS EmployeePerformance (
    PerformanceID    VARCHAR(4) PRIMARY KEY,
    EmployeeID       VARCHAR(4) NOT NULL,
    ActivelyEmployed BOOLEAN NOT NULL DEFAULT TRUE,
    Points           INT NOT NULL DEFAULT 0,
    Comments         TEXT,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE IF NOT EXISTS TimeOffRequests (
    RequestID  INT NOT NULL AUTO_INCREMENT,
    EmployeeID VARCHAR(4) NOT NULL,
    MonthNum   INT NOT NULL,
    WeekNum    INT NOT NULL,
    DayOfWeek  VARCHAR(10) NOT NULL,
    Reason     TEXT,
    Status     VARCHAR(20) NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (RequestID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- ========================
-- SAMPLE DATA: CUSTOMERS
-- ========================

INSERT INTO `User` (UserID, FirstName, LastName, Password, UserName, ZipCode, Birthdate)
VALUES (1, 'Good', 'Mann', 'Manpas303', 'Goodman', 30314, '2000-02-12');

-- ========================
-- SAMPLE DATA: PARTS
-- ========================

INSERT INTO Parts (PartID, Name, Stock, Category, Image, Price) VALUES
(800210234, 'Buffer 10 in amp 7',                          12, 'buffer',        'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcREb9KrzrUBrarmKe36HkxUStzTokDziBI6_Vo-Y3EDaZVqmzo4NscDLc0zGASRjWCKdNZnMXoV3vIK5dKzzuQ5z4NkKseobWqX5aswUV79I5UcdT5EOfwQ', 65.00),
(900810524, 'Graphite Gray Metallic Acrylic Urethane Paint', 2,  'paint',         'https://m.media-amazon.com/images/I/811WKwRAdcL._AC_UF894,1000_QL80_.jpg', 180.99),
(800832124, 'Ryobi 10in Speed Random Orbit',                0,  'buffer',        'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcTQ5MXYItCWT7NJX_TNpFyaFTE_vrFNDp_gFeROtZH-rT0VIZAeBrNxBVoBPi-W5fSwja7jzlPM10qNpIqklTlsbDxoM2q9RDrhzkqTVkewLu3ZVFjCYUJufPE', 59.97),
(300432111, 'Orange Forged Wheel 4-Piece',                  24, 'wheel',         'https://rvrnwheel.com/cdn/shop/files/T081-1937-chevy-coupe-business-wheels-custom-aftermarket-deep-dish-vintage-rims-orange-black-rvrn-forged_2.jpg?v=1740469662', 8000.99),
(200761731, '376 CI Whipple 3.0L Supercharged LS',          8,  'engine',        'https://www.wegnerautomotive.com/assets/Product-Featured-Images/Angle-1-sm-no-VC.png', 33225.00),
(400204631, 'The La Cucaracha Musical Horn',                25, 'horn',          'https://hornblasters.com/cdn/shop/files/NEW-LA-CUCARACHA.jpg?v=1762199157&width=1800', 49.99),
(500467921, 'American Thunder Axle-back Exhaust System',    0,  'exhaust system','https://images.flowmastermufflers.com/583x/1eed06e7ef0232847de4e0989b3c88bc96c2adb5.jpg', 1500.95),
(900467921, 'Urethane Basecoat - Purple Metallic 1 Gallon', 43, 'paint',         'https://paintforcars.com/wp-content/uploads/2018/10/Purple-Metallic-Auto-Paint-5-570x572-1.jpg', 144.48);

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
SELECT COUNT(*) AS UserCount   FROM `User`;
SELECT COUNT(*) AS PartCount   FROM Parts;
SELECT COUNT(*) AS EmpCount    FROM Employees;
