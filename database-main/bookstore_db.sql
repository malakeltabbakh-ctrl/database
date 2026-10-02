-- ============================================================
--  BOOKSTORE DATABASE - Oracle SQL Implementation
--  Based on ERD and Relational Schema
-- ============================================================

-- Drop tables in reverse dependency order (if re-running)
DROP TABLE Book_Supplier   CASCADE CONSTRAINTS;
DROP TABLE Book_Operation  CASCADE CONSTRAINTS;
DROP TABLE Book_Author     CASCADE CONSTRAINTS;
DROP TABLE Book_Genre      CASCADE CONSTRAINTS;
DROP TABLE Operation       CASCADE CONSTRAINTS;
DROP TABLE Customer_Ph     CASCADE CONSTRAINTS;
DROP TABLE Customer        CASCADE CONSTRAINTS;
DROP TABLE Supplier_Ph     CASCADE CONSTRAINTS;
DROP TABLE Supplier        CASCADE CONSTRAINTS;
DROP TABLE Employee_Ph     CASCADE CONSTRAINTS;
DROP TABLE Employee        CASCADE CONSTRAINTS;
DROP TABLE Author          CASCADE CONSTRAINTS;
DROP TABLE Book            CASCADE CONSTRAINTS;

-- ============================================================
--  1. BOOK
-- ============================================================
CREATE TABLE Book (
    Book_ID    NUMBER         PRIMARY KEY,
    Title      VARCHAR2(200)  NOT NULL,
    Quantity   NUMBER         DEFAULT 0 CHECK (Quantity >= 0),
    Price      NUMBER(10,2)   CHECK (Price > 0)
);

-- ============================================================
--  2. BOOK_GENRE  (multi-valued attribute)
-- ============================================================
CREATE TABLE Book_Genre (
    Book_ID  NUMBER        NOT NULL,
    Genre    VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_book_genre PRIMARY KEY (Book_ID, Genre),
    CONSTRAINT fk_bg_book   FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID)
        ON DELETE CASCADE
);

-- ============================================================
--  3. AUTHOR
-- ============================================================
CREATE TABLE Author (
    Author_ID   NUMBER        PRIMARY KEY,
    Fname       VARCHAR2(100) NOT NULL,
    Lname       VARCHAR2(100),
    Nationality VARCHAR2(100),
    Gender      VARCHAR2(10)  CHECK (Gender IN ('Male','Female','Other'))
);

-- ============================================================
--  4. BOOK_AUTHOR  (M:N between Book and Author)
-- ============================================================
CREATE TABLE Book_Author (
    Book_ID   NUMBER NOT NULL,
    Author_ID NUMBER NOT NULL,
    CONSTRAINT pk_book_author  PRIMARY KEY (Book_ID, Author_ID),
    CONSTRAINT fk_ba_book      FOREIGN KEY (Book_ID)   REFERENCES Book(Book_ID)   ON DELETE CASCADE,
    CONSTRAINT fk_ba_author    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID) ON DELETE CASCADE
);

-- ============================================================
--  5. EMPLOYEE  (self-referencing for supervisor)
-- ============================================================
CREATE TABLE Employee (
    EmployeeID   NUMBER        PRIMARY KEY,
    Name         VARCHAR2(200) NOT NULL,
    Role         VARCHAR2(100),
    Salary       NUMBER(10,2)  CHECK (Salary >= 0),
    Gender       VARCHAR2(10)  CHECK (Gender IN ('Male','Female','Other')),
    BDate        DATE,
    Age          NUMBER        CHECK (Age > 0),
    Supervisor_ID NUMBER,
    CONSTRAINT fk_emp_supervisor FOREIGN KEY (Supervisor_ID) REFERENCES Employee(EmployeeID)
);

-- ============================================================
--  6. EMPLOYEE_PH  (multi-valued attribute)
-- ============================================================
CREATE TABLE Employee_Ph (
    Emp_ID  NUMBER        NOT NULL,
    Phone   VARCHAR2(20)  NOT NULL,
    CONSTRAINT pk_emp_ph  PRIMARY KEY (Emp_ID, Phone),
    CONSTRAINT fk_eph_emp FOREIGN KEY (Emp_ID) REFERENCES Employee(EmployeeID)
        ON DELETE CASCADE
);

-- ============================================================
--  7. CUSTOMER
-- ============================================================
CREATE TABLE Customer (
    Customer_ID NUMBER        PRIMARY KEY,
    Name        VARCHAR2(200) NOT NULL,
    BD          DATE,
    Email       VARCHAR2(200) UNIQUE,
    Age         NUMBER        CHECK (Age > 0)
);

-- ============================================================
--  8. CUSTOMER_PH  (multi-valued attribute)
-- ============================================================
CREATE TABLE Customer_Ph (
    Customer_ID NUMBER       NOT NULL,
    Phone       VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_cust_ph  PRIMARY KEY (Customer_ID, Phone),
    CONSTRAINT fk_cph_cust FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
        ON DELETE CASCADE
);

-- ============================================================
--  9. SUPPLIER
-- ============================================================
CREATE TABLE Supplier (
    Supplier_ID NUMBER        PRIMARY KEY,
    Name        VARCHAR2(200) NOT NULL
);

-- ============================================================
--  10. SUPPLIER_PH  (multi-valued attribute)
-- ============================================================
CREATE TABLE Supplier_Ph (
    Supp_ID NUMBER       NOT NULL,
    Phone   VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_supp_ph  PRIMARY KEY (Supp_ID, Phone),
    CONSTRAINT fk_sph_supp FOREIGN KEY (Supp_ID) REFERENCES Supplier(Supplier_ID)
        ON DELETE CASCADE
);

-- ============================================================
--  11. OPERATION  (transaction / sale / order)
-- ============================================================
CREATE TABLE Operation (
    Operation_ID NUMBER        PRIMARY KEY,
    Type         VARCHAR2(50)  CHECK (Type IN ('Sale','Return','Order')),
    Day          NUMBER(2)     CHECK (Day BETWEEN 1 AND 31),
    Month        NUMBER(2)     CHECK (Month BETWEEN 1 AND 12),
    Year         NUMBER(4),
    Totalprice   NUMBER(12,2)  CHECK (Totalprice >= 0),
    Payment      VARCHAR2(50),
    Emp_ID       NUMBER        NOT NULL,
    Customer_ID  NUMBER,
    Supplier_ID  NUMBER,
    CONSTRAINT fk_op_emp      FOREIGN KEY (Emp_ID)      REFERENCES Employee(EmployeeID),
    CONSTRAINT fk_op_cust     FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    CONSTRAINT fk_op_supp     FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID)
);

-- ============================================================
--  12. BOOK_OPERATION  (M:N – books included in an operation)
-- ============================================================
CREATE TABLE Book_Operation (
    Book_ID      NUMBER NOT NULL,
    Operation_ID NUMBER NOT NULL,
    CONSTRAINT pk_book_op   PRIMARY KEY (Book_ID, Operation_ID),
    CONSTRAINT fk_bop_book  FOREIGN KEY (Book_ID)      REFERENCES Book(Book_ID)      ON DELETE CASCADE,
    CONSTRAINT fk_bop_op    FOREIGN KEY (Operation_ID) REFERENCES Operation(Operation_ID) ON DELETE CASCADE
);

-- ============================================================
--  13. BOOK_SUPPLIER  (M:N – books supplied by a supplier)
-- ============================================================
CREATE TABLE Book_Supplier (
    Book_ID     NUMBER NOT NULL,
    Supplier_ID NUMBER NOT NULL,
    CONSTRAINT pk_book_supp  PRIMARY KEY (Book_ID, Supplier_ID),
    CONSTRAINT fk_bs_book    FOREIGN KEY (Book_ID)     REFERENCES Book(Book_ID)         ON DELETE CASCADE,
    CONSTRAINT fk_bs_supp    FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID) ON DELETE CASCADE
);


-- ============================================================
--  SAMPLE DATA
-- ============================================================

-- Books
INSERT INTO Book VALUES (1, 'The Great Gatsby',   50, 12.99);
INSERT INTO Book VALUES (2, 'To Kill a Mockingbird', 30, 9.99);
INSERT INTO Book VALUES (3, 'Clean Code',          20, 35.00);
INSERT INTO Book VALUES (4, '1984',                45, 11.50);

-- Book Genres
INSERT INTO Book_Genre VALUES (1, 'Fiction');
INSERT INTO Book_Genre VALUES (2, 'Fiction');
INSERT INTO Book_Genre VALUES (2, 'Drama');
INSERT INTO Book_Genre VALUES (3, 'Technology');
INSERT INTO Book_Genre VALUES (4, 'Dystopian');

-- Authors
INSERT INTO Author VALUES (1, 'F. Scott',  'Fitzgerald', 'American', 'Male');
INSERT INTO Author VALUES (2, 'Harper',    'Lee',        'American', 'Female');
INSERT INTO Author VALUES (3, 'Robert',    'Martin',     'American', 'Male');
INSERT INTO Author VALUES (4, 'George',    'Orwell',     'British',  'Male');

-- Book_Author
INSERT INTO Book_Author VALUES (1, 1);
INSERT INTO Book_Author VALUES (2, 2);
INSERT INTO Book_Author VALUES (3, 3);
INSERT INTO Book_Author VALUES (4, 4);

-- Employees (supervisor inserted first)
INSERT INTO Employee VALUES (1, 'Ahmed Hassan',   'Manager',    8000, 'Male',   DATE '1975-03-15', 49, NULL);
INSERT INTO Employee VALUES (2, 'Sara Ali',       'Cashier',    3500, 'Female', DATE '1995-07-22', 28, 1);
INSERT INTO Employee VALUES (3, 'Mohamed Kamal',  'Stockroom',  3000, 'Male',   DATE '1998-11-05', 25, 1);

-- Employee phones
INSERT INTO Employee_Ph VALUES (1, '0100-123-4567');
INSERT INTO Employee_Ph VALUES (2, '0111-987-6543');
INSERT INTO Employee_Ph VALUES (3, '0122-456-7890');

-- Customers
INSERT INTO Customer VALUES (1, 'Layla Ibrahim',  DATE '1992-05-10', 'layla@email.com',   31);
INSERT INTO Customer VALUES (2, 'Omar Sayed',     DATE '1988-09-30', 'omar@email.com',    35);
INSERT INTO Customer VALUES (3, 'Nour Mahmoud',   DATE '2000-01-14', 'nour@email.com',    24);

-- Customer phones
INSERT INTO Customer_Ph VALUES (1, '0100-111-2222');
INSERT INTO Customer_Ph VALUES (2, '0111-333-4444');
INSERT INTO Customer_Ph VALUES (3, '0122-555-6666');

-- Suppliers
INSERT INTO Supplier VALUES (1, 'Dar El Shorouk');
INSERT INTO Supplier VALUES (2, 'Al Ahram Publishing');

-- Supplier phones
INSERT INTO Supplier_Ph VALUES (1, '02-2555-0000');
INSERT INTO Supplier_Ph VALUES (2, '02-2777-1111');

-- Operations
INSERT INTO Operation VALUES (1, 'Sale',  8, 5, 2026, 22.98, 'Cash',  2, 1, NULL);
INSERT INTO Operation VALUES (2, 'Sale',  8, 5, 2026, 11.50, 'Card',  2, 2, NULL);
INSERT INTO Operation VALUES (3, 'Order', 7, 5, 2026, 350.00,'Transfer', 3, NULL, 1);

-- Book_Operation
INSERT INTO Book_Operation VALUES (1, 1);
INSERT INTO Book_Operation VALUES (2, 1);
INSERT INTO Book_Operation VALUES (4, 2);
INSERT INTO Book_Operation VALUES (1, 3);
INSERT INTO Book_Operation VALUES (3, 3);

-- Book_Supplier
INSERT INTO Book_Supplier VALUES (1, 1);
INSERT INTO Book_Supplier VALUES (2, 1);
INSERT INTO Book_Supplier VALUES (3, 2);
INSERT INTO Book_Supplier VALUES (4, 2);

COMMIT;


-- ============================================================
--  SAMPLE QUERIES
-- ============================================================

-- 1. All books with their genres
SELECT b.Title, bg.Genre
FROM Book b JOIN Book_Genre bg ON b.Book_ID = bg.Book_ID
ORDER BY b.Title;

-- 2. Books written by each author
SELECT a.Fname || ' ' || a.Lname AS Author, b.Title
FROM Author a
JOIN Book_Author ba ON a.Author_ID = ba.Author_ID
JOIN Book b         ON ba.Book_ID  = b.Book_ID;

-- 3. Total sales per customer
SELECT c.Name, SUM(o.Totalprice) AS TotalSpent
FROM Customer c
JOIN Operation o ON c.Customer_ID = o.Customer_ID
WHERE o.Type = 'Sale'
GROUP BY c.Name
ORDER BY TotalSpent DESC;

-- 4. Operations processed by each employee
SELECT e.Name AS Employee, COUNT(o.Operation_ID) AS NumOperations
FROM Employee e
JOIN Operation o ON e.EmployeeID = o.Emp_ID
GROUP BY e.Name;

-- 5. Books supplied by each supplier
SELECT s.Name AS Supplier, b.Title
FROM Supplier s
JOIN Book_Supplier bs ON s.Supplier_ID = bs.Supplier_ID
JOIN Book b           ON bs.Book_ID    = b.Book_ID;

-- 6. Employee and their supervisor
SELECT e.Name AS Employee, s.Name AS Supervisor
FROM Employee e
LEFT JOIN Employee s ON e.Supervisor_ID = s.EmployeeID;

-- 7. Low stock books (quantity < 25)
SELECT Title, Quantity FROM Book WHERE Quantity < 25 ORDER BY Quantity;
