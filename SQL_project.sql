CREATE DATABASE CarRentalDB;
GO

USE CarRentalDB;
GO
-- Tabela Klienci
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    DateOfBirth DATE
);

-- Tabela Samochody
CREATE TABLE Cars (
    CarID INT PRIMARY KEY IDENTITY(1,1),
    Make NVARCHAR(50),
    Model NVARCHAR(50),
    Year INT,
    LicensePlate NVARCHAR(15),
    DailyRate DECIMAL(10, 2),
    Status NVARCHAR(20) -- Dostępny, Wypożyczony, Serwis
);

-- Tabela Wypożyczenia
CREATE TABLE Rentals (
    RentalID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CarID INT FOREIGN KEY REFERENCES Cars(CarID),
    RentalDate DATE,
    ReturnDate DATE,
    TotalAmount DECIMAL(10, 2)
);

-- Tabela Płatności
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    RentalID INT FOREIGN KEY REFERENCES Rentals(RentalID),
    PaymentDate DATE,
    Amount DECIMAL(10, 2),
    PaymentMethod NVARCHAR(50) -- Karta, Przelew, Gotówka
);

-- Dodawanie klientów
INSERT INTO Customers (FirstName, LastName, Email, PhoneNumber, DateOfBirth)
VALUES 
('Jan', 'Kowalski', 'jan.kowalski@example.com', '123456789', '1985-05-15'),
('Anna', 'Nowak', 'anna.nowak@example.com', '987654321', '1990-11-25');

-- Dodawanie samochodów
INSERT INTO Cars (Make, Model, Year, LicensePlate, DailyRate, Status)
VALUES 
('Toyota', 'Corolla', 2020, 'WI1234A', 120.00, 'Dostępny'),
('Ford', 'Focus', 2018, 'KR5678B', 100.00, 'Dostępny');

-- Dodawanie wypożyczeń
INSERT INTO Rentals (CustomerID, CarID, RentalDate, ReturnDate, TotalAmount)
VALUES 
(1, 1, '2024-08-01', '2024-08-05', 480.00),
(2, 2, '2024-08-10', '2024-08-15', 500.00);

-- Dodawanie płatności
INSERT INTO Payments (RentalID, PaymentDate, Amount, PaymentMethod)
VALUES 
(1, '2024-08-01', 480.00, 'Karta'),
(2, '2024-08-10', 500.00, 'Przelew');



-- Wyszukanie wszystkich klientów, którzy wypożyczyli samochód więcej niż raz
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(r.RentalID) AS NumberOfRentals
FROM Customers c
JOIN Rentals r ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(r.RentalID) > 1;

--Wyświetlenie listy samochodów wraz z liczbą dni, przez które były wypożyczone
SELECT 
    ca.Make, 
    ca.Model, 
    ca.Year, 
    SUM(DATEDIFF(DAY, r.RentalDate, r.ReturnDate)) AS TotalRentalDays
FROM Cars ca
LEFT JOIN Rentals r ON ca.CarID = r.CarID
GROUP BY ca.Make, ca.Model, ca.Year
ORDER BY TotalRentalDays DESC;

-- Wyszukanie przychodu z wypożyczeń samochodów w rozbiciu na miesiące
SELECT 
    YEAR(r.RentalDate) AS Year, 
    MONTH(r.RentalDate) AS Month, 
    SUM(r.TotalAmount) AS MonthlyRevenue
FROM Rentals r
GROUP BY YEAR(r.RentalDate), MONTH(r.RentalDate)
ORDER BY Year, Month;

--Tworzenie widoku wyświetlającego pełne informacje o wypożyczeniach
CREATE VIEW RentalDetails AS
SELECT 
    r.RentalID, 
    c.FirstName, 
    c.LastName, 
    ca.Make, 
    ca.Model, 
    r.RentalDate, 
    r.ReturnDate, 
    r.TotalAmount, 
    p.PaymentMethod, 
    p.PaymentDate
FROM Rentals r
JOIN Customers c ON r.CustomerID = c.CustomerID
JOIN Cars ca ON r.CarID = ca.CarID
JOIN Payments p ON r.RentalID = p.RentalID;

-- Tworzenie tabeli 'FrequentCustomers'
CREATE TABLE FrequentCustomers (
    FrequentCustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    RentalCount INT
);


INSERT INTO FrequentCustomers (CustomerID, FirstName, LastName, Email, RentalCount)
SELECT 
    c.CustomerID, 
    c.FirstName, 
    c.LastName, 
    c.Email, 
    COUNT(r.RentalID) AS RentalCount
FROM 
    Customers c
JOIN 
    Rentals r ON c.CustomerID = r.CustomerID
GROUP BY 
    c.CustomerID, c.FirstName, c.LastName, c.Email
HAVING 
    COUNT(r.RentalID) > 1;


SELECT * FROM FrequentCustomers;

-- Dodawanie klientów 
INSERT INTO FrequentCustomers (CustomerID, FirstName, LastName, Email, RentalCount)
SELECT 
    c.CustomerID, 
    c.FirstName, 
    c.LastName, 
    c.Email, 
    COUNT(r.RentalID) AS RentalCount
FROM 
    Customers c
JOIN 
    Rentals r ON c.CustomerID = r.CustomerID
GROUP BY 
    c.CustomerID, c.FirstName, c.LastName, c.Email
HAVING 
    COUNT(r.RentalID) > 1;


INSERT INTO FrequentCustomers (CustomerID, FirstName, LastName, Email, RentalCount)
VALUES 
(1, 'Jan', 'Kowalski', 'jan.kowalski@example.com', 3),
(2, 'Anna', 'Nowak', 'anna.nowak@example.com', 2),
(3, 'Piotr', 'Zieliński', 'piotr.zielinski@example.com', 4);

INSERT INTO FrequentCustomers (CustomerID, FirstName, LastName, Email, RentalCount)
VALUES 
(4, 'Marek', 'Nowicki', 'marek.nowicki@example.com', 5),
(5, 'Ewa', 'Wiśniewska', 'ewa.wisniewska@example.com', 3),
(6, 'Tomasz', 'Jankowski', 'tomasz.jankowski@example.com', 2),
(7, 'Katarzyna', 'Kowalczyk', 'katarzyna.kowalczyk@example.com', 4),
(8, 'Paweł', 'Zalewski', 'pawel.zalewski@example.com', 6),
(9, 'Barbara', 'Wójcik', 'barbara.wojcik@example.com', 2),
(10, 'Jacek', 'Kamiński', 'jacek.kaminski@example.com', 3),
(11, 'Aleksandra', 'Lewandowska', 'aleksandra.lewandowska@example.com', 5),
(12, 'Michał', 'Piotrowski', 'michal.piotrowski@example.com', 7),
(13, 'Zofia', 'Kaczmarek', 'zofia.kaczmarek@example.com', 4),
(14, 'Grzegorz', 'Sikorski', 'grzegorz.sikorski@example.com', 3),
(15, 'Magdalena', 'Kwiatkowska', 'magdalena.kwiatkowska@example.com', 2);

SELECT * FROM FrequentCustomers;

