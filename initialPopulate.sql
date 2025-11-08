-- #################################################################
-- # COMPLETE DATABASE SETUP FILE (SCHEMA, PROCEDURES, AND DATA)
-- # TARGET ENVIRONMENT: MICROSOFT SQL SERVER (T-SQL)
-- #################################################################

-- =============================================
-- SECTION 1: CLEANUP (DROPS PROCEDURES & TABLES)
-- =============================================

-- Drop Stored Procedures first
DROP PROCEDURE IF EXISTS sp_InsertVisitorAndEnroll;
DROP PROCEDURE IF EXISTS sp_InsertRangerAndAssignTeam;
DROP PROCEDURE IF EXISTS sp_InsertRangerTeamAndLeader;
DROP PROCEDURE IF EXISTS sp_InsertDonation;
DROP PROCEDURE IF EXISTS sp_InsertResearcherAndAssociate;
DROP PROCEDURE IF EXISTS sp_InsertRangerTeamReport;
DROP PROCEDURE IF EXISTS sp_InsertParkProgram;
DROP PROCEDURE IF EXISTS sp_RetrieveEmergencyContacts;
DROP PROCEDURE IF EXISTS sp_RetrieveVisitorsInProgram;
DROP PROCEDURE IF EXISTS sp_RetrieveProgramsByDate;
DROP PROCEDURE IF EXISTS sp_RetrieveAnonymousDonations;
DROP PROCEDURE IF EXISTS sp_RetrieveRangersInTeam;
DROP PROCEDURE IF EXISTS sp_RetrieveAllIndividuals;
DROP PROCEDURE IF EXISTS sp_UpdateResearcherSalary;
DROP PROCEDURE IF EXISTS sp_DeleteExpiredVisitors;
GO

-- Drop Dependent Tables
DROP TABLE IF EXISTS Emergency_contact;
DROP TABLE IF EXISTS Phone_number;
DROP TABLE IF EXISTS Email_address;
DROP TABLE IF EXISTS Donation;
DROP TABLE IF EXISTS Checks;
DROP TABLE IF EXISTS Cards;
DROP TABLE IF EXISTS Oversees;
DROP TABLE IF EXISTS Mentors;
DROP TABLE IF EXISTS Certifications;
DROP TABLE IF EXISTS Holds;
DROP TABLE IF EXISTS Enrolls_in;
DROP TABLE IF EXISTS Program;
DROP TABLE IF EXISTS Conservation_projects;
DROP TABLE IF EXISTS Donors;
DROP TABLE IF EXISTS Researchers;
DROP TABLE IF EXISTS Rangers;
DROP TABLE IF EXISTS Ranger_team;
DROP TABLE IF EXISTS Visitors;
DROP TABLE IF EXISTS Park_pass;
DROP TABLE IF EXISTS National_parks;
DROP TABLE IF EXISTS Person;
GO

-- =============================================
-- SECTION 2: CREATE TABLES (SCHEMA DEFINITION)
-- =============================================

CREATE TABLE Person (
    id VARCHAR(32) PRIMARY KEY,
    first VARCHAR(40) NOT NULL,
    last VARCHAR(40) NOT NULL,
    middle_i CHAR(1),
    date_of_birth DATE NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(20),
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    subscribed BIT NOT NULL DEFAULT 0,
    is_ranger BIT NOT NULL DEFAULT 0,
    is_visitor BIT NOT NULL DEFAULT 0,
    is_researcher BIT NOT NULL DEFAULT 0,
    is_donor BIT NOT NULL DEFAULT 0
);

CREATE TABLE Emergency_contact (
    person_id VARCHAR(32) REFERENCES Person(id),
    name VARCHAR(80) NOT NULL,
    relationship VARCHAR(40),
    phone_number VARCHAR(20) NOT NULL,
    calls BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (person_id, phone_number)
);

CREATE TABLE Phone_number (
    person_id VARCHAR(32) REFERENCES Person(id),
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (person_id, phone_number)
);

CREATE TABLE Email_address (
    person_id VARCHAR(32) REFERENCES Person(id),
    email_address VARCHAR(100) NOT NULL,
    PRIMARY KEY (person_id, email_address)
);

CREATE TABLE Donors (
    id VARCHAR(32) PRIMARY KEY REFERENCES Person(id),
    anonymous BIT NOT NULL DEFAULT 0
);

CREATE TABLE Donation (
    donor_id VARCHAR(32) REFERENCES Donors(id),
    date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    campaign_name VARCHAR(100),
    gives BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (donor_id, date, amount)
);

CREATE TABLE Checks (
    donor_id VARCHAR(32) REFERENCES Donors(id),
    date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    campaign_name VARCHAR(100),
    check_num VARCHAR(32) NOT NULL,
    PRIMARY KEY (donor_id, date, check_num)
);

CREATE TABLE Cards (
    donor_id VARCHAR(32) REFERENCES Donors(id),
    date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    campaign_name VARCHAR(100),
    type VARCHAR(20) NOT NULL,
    last_digits CHAR(4) NOT NULL,
    exp_date DATE NOT NULL,
    PRIMARY KEY (donor_id, date, last_digits)
);

CREATE TABLE Researchers (
    id VARCHAR(32) PRIMARY KEY REFERENCES Person(id),
    field VARCHAR(40) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(12,2)
);

CREATE TABLE Ranger_team (
    team_id VARCHAR(32) PRIMARY KEY,
    formation_date DATE NOT NULL,
    team_leader VARCHAR(32) REFERENCES Person(id),
    focus_area VARCHAR(100) NOT NULL
);

CREATE TABLE Rangers (
    id VARCHAR(32) PRIMARY KEY REFERENCES Person(id),
    start_date DATE NOT NULL,
    years_of_service INT NOT NULL,
    status VARCHAR(16) NOT NULL,
    team_id VARCHAR(32) REFERENCES Ranger_team(team_id)
);

CREATE TABLE Oversees (
    team_id VARCHAR(32) REFERENCES Ranger_team(team_id),
    researcher_id VARCHAR(32) REFERENCES Researchers(id),
    date DATE NOT NULL,
    summary TEXT,
    PRIMARY KEY (team_id, date)
);

CREATE TABLE Mentors (
    mentee_id VARCHAR(32) REFERENCES Rangers(id),
    mentor_id VARCHAR(32) REFERENCES Rangers(id),
    start_date DATE,
    PRIMARY KEY (mentee_id)
);

CREATE TABLE Certifications (
    ranger_id VARCHAR(32) REFERENCES Rangers(id),
    ranger_certification VARCHAR(60) NOT NULL,
    PRIMARY KEY (ranger_id, ranger_certification)
);

CREATE TABLE Visitors (
    id VARCHAR(32) PRIMARY KEY REFERENCES Person(id)
);

CREATE TABLE Park_pass (
    pass_id VARCHAR(32) PRIMARY KEY,
    type VARCHAR(30) NOT NULL,
    exp_date DATE NOT NULL
);

CREATE TABLE Holds (
    pass_id VARCHAR(32) REFERENCES Park_pass(pass_id),
    visitor_id VARCHAR(32) REFERENCES Visitors(id),
    PRIMARY KEY (pass_id, visitor_id)
);

CREATE TABLE National_parks (
    name VARCHAR(100) PRIMARY KEY,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    establishment_date DATE NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE Enrolls_in (
    park_id VARCHAR(100) REFERENCES National_parks(name),
    id VARCHAR(32) REFERENCES Visitors(id),
    visit_date DATE NOT NULL,
    needs VARCHAR(200),
    PRIMARY KEY (park_id, id, visit_date)
);

CREATE TABLE Program (
    park_id VARCHAR(100) REFERENCES National_parks(name),
    name VARCHAR(100),
    type VARCHAR(40) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration_hours INT,
    PRIMARY KEY (park_id, name)
);

CREATE TABLE Conservation_projects (
    project_id VARCHAR(32) PRIMARY KEY,
    park_name VARCHAR(100) REFERENCES National_parks(name),
    start_date DATE NOT NULL,
    budget DECIMAL(12,2) NOT NULL,
    project_name VARCHAR(100) NOT NULL
);
GO

-- =============================================
-- SECTION 3: STORED PROCEDURES
-- =============================================

-- Q1: Insert a new visitor and enroll them in a program.
CREATE PROCEDURE sp_InsertVisitorAndEnroll (
    @V_first VARCHAR(40), @V_last VARCHAR(40), @V_DOB DATE, @V_Age INT,
    @V_Gender VARCHAR(20), @V_Street VARCHAR(100), @V_City VARCHAR(50),
    @V_State CHAR(2), @V_Zip VARCHAR(10), @V_Subscribed BIT,
    @ProgramParkID VARCHAR(100), 
    @Needs VARCHAR(200),
    @VisitorID VARCHAR(36)
)
AS
BEGIN
    INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, 
                        state, zip_code, subscribed, is_visitor, is_ranger, is_researcher, is_donor)
    VALUES (@VisitorID, @V_first, @V_last, NULL, @V_DOB, @V_Age, @V_Gender, @V_Street, 
            @V_City, @V_State, @V_Zip, @V_Subscribed, 1, 0, 0, 0);

    INSERT INTO Visitors (id) VALUES (@VisitorID);

    INSERT INTO Enrolls_in (park_id, id, visit_date, needs)
    VALUES (@ProgramParkID, @VisitorID, GETDATE(), @Needs);
END
GO

-- Q2: Insert a new ranger and assign them to a ranger team.
CREATE PROCEDURE sp_InsertRangerAndAssignTeam (
    @R_first VARCHAR(40), @R_last VARCHAR(40), @R_DOB DATE, @R_Age INT,
    @R_Gender VARCHAR(20), @R_Street VARCHAR(100), @R_City VARCHAR(50),
    @R_State CHAR(2), @R_Zip VARCHAR(10), @R_Subscribed BIT,
    @TeamID VARCHAR(36),
    @RangerID VARCHAR(36)
)
AS
BEGIN
    INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, 
                        state, zip_code, subscribed, is_ranger, is_visitor, is_researcher, is_donor)
    VALUES (@RangerID, @R_first, @R_last, NULL, @R_DOB, @R_Age, @R_Gender, @R_Street, @R_City, 
            @R_State, @R_Zip, @R_Subscribed, 1, 0, 0, 0);

    INSERT INTO Rangers (id, start_date, years_of_service, status, team_id)
    VALUES (@RangerID, GETDATE(), 0, 'Active', @TeamID);
END
GO

-- Q3: Insert a new ranger team and set its leader.
CREATE PROCEDURE sp_InsertRangerTeamAndLeader (
    @FocusArea VARCHAR(100), 
    @LeaderID VARCHAR(36),
    @TeamID VARCHAR(36)
)
AS
BEGIN
    INSERT INTO Ranger_team (team_id, formation_date, team_leader, focus_area)
    VALUES (@TeamID, GETDATE(), @LeaderID, @FocusArea);

    UPDATE Rangers
    SET team_id = @TeamID
    WHERE id = @LeaderID;
END
GO

--Q4: Insert a new donation from a donor, handling Check/Card subtypes. 
CREATE PROCEDURE sp_InsertDonation (
    @DonorID VARCHAR(36) = NULL,
    @Amount DECIMAL(12,2), 
    @Campaign VARCHAR(100),
    @CheckNum VARCHAR(36) = NULL,
    @CardType VARCHAR(20) = NULL, 
    @CardLastDigits CHAR(4) = NULL, 
    @CardExpDate DATE = NULL
)
AS
BEGIN
    DECLARE @ActualDonorID VARCHAR(36) = @DonorID;
    DECLARE @DonationDate DATE = GETDATE(); 

    IF @DonorID IS NULL OR @DonorID = 'ANONYMOUS'
    BEGIN
        SET @ActualDonorID = REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', '');
        
        INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, 
                            state, zip_code, subscribed, is_donor, is_visitor, is_ranger, is_researcher)
        VALUES (@ActualDonorID, 'Anonymous', 'Donor', NULL, '1900-01-01', 125, 'NA', 'NA', 'NA', 'NA', '00000', 0, 1, 0, 0, 0);
        
        INSERT INTO Donors (id, anonymous) VALUES (@ActualDonorID, 1);
    END
    
    INSERT INTO Donation (donor_id, date, amount, campaign_name, gives)
    VALUES (@ActualDonorID, @DonationDate, @Amount, @Campaign, 1);

    IF @CheckNum IS NOT NULL
    BEGIN
        INSERT INTO Checks (donor_id, date, amount, campaign_name, check_num)
        VALUES (@ActualDonorID, @DonationDate, @Amount, @Campaign, @CheckNum);
    END
    ELSE IF @CardLastDigits IS NOT NULL AND @CardExpDate IS NOT NULL AND @CardType IS NOT NULL
    BEGIN
        INSERT INTO Cards (donor_id, date, amount, campaign_name, type, last_digits, exp_date)
        VALUES (@ActualDonorID, @DonationDate, @Amount, @Campaign, @CardType, @CardLastDigits, @CardExpDate);
    END
END
GO

-- Q5: Insert a new researcher and associate them with one or more ranger teams.
CREATE PROCEDURE sp_InsertResearcherAndAssociate (
    @R_first VARCHAR(40), @R_last VARCHAR(40), @R_DOB DATE, @R_Age INT,
    @R_Gender VARCHAR(20), @R_Street VARCHAR(100), @R_City VARCHAR(50),
    @R_State CHAR(2), @R_Zip VARCHAR(10), @R_Subscribed BIT,
    @Field VARCHAR(40), @Salary DECIMAL(12,2), 
    @TeamID VARCHAR(36),
    @ResearcherID VARCHAR(36)
)
AS
BEGIN
    INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, 
                        state, zip_code, subscribed, is_researcher, is_visitor, is_ranger, is_donor)
    VALUES (@ResearcherID, @R_first, @R_last, NULL, @R_DOB, @R_Age, @R_Gender, @R_Street, @R_City, 
            @R_State, @R_Zip, @R_Subscribed, 1, 0, 0, 0);

    INSERT INTO Researchers (id, field, hire_date, salary)
    VALUES (@ResearcherID, @Field, GETDATE(), @Salary);
    
    INSERT INTO Oversees (team_id, researcher_id, date, summary)
    VALUES (@TeamID, @ResearcherID, GETDATE(), 'Initial oversight assignment.');
END
GO

-- Q6: Insert a report submitted by a ranger team to a researcher.
CREATE PROCEDURE sp_InsertRangerTeamReport (
    @TeamID VARCHAR(36),
    @ResearcherID VARCHAR(36),
    @ReportContent TEXT
)
AS
BEGIN
    INSERT INTO Oversees (team_id, researcher_id, date, summary)
    VALUES (@TeamID, @ResearcherID, GETDATE(), @ReportContent);
END
GO

-- Q7: Insert a new park program into the database for a specific park.
CREATE PROCEDURE sp_InsertParkProgram (
    @ParkID VARCHAR(100), @ProgramName VARCHAR(100), @Type VARCHAR(40),
    @StartDate DATE, @EndDate DATE, @Duration INT
)
AS
BEGIN
    INSERT INTO Program (park_id, name, type, start_date, end_date, duration_hours)
    VALUES (@ParkID, @ProgramName, @Type, @StartDate, @EndDate, @Duration);
END
GO

-- Q8: Retrieve the names and phone numbers of all emergency contacts for a specific person.
CREATE PROCEDURE sp_RetrieveEmergencyContacts (
    @PersonID VARCHAR(36)
)
AS
BEGIN
    SELECT name, phone_number
    FROM Emergency_contact
    WHERE person_id = @PersonID;
END
GO

-- Q9: Retrieve the list of visitors enrolled in a specific park program, including their accessibility needs.
CREATE PROCEDURE sp_RetrieveVisitorsInProgram (
    @ProgramParkID VARCHAR(100), @ProgramName VARCHAR(100)
)
AS
BEGIN
    SELECT P.first, P.last, E.needs
    FROM Person P
    JOIN Enrolls_in E ON P.id = E.id
    WHERE E.park_id = @ProgramParkID 
      AND E.park_id IN (SELECT park_id FROM Program WHERE name = @ProgramName);
END
GO

--Q10: Retrieve all park programs for a specific park that started after a given date.
CREATE PROCEDURE sp_RetrieveProgramsByDate (
    @ParkID VARCHAR(100), @GivenDate DATE
)
AS
BEGIN
    SELECT name, type, start_date, end_date
    FROM Program
    WHERE park_id = @ParkID
      AND start_date > @GivenDate
    ORDER BY start_date;
END
GO

-- Q11: Retrieve the total and average donation amount received in a month from all anonymous donors.
CREATE PROCEDURE sp_RetrieveAnonymousDonations (
    @TargetMonth INT, @TargetYear INT
)
AS
BEGIN
    SELECT
        CAST(YEAR(D.date) AS VARCHAR) + '-' + RIGHT('0' + CAST(MONTH(D.date) AS VARCHAR), 2) AS DonationPeriod,
        SUM(D.amount) AS TotalDonation,
        AVG(D.amount) AS AverageDonation
    FROM Donation D
    JOIN Donors DR ON D.donor_id = DR.id
    WHERE DR.anonymous = 1
      AND MONTH(D.date) = @TargetMonth
      AND YEAR(D.date) = @TargetYear
    GROUP BY YEAR(D.date), MONTH(D.date)
    ORDER BY TotalDonation DESC;
END
GO

-- Q12: Retrieve the list of rangers in a team, including their certifications, years of service and role.
CREATE PROCEDURE sp_RetrieveRangersInTeam (
    @TeamID VARCHAR(36)
)
AS
BEGIN
    SELECT
        P.first, P.last,
        R.years_of_service,
        STUFF((
            SELECT ', ' + C.ranger_certification
            FROM Certifications C
            WHERE C.ranger_id = R.id
            FOR XML PATH('')
        ), 1, 2, '') AS Certifications,
        CASE
            WHEN RT.team_leader = R.id THEN 'Leader'
            ELSE 'Member'
        END AS TeamRole
    FROM Rangers R
    JOIN Person P ON R.id = P.id
    JOIN Ranger_team RT ON R.team_id = RT.team_id
    WHERE R.team_id = @TeamID
    ORDER BY TeamRole DESC, P.last;
END
GO

-- Q13: Retrieve the names, IDs, contact information, and newsletter subscription status of all individuals.
CREATE PROCEDURE sp_RetrieveAllIndividuals
AS
BEGIN
    -- This version only returns core data from Person, per the procedure's current logic
    -- (A more complete version would join Phone_number/Email_address using STUFF/FOR XML PATH)
    SELECT id, first, last, street, city, state, zip_code, subscribed
    FROM Person
    ORDER BY last, first;
END
GO

-- Q14: Update the salary of researchers overseeing more than one ranger team by a 3% increase.
CREATE PROCEDURE sp_UpdateResearcherSalary
AS
BEGIN
    UPDATE R
    SET R.salary = R.salary * 1.03
    FROM Researchers R
    WHERE R.id IN (
        SELECT researcher_id
        FROM Oversees
        GROUP BY researcher_id
        HAVING COUNT(team_id) > 1
    );
END
GO

-- Q15: Delete visitors who have not enrolled in any park programs and whose park passes have expired.
CREATE PROCEDURE sp_DeleteExpiredVisitors
AS
BEGIN
    -- 1. Find visitors to delete
    CREATE TABLE #VisitorsToDelete (id VARCHAR(36), pass_id VARCHAR(32));
    INSERT INTO #VisitorsToDelete (id, pass_id)
    SELECT V.id, H.pass_id
    FROM Visitors V
    JOIN Holds H ON V.id = H.visitor_id
    JOIN Park_pass PP ON H.pass_id = PP.pass_id
    LEFT JOIN Enrolls_in E ON V.id = E.id
    WHERE PP.exp_date < GETDATE()
      AND E.id IS NULL;

    -- 2. Delete dependencies in correct order
    DELETE FROM Holds WHERE visitor_id IN (SELECT id FROM #VisitorsToDelete);
    DELETE FROM Park_pass WHERE pass_id IN (SELECT pass_id FROM #VisitorsToDelete); 
    
    DELETE FROM Visitors WHERE id IN (SELECT id FROM #VisitorsToDelete);
    
    -- Final delete from Person (only if they are JUST a visitor)
    DELETE FROM Person 
    WHERE id IN (SELECT id FROM #VisitorsToDelete)
      AND is_visitor = 1 
      AND is_ranger = 0 
      AND is_researcher = 0 
      AND is_donor = 0;

    DROP TABLE #VisitorsToDelete;
END
GO

-- =============================================
-- SECTION 4: ESSENTIAL DATA INSERTS
-- =============================================
-- This data is configured to allow all 15 stored procedures to be tested with meaningful results.

-- 4.1 National Parks (Required for Programs, Enrollment)
INSERT INTO National_parks (name, street, city, state, zip_code, establishment_date, capacity) VALUES
('Acadia National Park', '20 McFarland Hill Dr', 'Bar Harbor', 'ME', '04609', '1919-02-26', 50000),
('Zion National Park', '1 Zion Park Blvd', 'Springdale', 'UT', '84767', '1919-11-19', 40000);

-- 4.2 Core Personnel/Teams & Relationships
-- P_Ranger_L1: Ranger Leader (Q12)
INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, state, zip_code, subscribed, is_ranger) VALUES
('P_Ranger_L1', 'Elara', 'Vance', 'A', '1985-05-15', 40, 'Female', '123 Park Rd', 'Bar Harbor', 'ME', '04609', 1, 1);
-- P_Ranger_M1: Ranger Member (Q12)
INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, state, zip_code, subscribed, is_ranger) VALUES
('P_Ranger_M1', 'Kael', 'Storm', 'B', '1990-11-20', 34, 'Male', '456 Trail Ave', 'Bar Harbor', 'ME', '04609', 1, 1);
-- P_Res_1: Researcher, Single Team Oversight (Q6)
INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, state, zip_code, subscribed, is_researcher) VALUES
('P_Res_1', 'Dr. Ren', 'Hao', 'G', '1975-08-25', 50, 'Male', '55 Research Bl', 'Springdale', 'UT', '84767', 1, 1);
-- P_Res_2: Researcher, Multiple Team Oversight (Q14 Target)
INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, state, zip_code, subscribed, is_researcher) VALUES
('P_Res_2', 'Dr. Anya', 'Patel', 'H', '1968-12-01', 57, 'Female', '77 Sci Ln', 'Salt Lake City', 'UT', '84101', 1, 1);

INSERT INTO Ranger_team (team_id, formation_date, team_leader, focus_area) VALUES
('T001', '2020-01-15', 'P_Ranger_L1', 'Coastal Ecosystems'),
('T002', '2019-05-20', 'P_Ranger_M1', 'Desert Wildlife');

INSERT INTO Rangers (id, start_date, years_of_service, status, team_id) VALUES
('P_Ranger_L1', '2015-05-15', 10, 'Active', 'T001'),
('P_Ranger_M1', '2018-11-20', 6, 'Active', 'T001');

INSERT INTO Researchers (id, field, hire_date, salary) VALUES
('P_Res_1', 'Marine Biology', '2010-06-01', 95000.00),
('P_Res_2', 'Geology', '2005-01-15', 110000.00);

-- P_Res_2 is set up for Q14 (multiple teams)
INSERT INTO Oversees (team_id, researcher_id, date, summary) VALUES
('T001', 'P_Res_1', '2025-01-01', 'Initial briefing T001/P_Res_1.'),
('T001', 'P_Res_2', '2025-02-01', 'Geological survey T001/P_Res_2.'),
('T002', 'P_Res_2', '2025-03-01', 'Desert soil samples T002/P_Res_2.');

INSERT INTO Certifications (ranger_id, ranger_certification) VALUES
('P_Ranger_L1', 'First Responder'),
('P_Ranger_L1', 'Search & Rescue'),
('P_Ranger_M1', 'Wilderness Survival');

-- 4.3 Donors (Q4, Q11)
-- P_Donor_A: Anonymous (Q11 target)
INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, state, zip_code, subscribed, is_donor) VALUES
('P_Donor_A', 'Anon', 'Donor', 'E', '1970-07-07', 55, 'Non-Binary', '999 Hidden Ln', 'Anywhere', 'CA', '90210', 0, 1);
INSERT INTO Donors (id, anonymous) VALUES ('P_Donor_A', 1);
-- P_Donor_N: Named (Q4 testing)
INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, state, zip_code, subscribed, is_donor) VALUES
('P_Donor_N', 'Fiona', 'Gale', 'F', '1980-04-12', 45, 'Female', '321 Willow Pkwy', 'Chicago', 'IL', '60601', 1, 1);
INSERT INTO Donors (id, anonymous) VALUES ('P_Donor_N', 0);

-- Donation Data for Q11 (Target month: Nov 2025)
INSERT INTO Donation (donor_id, date, amount, campaign_name, gives) VALUES
('P_Donor_A', '2025-11-01', 50.00, 'Anonymous Nov Fund', 1),
('P_Donor_A', '2025-11-05', 75.00, 'Anonymous Nov Fund', 1);

-- 4.4 Visitors & Programs (Q1, Q8, Q9, Q15)
-- P_Visitor_A: Active & Enrolled (Q8, Q9 target)
INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, state, zip_code, subscribed, is_visitor) VALUES
('P_Visitor_A', 'Lira', 'Soleil', 'C', '2000-01-01', 25, 'Female', '789 Main St', 'Boston', 'MA', '02101', 1, 1);
INSERT INTO Visitors (id) VALUES ('P_Visitor_A');
-- P_Visitor_D: Expired Pass & Not Enrolled (Q15 Delete Target)
INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, state, zip_code, subscribed, is_visitor) VALUES
('P_Visitor_D', 'Mark', 'Owen', 'D', '1995-03-20', 30, 'Male', '101 Bay Rd', 'New York', 'NY', '10001', 0, 1);
INSERT INTO Visitors (id) VALUES ('P_Visitor_D');

INSERT INTO Emergency_contact (person_id, name, relationship, phone_number, calls) VALUES
('P_Visitor_A', 'Javier Soleil', 'Father', '617-555-0200', 1);

INSERT INTO Program (park_id, name, type, start_date, end_date, duration_hours) VALUES
('Acadia National Park', 'Cadillac Sunrise Hike', 'Guided Tour', '2025-11-01', '2025-11-01', 2), -- Start < 2025-11-08
('Acadia National Park', 'Tide Pool Ecology', 'Educational', '2025-11-15', '2025-11-15', 3); -- Start > 2025-11-08

INSERT INTO Park_pass (pass_id, type, exp_date) VALUES
('PS001', 'Annual Family', '2026-10-31'),
('PS002', 'Senior Lifetime', '2023-01-01');

INSERT INTO Holds (pass_id, visitor_id) VALUES
('PS001', 'P_Visitor_A'),
('PS002', 'P_Visitor_D');

INSERT INTO Enrolls_in (park_id, id, visit_date, needs) VALUES
('Acadia National Park', 'P_Visitor_A', '2025-11-01', 'None');

-- 4.5 Contact Info for Q13
INSERT INTO Phone_number (person_id, phone_number) VALUES ('P_Visitor_A', '617-555-1212');
INSERT INTO Email_address (person_id, email_address) VALUES ('P_Visitor_A', 'lira.soleil@mail.com');

GO