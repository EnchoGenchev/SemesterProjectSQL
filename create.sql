-- Now drop the dependent tables
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


-- Create tables (entity and relation tables as previously adjusted)
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
