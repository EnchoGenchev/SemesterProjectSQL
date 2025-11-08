

--Q1: Insert a new visitor and enroll them in a program.
DROP PROCEDURE IF EXISTS sp_InsertVisitorAndEnroll;
GO
CREATE PROCEDURE sp_InsertVisitorAndEnroll (
    @V_first VARCHAR(40), @V_last VARCHAR(40), @V_DOB DATE, @V_Age INT,
    @V_Gender VARCHAR(20), @V_Street VARCHAR(100), @V_City VARCHAR(50),
    @V_State CHAR(2), @V_Zip VARCHAR(10), @V_Subscribed BIT,
    @ProgramParkID VARCHAR(100), 
    @Needs VARCHAR(200),
    @VisitorID VARCHAR(36) -- NEW Input ID
)
AS
BEGIN
    --insert into Person 
    INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, 
                        state, zip_code, subscribed, is_visitor, is_ranger, is_researcher, is_donor)
    VALUES (@VisitorID, @V_first, @V_last, NULL, @V_DOB, @V_Age, @V_Gender, @V_Street, 
            @V_City, @V_State, @V_Zip, @V_Subscribed, 1, 0, 0, 0);

    INSERT INTO Visitors (id) VALUES (@VisitorID);

    --enrolls_in: (park_id, id, visit_date)
    INSERT INTO Enrolls_in (park_id, id, visit_date, needs)
    VALUES (@ProgramParkID, @VisitorID, GETDATE(), @Needs);
END
GO

-- Q2: Insert a new ranger and assign them to a ranger team.
DROP PROCEDURE IF EXISTS sp_InsertRangerAndAssignTeam;
GO
CREATE PROCEDURE sp_InsertRangerAndAssignTeam (
    @R_first VARCHAR(40), @R_last VARCHAR(40), @R_DOB DATE, @R_Age INT,
    @R_Gender VARCHAR(20), @R_Street VARCHAR(100), @R_City VARCHAR(50),
    @R_State CHAR(2), @R_Zip VARCHAR(10), @R_Subscribed BIT,
    @TeamID VARCHAR(36),
    @RangerID VARCHAR(36) --NEW input ID
)
AS
BEGIN
    -- Insert into Person (using user-provided @RangerID)
    INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, 
                        state, zip_code, subscribed, is_ranger, is_visitor, is_researcher, is_donor)
    VALUES (@RangerID, @R_first, @R_last, NULL, @R_DOB, @R_Age, @R_Gender, @R_Street, @R_City, 
            @R_State, @R_Zip, @R_Subscribed, 1, 0, 0, 0);

    INSERT INTO Rangers (id, start_date, years_of_service, status, team_id)
    VALUES (@RangerID, GETDATE(), 0, 'Active', @TeamID);
END
GO

-- Q3: Insert a new ranger team and set its leader.
DROP PROCEDURE IF EXISTS sp_InsertRangerTeamAndLeader;
GO
CREATE PROCEDURE sp_InsertRangerTeamAndLeader (
    @FocusArea VARCHAR(100), 
    @LeaderID VARCHAR(36),
    @TeamID VARCHAR(36) -- NEW Input ID
)
AS
BEGIN
    --insert into Ranger_team (using user-provided @TeamID)
    INSERT INTO Ranger_team (team_id, formation_date, team_leader, focus_area)
    VALUES (@TeamID, GETDATE(), @LeaderID, @FocusArea);

    UPDATE Rangers
    SET team_id = @TeamID
    WHERE id = @LeaderID;
END
GO

--Q4: Insert a new donation from a donor, handling Check/Card subtypes. 
DROP PROCEDURE IF EXISTS sp_InsertDonation;
GO
CREATE PROCEDURE sp_InsertDonation (
    @DonorID VARCHAR(36) = NULL,
    @Amount DECIMAL(12,2), 
    @Campaign VARCHAR(100),

    --parameters for payment sub-types
    @CheckNum VARCHAR(36) = NULL,
    @CardType VARCHAR(20) = NULL, 
    @CardLastDigits CHAR(4) = NULL, 
    @CardExpDate DATE = NULL
)
AS
BEGIN
    DECLARE @ActualDonorID VARCHAR(36) = @DonorID;
    DECLARE @DonationDate DATE = GETDATE(); 

    --1. handle Anonymous Donor 
    IF @DonorID IS NULL OR @DonorID = 'ANONYMOUS'
    BEGIN
        SET @ActualDonorID = REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', '');
        
        --insert into Person 
        INSERT INTO Person (id, first, last, middle_i, date_of_birth, age, gender, street, city, 
                            state, zip_code, subscribed, is_donor, is_visitor, is_ranger, is_researcher)
        VALUES (@ActualDonorID, 'Anonymous', 'Donor', NULL, '1900-01-01', 125, 'NA', 'NA', 'NA', 'NA', '00000', 0, 1, 0, 0, 0);
        
        INSERT INTO Donors (id, anonymous) VALUES (@ActualDonorID, 1);
    END
    
    --2. insert into donation table.
    INSERT INTO Donation (donor_id, date, amount, campaign_name, gives)
    VALUES (@ActualDonorID, @DonationDate, @Amount, @Campaign, 1);

    --3. insert into payment sub-type tables
    IF @CheckNum IS NOT NULL
    BEGIN
        --insert into Checks.
        INSERT INTO Checks (donor_id, date, amount, campaign_name, check_num)
        VALUES (@ActualDonorID, @DonationDate, @Amount, @Campaign, @CheckNum);
    END
    ELSE IF @CardLastDigits IS NOT NULL AND @CardExpDate IS NOT NULL AND @CardType IS NOT NULL
    BEGIN
        --insert into Cards.
        INSERT INTO Cards (donor_id, date, amount, campaign_name, type, last_digits, exp_date)
        VALUES (@ActualDonorID, @DonationDate, @Amount, @Campaign, @CardType, @CardLastDigits, @CardExpDate);
    END
END
GO

-- Q5: Insert a new researcher and associate them with one or more ranger teams.
DROP PROCEDURE IF EXISTS sp_InsertResearcherAndAssociate;
GO
CREATE PROCEDURE sp_InsertResearcherAndAssociate (
    @R_first VARCHAR(40), @R_last VARCHAR(40), @R_DOB DATE, @R_Age INT,
    @R_Gender VARCHAR(20), @R_Street VARCHAR(100), @R_City VARCHAR(50),
    @R_State CHAR(2), @R_Zip VARCHAR(10), @R_Subscribed BIT,
    @Field VARCHAR(40), @Salary DECIMAL(12,2), 
    @TeamID VARCHAR(36),
    @ResearcherID VARCHAR(36) --NEW input ID
)
AS
BEGIN
    --insert into Person 
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
DROP PROCEDURE IF EXISTS sp_InsertRangerTeamReport;
GO
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
DROP PROCEDURE IF EXISTS sp_InsertParkProgram;
GO
CREATE PROCEDURE sp_InsertParkProgram (
    @ParkID VARCHAR(100), @ProgramName VARCHAR(100), @Type VARCHAR(40),
    @StartDate DATE, @EndDate DATE, @Duration INT
)
AS
BEGIN
    -- Program PK: (park_id, name)
    INSERT INTO Program (park_id, name, type, start_date, end_date, duration_hours)
    VALUES (@ParkID, @ProgramName, @Type, @StartDate, @EndDate, @Duration);
END
GO

-- Q8: Retrieve the names and phone numbers of all emergency contacts for a specific person.
DROP PROCEDURE IF EXISTS sp_RetrieveEmergencyContacts;
GO
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
DROP PROCEDURE IF EXISTS sp_RetrieveVisitorsInProgram;
GO
CREATE PROCEDURE sp_RetrieveVisitorsInProgram (
    @ProgramParkID VARCHAR(100), @ProgramName VARCHAR(100)
)
AS
BEGIN
     
    --we check that the visitor is enrolled in the park AND that park hosts the program.
    SELECT P.first, P.last, E.needs
    FROM Person P
    JOIN Enrolls_in E ON P.id = E.id
    WHERE E.park_id = @ProgramParkID 
      AND E.park_id IN (SELECT park_id FROM Program WHERE name = @ProgramName);
END
GO

--Q10: Retrieve all park programs for a specific park that started after a given date.
DROP PROCEDURE IF EXISTS sp_RetrieveProgramsByDate;
GO
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
DROP PROCEDURE IF EXISTS sp_RetrieveAnonymousDonations;
GO
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
DROP PROCEDURE IF EXISTS sp_RetrieveRangersInTeam;
GO
CREATE PROCEDURE sp_RetrieveRangersInTeam (
    @TeamID VARCHAR(36)
)
AS
BEGIN
    SELECT
        P.first, P.last,
        R.years_of_service,
        -- Concatenate certifications (SQL Server specific)
        STUFF((
            SELECT ', ' + C.ranger_certification
            FROM Certifications C
            WHERE C.ranger_id = R.id
            FOR XML PATH('')
        ), 1, 2, '') AS Certifications,
        -- Determine role (Leader or Member)
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
DROP PROCEDURE IF EXISTS sp_RetrieveAllIndividuals;
GO
CREATE PROCEDURE sp_RetrieveAllIndividuals
AS
BEGIN
    SELECT id, first, last, street, city, state, zip_code, subscribed
    FROM Person
    ORDER BY last, first;
END
GO

-- Q14: Update the salary of researchers overseeing more than one ranger team by a 3% increase.
DROP PROCEDURE IF EXISTS sp_UpdateResearcherSalary;
GO
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
DROP PROCEDURE IF EXISTS sp_DeleteExpiredVisitors;
GO
CREATE PROCEDURE sp_DeleteExpiredVisitors
AS
BEGIN
    -- 1. Find visitors to delete
    CREATE TABLE #VisitorsToDelete (id VARCHAR(36));
    INSERT INTO #VisitorsToDelete (id)
    SELECT V.id
    FROM Visitors V
    JOIN Holds H ON V.id = H.visitor_id
    JOIN Park_pass PP ON H.pass_id = PP.pass_id
    LEFT JOIN Enrolls_in E ON V.id = E.id
    WHERE PP.exp_date < GETDATE() -- Pass expired
      AND E.id IS NULL;            -- Not enrolled in any program

    -- 2. Delete dependencies (Holds, then Visitors, then Person)
    DELETE FROM Holds WHERE visitor_id IN (SELECT id FROM #VisitorsToDelete);
    
    DELETE FROM Visitors WHERE id IN (SELECT id FROM #VisitorsToDelete);
    
    --ensure you only delete the Person record if they are only a Visitor
    DELETE FROM Person 
    WHERE id IN (SELECT id FROM #VisitorsToDelete)
      AND is_visitor = 1 
      AND is_ranger = 0 
      AND is_researcher = 0 
      AND is_donor = 0;

    DROP TABLE #VisitorsToDelete;
END
GO