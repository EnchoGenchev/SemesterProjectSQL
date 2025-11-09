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