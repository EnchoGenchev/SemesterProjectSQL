

-- 3. Researcher ID: R103 (Associate with T006)
EXEC sp_InsertResearcherAndAssociate 
    @R_first = 'Emily', 
    @R_last = 'Blunt', 
    @R_DOB = '1990-11-20', 
    @R_Age = 35, 
    @R_Gender = 'Female', 
    @R_Street = '3 Bird Sanctuary', 
    @R_City = 'Seattle', 
    @R_State = 'WA', 
    @R_Zip = '98101', 
    @R_Subscribed = 1, 
    @Field = 'Ornithology', 
    @Salary = 98000.00, 
    @TeamID = 'T006', 
    @ResearcherID = 'R103';
GO

---

-- 4. Researcher ID: R104 (Associate with T007)
EXEC sp_InsertResearcherAndAssociate 
    @R_first = 'Kenji', 
    @R_last = 'Sato', 
    @R_DOB = '1980-02-28', 
    @R_Age = 45, 
    @R_Gender = 'Male', 
    @R_Street = '4 Quake Zone', 
    @R_City = 'San Jose', 
    @R_State = 'CA', 
    @R_Zip = '95101', 
    @R_Subscribed = 0, 
    @Field = 'Geophysics', 
    @Salary = 115000.00, 
    @TeamID = 'T007', 
    @ResearcherID = 'R104';
GO