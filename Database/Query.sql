-- Create the database
CREATE DATABASE CityPopulationDB;
GO

USE CityPopulationDB;
GO

-- 1. Associations_Clans table
CREATE TABLE Associations_Clans (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    type NVARCHAR(50),
    contact_person NVARCHAR(100),
    phone NVARCHAR(20),
    email NVARCHAR(100),
    address NVARCHAR(200)
);
GO

-- 2. Citizens table with marriage tracking
CREATE TABLE Citizens (
    id INT PRIMARY KEY IDENTITY(1,1),
    full_name NVARCHAR(100) NOT NULL,
    gender NVARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    birth_date DATE NOT NULL,
    national_id NVARCHAR(20) UNIQUE,
    phone NVARCHAR(20),
    address NVARCHAR(200),
    tribe_family NVARCHAR(100),
    marital_status NVARCHAR(20) DEFAULT 'Single' 
        CHECK (marital_status IN ('Single', 'Married', 'Divorced', 'Widowed')),
    education_level NVARCHAR(50),
    workplace NVARCHAR(100),
    blood_type NVARCHAR(5),
    family_members_count INT DEFAULT 1,
    health_status NVARCHAR(100),
    father_id INT NULL,
    spouse_id INT NULL,
    CONSTRAINT FK_Citizen_Father FOREIGN KEY (father_id) REFERENCES Citizens(id),
    CONSTRAINT FK_Citizen_Spouse FOREIGN KEY (spouse_id) REFERENCES Citizens(id)
);
GO

-- Add check constraint separately
ALTER TABLE Citizens ADD CONSTRAINT CHK_Marriage 
CHECK (
    (gender = 'Female' AND marital_status = 'Married' AND spouse_id IS NOT NULL) OR
    (gender = 'Female' AND marital_status != 'Married' AND spouse_id IS NULL) OR
    (gender != 'Female')
);
GO

-- 3. Parenting table for additional relationships
CREATE TABLE Parenting (
    id INT PRIMARY KEY IDENTITY(1,1),
    citizen_id INT NOT NULL,
    parent_id INT NOT NULL,
    relationship_type NVARCHAR(20) DEFAULT 'Guardian' 
        CHECK (relationship_type IN ('Guardian', 'Step-Parent', 'Adoptive', 'Foster')),
    start_date DATE DEFAULT GETDATE(),
    end_date DATE NULL,
    CONSTRAINT FK_Parenting_Citizen FOREIGN KEY (citizen_id) REFERENCES Citizens(id),
    CONSTRAINT FK_Parenting_Parent FOREIGN KEY (parent_id) REFERENCES Citizens(id),
    CONSTRAINT CHK_Parenting_Dates CHECK (start_date <= ISNULL(end_date, GETDATE()))
);
GO

-- 4. Marriage table to track marriage history
CREATE TABLE Marriages (
    id INT PRIMARY KEY IDENTITY(1,1),
    husband_id INT NOT NULL,
    wife_id INT NOT NULL,
    marriage_date DATE NOT NULL,
    divorce_date DATE NULL,
    CONSTRAINT FK_Marriage_Husband FOREIGN KEY (husband_id) REFERENCES Citizens(id),
    CONSTRAINT FK_Marriage_Wife FOREIGN KEY (wife_id) REFERENCES Citizens(id),
    CONSTRAINT CHK_Marriage_Dates CHECK (marriage_date <= ISNULL(divorce_date, GETDATE()))
);
GO

-- Create filtered index for active marriages
CREATE UNIQUE INDEX UQ_Active_Marriage_Wife ON Marriages(wife_id) 
WHERE divorce_date IS NULL;
GO

-- 5. Students table
CREATE TABLE Students (
    id INT PRIMARY KEY IDENTITY(1,1),
    citizen_id INT NOT NULL,
    school_university NVARCHAR(100),
    education_level NVARCHAR(50),
    major NVARCHAR(100),
    CONSTRAINT FK_Student_Citizen FOREIGN KEY (citizen_id) REFERENCES Citizens(id)
);
GO

-- 6. Users table
CREATE TABLE Users (
    id INT PRIMARY KEY IDENTITY(1,1),
    username NVARCHAR(50) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    role NVARCHAR(20) NOT NULL,
    citizen_id INT NULL,
    CONSTRAINT FK_User_Citizen FOREIGN KEY (citizen_id) REFERENCES Citizens(id)
);
GO

-- 7. Citizen-Clan Membership junction table
CREATE TABLE Citizen_Clan_Membership (
    citizen_id INT NOT NULL,
    clan_id INT NOT NULL,
    join_date DATE DEFAULT GETDATE(),
    membership_type NVARCHAR(50),
    is_active BIT DEFAULT 1,
    PRIMARY KEY (citizen_id, clan_id),
    CONSTRAINT FK_Membership_Citizen FOREIGN KEY (citizen_id) REFERENCES Citizens(id),
    CONSTRAINT FK_Membership_Clan FOREIGN KEY (clan_id) REFERENCES Associations_Clans(id)
);
GO

-- Create indexes
CREATE INDEX IX_Citizens_name ON Citizens(full_name);
CREATE INDEX IX_Citizens_father ON Citizens(father_id);
CREATE INDEX IX_Citizens_spouse ON Citizens(spouse_id);
CREATE INDEX IX_Parenting_citizen ON Parenting(citizen_id);
CREATE INDEX IX_Parenting_parent ON Parenting(parent_id);
CREATE INDEX IX_Marriages_wife ON Marriages(wife_id);
GO

-- Corrected trigger with proper SQL Server syntax
CREATE TRIGGER trg_Prevent_Married_Women_Relationships
ON Parenting
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Citizens c ON i.citizen_id = c.id
        WHERE c.gender = 'Female' 
        AND c.marital_status = 'Married'
        AND i.parent_id <> ISNULL(c.father_id, -1)
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Married women cannot enter parenting relationships with other men', 16, 1);
        RETURN;
    END
END;
GO

-- Stored procedure for marriage
CREATE PROCEDURE MarryCouple
    @husband_id INT,
    @wife_id INT,
    @marriage_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @marriage_date IS NULL
        SET @marriage_date = GETDATE();
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify the woman isn't already married
        IF EXISTS (SELECT 1 FROM Citizens WHERE id = @wife_id AND marital_status = 'Married')
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('The woman is already married', 16, 1);
            RETURN;
        END
        
        -- Verify the man isn't already married
        IF EXISTS (SELECT 1 FROM Citizens WHERE id = @husband_id AND marital_status = 'Married')
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('The man is already married', 16, 1);
            RETURN;
        END
        
        -- Verify genders
        DECLARE @husband_gender NVARCHAR(10), @wife_gender NVARCHAR(10);
        SELECT @husband_gender = gender FROM Citizens WHERE id = @husband_id;
        SELECT @wife_gender = gender FROM Citizens WHERE id = @wife_id;
        
        IF @husband_gender != 'Male' OR @wife_gender != 'Female'
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Marriage must be between a male and female', 16, 1);
            RETURN;
        END
        
        -- Update marital statuses
        UPDATE Citizens SET marital_status = 'Married', spouse_id = @wife_id WHERE id = @husband_id;
        UPDATE Citizens SET marital_status = 'Married', spouse_id = @husband_id WHERE id = @wife_id;
        
        -- Record marriage
        INSERT INTO Marriages (husband_id, wife_id, marriage_date)
        VALUES (@husband_id, @wife_id, @marriage_date);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Stored procedure for divorce
CREATE PROCEDURE DivorceCouple
    @husband_id INT,
    @wife_id INT,
    @divorce_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @divorce_date IS NULL
        SET @divorce_date = GETDATE();
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify they are actually married
        IF NOT EXISTS (
            SELECT 1 FROM Marriages 
            WHERE husband_id = @husband_id 
            AND wife_id = @wife_id 
            AND divorce_date IS NULL)
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('These individuals are not currently married', 16, 1);
            RETURN;
        END
        
        -- Update marital statuses
        UPDATE Citizens SET marital_status = 'Divorced', spouse_id = NULL WHERE id IN (@husband_id, @wife_id);
        
        -- Record divorce
        UPDATE Marriages 
        SET divorce_date = @divorce_date
        WHERE husband_id = @husband_id 
        AND wife_id = @wife_id
        AND divorce_date IS NULL;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
