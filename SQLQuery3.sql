CREATE DATABASE ClinicNurses;
GO

USE ClinicNurses;
GO

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(100) NOT NULL
);

DROP TABLE Departments;

-- Tabela Departments (Oddziały)
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(100) NOT NULL UNIQUE,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME
);

-- Tabela Permissions (Uprawnienia)
CREATE TABLE Permissions (
    PermissionID INT PRIMARY KEY IDENTITY(1,1),
    PermissionName VARCHAR(100) NOT NULL UNIQUE,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME
);

-- Tabela Nurses (Pielęgniarki)
CREATE TABLE Nurses (
    NurseID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Degree VARCHAR(20) CHECK (Degree IN ('Licencjat', 'Magister')) NOT NULL,
    HireDate DATE NOT NULL,
    DepartmentID INT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

--Tabela NursePermissions (Uprawnienia Pielęgniarek)
CREATE TABLE NursePermissions (
    NursePermissionID INT PRIMARY KEY IDENTITY(1,1),
    NurseID INT,
    PermissionID INT,
    AssignedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (NurseID) REFERENCES Nurses(NurseID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (PermissionID) REFERENCES Permissions(PermissionID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (NurseID, PermissionID)
);

-- Wstawianie Danych do Tabeli Departments
INSERT INTO Departments (DepartmentName) VALUES
('Pediatria'),
('Chirurgia'),
('Onkologia');

-- Wstawianie Danych do Tabeli Permissions
INSERT INTO Permissions (PermissionName) VALUES
('Podawanie leków'),
('Pobieranie krwi'),
('Szczepienie');

--  Wstawianie Danych do Tabeli Nurses
INSERT INTO Nurses (FirstName, LastName, Degree, HireDate, DepartmentID) VALUES
('Anna', 'Kowalska', 'Licencjat', '2020-05-15', 1),
('Ola', 'Nowak', 'Licencjat', '2021-06-20', 2),
('Kasia', 'Wiśniewska', 'Licencjat', '2019-11-30', 3),
('Monika', 'Zielińska', 'Magister', '2018-04-25', 1),
('Magda', 'Lewandowska', 'Magister', '2022-02-10', 2);

--Wstawianie Danych do Tabeli NursePermissions
-- Uprawnienia dla pielęgniarek z licencjatem
INSERT INTO NursePermissions (NurseID, PermissionID) VALUES
(1, 1), -- Anna - Podawanie leków
(1, 2), -- Anna - Pobieranie krwi
(2, 1), -- Ola - Podawanie leków
(2, 2), -- Ola - Pobieranie krwi
(3, 1), -- Kasia - Podawanie leków
(3, 2); -- Kasia - Pobieranie krwi

-- Uprawnienia dla pielęgniarek z magistrem
INSERT INTO NursePermissions (NurseID, PermissionID) VALUES
(4, 1), -- Monika - Podawanie leków
(4, 2), -- Monika - Pobieranie krwi
(4, 3), -- Monika - Szczepienie
(5, 1), -- Magda - Podawanie leków
(5, 2), -- Magda - Pobieranie krwi
(5, 3); -- Magda - Szczepienie

--Wyszukanie Pielęgniarek z Tytułem Magistra
SELECT FirstName, LastName
FROM Nurses
WHERE Degree = 'Magister';

--Wyświetlenie Uprawnień Pielęgniarki o Nazwisku 'Zielińska'
SELECT p.PermissionName
FROM Nurses n
JOIN NursePermissions np ON n.NurseID = np.NurseID
JOIN Permissions p ON np.PermissionID = p.PermissionID
WHERE n.LastName = 'Zielińska';

-- Wyświetlenie Liczby Pielęgniarek na Każdym Oddziale
SELECT d.DepartmentName, COUNT(n.NurseID) AS LiczbaPielęgniarek
FROM Departments d
LEFT JOIN Nurses n ON d.DepartmentID = n.DepartmentID
GROUP BY d.DepartmentName;

--Lista Pielęgniarek oraz Ich Uprawnień
SELECT n.FirstName, n.LastName, p.PermissionName
FROM Nurses n
JOIN NursePermissions np ON n.NurseID = np.NurseID
JOIN Permissions p ON np.PermissionID = p.PermissionID
ORDER BY n.LastName;

--Lista Pielęgniarek z Uprawnieniem do Szczepienia
SELECT n.FirstName, n.LastName
FROM Nurses n
JOIN NursePermissions np ON n.NurseID = np.NurseID
WHERE np.PermissionID = (SELECT PermissionID FROM Permissions WHERE PermissionName = 'Szczepienie');

-- Dodanie Nowego Uprawnienia dla Pielęgniarki
INSERT INTO NursePermissions (NurseID, PermissionID)
VALUES (2, 3); -- Dodanie uprawnienia 'Szczepienie' dla pielęgniarki Ola Nowak (ID 2)


--Procedura Dodająca Nową Pielęgniarkę
CREATE PROCEDURE AddNurse
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Degree VARCHAR(20),
    @HireDate DATE,
    @DepartmentID INT
AS
BEGIN
    INSERT INTO Nurses (FirstName, LastName, Degree, HireDate, DepartmentID)
    VALUES (@FirstName, @LastName, @Degree, @HireDate, @DepartmentID);
END;

--Procedura Dodająca Uprawnienie dla Pielęgniarki
CREATE PROCEDURE AddNursePermission
    @NurseID INT,
    @PermissionID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NursePermissions WHERE NurseID = @NurseID AND PermissionID = @PermissionID)
    BEGIN
        INSERT INTO NursePermissions (NurseID, PermissionID)
        VALUES (@NurseID, @PermissionID);
    END
    ELSE
    BEGIN
        PRINT 'This nurse already has this permission.';
    END
END;


--Trigger Automatycznie Ustawiający UpdatedAt na Aktualną Datę
CREATE TRIGGER trg_UpdateTimestamp
ON Nurses
AFTER UPDATE
AS
BEGIN
    UPDATE Nurses
    SET UpdatedAt = GETDATE()
    WHERE NurseID IN (SELECT DISTINCT NurseID FROM Inserted);
END;






















