import java.sql.*;
import java.util.Scanner;
import java.io.*;
import java.util.InputMismatchException;

public class Genchev_Encho_IP_Task5b {

    //SQL Server connection information
    final static String HOSTNAME = "genc0000-sql-server.database.windows.net";
    final static String DBNAME = "cs-dsa-4513-sql-db";
    final static String USERNAME = "genc0000";
    final static String PASSWORD = "Maxence01!";

    //connection string
    final static String URL =
        String.format("jdbc:sqlserver://%s:1433;database=%s;user=%s;password=%s;"
        + "encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;"
        + "loginTimeout=30;", HOSTNAME, DBNAME, USERNAME, PASSWORD);

    //menu
    final static String PROMPT =
        "WELCOME TO THE NATIONAL PARK SERVICE SYSTEM DATABASE\n" +
        "(1)  Insert new visitor and enroll (Q1)\n" +
        "(2)  Insert new ranger and assign team (Q2)\n" +
        "(3)  Insert new ranger team and set leader (Q3)\n" +
        "(4)  Insert new donation (Q4)\n" +
        "(5)  Insert new researcher and associate team (Q5)\n" +
        "(6)  Insert report submitted by a ranger team (Q6)\n" +
        "(7)  Insert new park program (Q7)\n" +
        "(8)  Retrieve emergency contacts for a person (Q8)\n" +
        "(9)  Retrieve visitors enrolled in a program (Q9)\n" +
        "(10) Retrieve park programs for a park after a date (Q10)\n" +
        "(11) Retrieve total/average anonymous donations (Q11)\n" +
        "(12) Retrieve rangers in a team with details (Q12)\n" +
        "(13) Retrieve all individuals' contact/newsletter status (Q13)\n" +
        "(14) Update researcher salary (Q14)\n" +
        "(15) Delete un-enrolled visitors with expired passes (Q15)\n" +
        "(16) Import: Enter new teams from a data file\n" +
        "(17) Export: Retrieve mailing list to a data file\n" +
        "(18) Quit (All queries are run as Stored Procedures)\n" +
        "Please select an option: ";
    
    
    
/*
 * BASICALLY ALL THE STATEMENTS GATHER THE REQUIRED INFORMATION IN ORDER
 * TO BE ABLE TO CALL THE STORED PROCEDURE
 * 
 * EACH PROCEDURE EXECUTES ONE OF THE 15 QUERIES 
 * 
 * THIS MAKES THE CODE HERE A LITTLE SHORTER AND MAKES THIS ONLY HAVE TO 
 * FOCUS ON FORMATTING THE QUERY
 */

    public static void main(String[] args) {
        System.out.println("Connecting to Azure SQL Database...");
        
        //testing to see if driver is there
        try {
            //load the SQL Server JDBC driver class
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("Driver loaded successfully.");
        } 
        catch (ClassNotFoundException e) {
            System.out.println("DRIVER NOT FOUND");
            return; //exit if the required driver is unavailable
        }

        final Scanner sc = new Scanner(System.in);
        String option = "";
        
        while (!option.equals("18")) { //until user chooses to quit
            System.out.println(PROMPT);
            try {
                option = sc.nextLine().trim();

                //if connection is successful, the the user can go ahead and pick and option
                try (Connection connection = DriverManager.getConnection(URL)) {
                    System.out.println("Connection successful.");
                    switch (option) {
                    	   //each case has its own associated method
                        case "1":  insertVisitor(connection, sc); break;
                        case "2":  insertRanger(connection, sc); break;
                        case "3":  insertRangerTeam(connection, sc); break;
                        case "4":  insertDonation(connection, sc); break;
                        case "5":  insertResearcher(connection, sc); break;
                        case "6":  insertReport(connection, sc); break;
                        case "7":  insertParkProgram(connection, sc); break;
                        case "8":  retrieveEmergencyContacts(connection, sc); break;
                        case "9":  retrieveVisitorsInProgram(connection, sc); break;
                        case "10": retrieveProgramsByDate(connection, sc); break;
                        case "11": retrieveAnonymousDonations(connection, sc); break;
                        case "12": retrieveRangersInTeam(connection, sc); break;
                        case "13": retrieveAllIndividuals(connection); break;
                        case "14": updateResearcherSalary(connection); break;
                        case "15": deleteExpiredVisitors(connection); break;
                        case "16": importTeamsFromFile(connection, sc); break;
                        case "17": exportMailingListToFile(connection, sc); break;
                        case "18": System.out.println("Bye!."); break;
                        default:   System.out.println("Unrecognized option. Please try again!");
                    }
                } 
                catch (SQLException e) {
                    System.out.println("CONNECTION ERROR"); 
                }

            } 
            catch (InputMismatchException | NumberFormatException e) {
                System.out.println("Invalid input format. Please check your types and try again.");
                sc.nextLine(); //clear buffer
            } 
            catch (Exception e) {
                System.out.println("An unexpected error occurred: " + e.getMessage());
                e.printStackTrace();
            }
        }
        sc.close();
    }

    

    private static void insertVisitor(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q1: Inserting New Visitor");
        try {
        	// getting all the info
            System.out.print("First Name: "); 
            String first = sc.nextLine();
            
            System.out.print("Last Name: "); 
            String last = sc.nextLine();
            
            System.out.print("DOB (YYYY-MM-DD): "); 
            String dob = sc.nextLine();
            
            System.out.print("Age: "); 
            int age = sc.nextInt(); sc.nextLine();
            
            System.out.print("Gender: "); 
            String gender = sc.nextLine();
            
            System.out.print("Street: "); 
            String street = sc.nextLine();
            
            System.out.print("City: "); 
            String city = sc.nextLine();
            
            System.out.print("State (2-char): "); 
            String state = sc.nextLine();
            
            System.out.print("Zip: "); 
            String zip = sc.nextLine();
            
            System.out.print("Subscribe to newsletter? (1=Yes, 0=No): "); 
            int sub = sc.nextInt(); sc.nextLine();
            
            System.out.print("Program Park ID: "); 
            String progParkId = sc.nextLine();
            
            System.out.print("Program Name: "); 
            String progName = sc.nextLine();
            
            System.out.print("Accessibility Needs (or NONE): "); 
            String needs = sc.nextLine();
            
            System.out.print("Visitor ID");
            String visitorId = sc.nextLine();

            //? placeholders
            String sql = "{CALL sp_InsertVisitorAndEnroll(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                
                stmt.setString(1, first); 
                stmt.setString(2, last); 
                stmt.setDate(3, Date.valueOf(dob)); 
                stmt.setInt(4, age);
                stmt.setString(5, gender); 
                stmt.setString(6, street); 
                stmt.setString(7, city); 
                stmt.setString(8, state); 
                stmt.setString(9, zip); 
                stmt.setBoolean(10, sub == 1);
                
                stmt.setString(11, progParkId); 
                stmt.setString(12, needs);
                
                stmt.setString(13, visitorId);
                
                stmt.executeUpdate();
                System.out.println("Success: Visitor inserted (ID: " + visitorId + ") and enrolled.");
            }
        } 
        catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    private static void insertRanger(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q2: Inserting New Ranger");
        try {
        	
        	//getting all the info
            System.out.print("First Name: "); 
            String first = sc.nextLine();
            
            System.out.print("Last Name: "); 
            String last = sc.nextLine();
            System.out.print("DOB (YYYY-MM-DD): "); 
            String dob = sc.nextLine();
            
            System.out.print("Age: "); 
            int age = sc.nextInt(); sc.nextLine();
            
            System.out.print("Gender: "); 
            String gender = sc.nextLine();
            
            System.out.print("Street: "); 
            String street = sc.nextLine();
            
            System.out.print("City: "); 
            String city = sc.nextLine();
            
            System.out.print("State (2-char): "); 
            String state = sc.nextLine();
            
            System.out.print("Zip: "); 
            String zip = sc.nextLine();
            
            System.out.print("Subscribe to newsletter? (1=Yes, 0=No): "); 
            int sub = sc.nextInt(); sc.nextLine();
            
            System.out.print("Team ID to assign: "); 
            String teamID = sc.nextLine();
            
            System.out.print("Ranger ID: ");
            String rangerID = sc.nextLine();
            
            //? placeholders
            String sql = "{CALL sp_InsertRangerAndAssignTeam(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}"; 
            try (CallableStatement stmt = conn.prepareCall(sql)) {
            	
            	
                stmt.setString(1, first); 
                stmt.setString(2, last); 
                stmt.setDate(3, Date.valueOf(dob)); 
                stmt.setInt(4, age);
                stmt.setString(5, gender); 
                stmt.setString(6, street); 
                stmt.setString(7, city); 
                stmt.setString(8, state); 
                stmt.setString(9, zip); 
                stmt.setBoolean(10, sub == 1);
                stmt.setString(11, teamID);
                stmt.setString(12, rangerID);
                
                //running the statement with the updated vlaues
                stmt.executeUpdate();
                System.out.println("Success: Ranger inserted and assigned to team " + teamID);
            }
        } 
        catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    private static void insertRangerTeam(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q3: Inserting New Ranger Team");
        try {
        	//getting all the info
            System.out.print("Team Focus Area: "); 
            String focus = sc.nextLine();
            
            System.out.print("Leader Person/Ranger ID: "); 
            String leaderID = sc.nextLine();
            
            System.out.print("Team ID: ");
            String teamID = sc.nextLine();
            
            //? placeholders
            String sql = "{CALL sp_InsertRangerTeamAndLeader(?, ?, ?)}"; 
            try (CallableStatement stmt = conn.prepareCall(sql)) {
            	
                stmt.setString(1, focus);
                stmt.setString(2, leaderID);
                stmt.setString(3, teamID);
                
                //calling the sql statment
                stmt.executeUpdate();
                System.out.println("Success: New team created with leader " + leaderID);
            }
        } 
        catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
    
    private static void insertDonation(Connection conn, Scanner sc) throws SQLException {
        System.out.println("--- Q4: Inserting New Donation ---");
        try {
        	
            System.out.print("Donor Person ID (Enter 'ANONYMOUS' or leave blank for anonymous): "); 
            String donorID = sc.nextLine();
            if (donorID.isEmpty()) donorID = "ANONYMOUS";
            
            System.out.print("Amount: "); 
            double amount = sc.nextDouble(); 
            sc.nextLine();
            System.out.print("Campaign Name: "); 
            String campaign = sc.nextLine();

            //? placeholders
            String sql = "{CALL sp_InsertDonation(?, ?, ?)}"; 
            try (CallableStatement stmt = conn.prepareCall(sql)) {
            	
                if (donorID.equals("ANONYMOUS")) {
                    stmt.setNull(1, Types.VARCHAR); //set NULL for anonymous
                } 
                else {
                    stmt.setString(1, donorID);
                }
                
                stmt.setDouble(2, amount);
                stmt.setString(3, campaign);
                stmt.executeUpdate();
                System.out.println("Success: Donation of $" + amount + " recorded.");
            }
        } 
        catch (Exception e) {
        	System.out.println("Error: " + e.getMessage());
        }
    }
    
    private static void insertResearcher(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q5: Inserting New Researcher");
        try {
        	//collecting all of the information
            System.out.print("First Name: "); 
            String first = sc.nextLine();
            System.out.print("Last Name: "); 
            String last = sc.nextLine();
            System.out.print("DOB (YYYY-MM-DD): "); 
            String dob = sc.nextLine();
            System.out.print("Age: "); 
            int age = sc.nextInt(); sc.nextLine();
            System.out.print("Gender: "); 
            String gender = sc.nextLine();
            System.out.print("Street: "); 
            String street = sc.nextLine();
            System.out.print("City: "); 
            String city = sc.nextLine();
            System.out.print("State (2-char): "); 
            String state = sc.nextLine();
            System.out.print("Zip: "); 
            String zip = sc.nextLine();
            System.out.print("Subscribe to newsletter? (1=Yes, 0=No): "); 
            int sub = sc.nextInt(); sc.nextLine();
            System.out.print("Researcher id: ");
            String researcherID = sc.nextLine();
            
            System.out.print("Field of Research: "); String field = sc.nextLine();
            System.out.print("Initial Salary: "); double salary = sc.nextDouble(); sc.nextLine();
            System.out.print("Team ID for initial association: "); String teamID = sc.nextLine();
            
            //inserting all of the information into a correctly formatted call to a procedure
            String sql = "{CALL sp_InsertResearcherAndAssociate(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}"; 
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, first); 
                stmt.setString(2, last); 
                stmt.setDate(3, Date.valueOf(dob)); 
                stmt.setInt(4, age);
                stmt.setString(5, gender); 
                stmt.setString(6, street); 
                stmt.setString(7, city); 
                stmt.setString(8, state); 
                stmt.setString(9, zip); 
                stmt.setBoolean(10, sub == 1);
                stmt.setString(11, field);
                stmt.setDouble(12, salary);
                stmt.setString(13, teamID);
                stmt.setString(14, researcherID);
                
                stmt.executeUpdate();
                System.out.println("Success: Researcher inserted and associated with team " + teamID);
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    private static void insertReport(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q6: Inserting Report");
        try {
            System.out.print("Team ID submitting report: "); String teamID = sc.nextLine();
            System.out.print("Researcher ID receiving report: "); String researcherID = sc.nextLine();
            System.out.print("Report Content/Summary: "); String content = sc.nextLine();

            String sql = "{CALL sp_InsertRangerTeamReport(?, ?, ?)}"; 
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, teamID);
                stmt.setString(2, researcherID);
                stmt.setString(3, content);
                stmt.executeUpdate();
                System.out.println("Success: Report submitted.");
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    private static void insertParkProgram(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q7: Inserting New Park Program");
        try {
            System.out.print("Park Name: "); String parkID = sc.nextLine();
            System.out.print("Program Name: "); String progName = sc.nextLine();
            System.out.print("Type: "); String type = sc.nextLine();
            System.out.print("Start Date (YYYY-MM-DD): "); String start = sc.nextLine();
            System.out.print("End Date (YYYY-MM-DD): "); String end = sc.nextLine();
            System.out.print("Duration (Hours): "); int duration = sc.nextInt(); sc.nextLine();

            String sql = "{CALL sp_InsertParkProgram(?, ?, ?, ?, ?, ?)}"; 
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, parkID);
                stmt.setString(2, progName);
                stmt.setString(3, type);
                stmt.setDate(4, Date.valueOf(start));
                stmt.setDate(5, Date.valueOf(end));
                stmt.setInt(6, duration);
                stmt.executeUpdate();
                System.out.println("Success: Program " + progName + " inserted.");
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    private static void retrieveEmergencyContacts(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q8: Retrieve Emergency Contacts");
        System.out.print("Enter the Person ID: ");
        String personID = sc.nextLine();
        
        String sql = "{CALL sp_RetrieveEmergencyContacts(?)}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, personID);
            
            //runs the query and stores the result in rs to be read
            try (ResultSet rs = stmt.executeQuery()) {
                System.out.println("\n Emergency Contacts for ID: " + personID);
                
                //this format puts results in column format
                System.out.printf("%-30s | %-20s\n", "Name", "Phone Number"); 
                
                //since there can be multiple
                while (rs.next()) {
                    System.out.printf("%-30s | %-20s\n", rs.getString("name"), rs.getString("phone_number"));
                }
            }
        }
    }
    
    private static void retrieveVisitorsInProgram(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q9: Retrieve Visitors in Program");
        System.out.print("Enter Program Park ID: "); String parkID = sc.nextLine();
        System.out.print("Enter Program Name: "); String progName = sc.nextLine();
        
        String sql = "{CALL sp_RetrieveVisitorsInProgram(?, ?)}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, parkID);
            stmt.setString(2, progName);
            
            //runs the query and stores the reult in rs to be read
            try (ResultSet rs = stmt.executeQuery()) {
                System.out.println("\n Visitors in " + progName);
                
                //this format puts results in column format
                System.out.printf("%-20s | %-50s\n", "Name", "Accessibility Needs");
                while (rs.next()) {
                    String name = rs.getString("first") + " " + rs.getString("last");
                    
                    //this format puts results in column format
                    System.out.printf("%-20s | %-50s\n", name, rs.getString("needs"));
                }
            }
        }
    }

    private static void retrieveProgramsByDate(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q10: Retrieve Programs by Date");
        System.out.print("Enter Park Name: "); String parkID = sc.nextLine();
        System.out.print("Enter Start Date threshold (YYYY-MM-DD): "); String date = sc.nextLine();
        
        String sql = "{CALL sp_RetrieveProgramsByDate(?, ?)}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, parkID);
            stmt.setDate(2, Date.valueOf(date));
            try (ResultSet rs = stmt.executeQuery()) {
                System.out.println("\n Programs in " + parkID + " starting after " + date);
                
                //this format puts results in column format
                System.out.printf("%-30s | %-10s | %-15s\n", "Name", "Type", "Start Date");
                
                while (rs.next()) {
                	//this format puts results in column format
                    System.out.printf("%-30s | %-10s | %-15s\n", 
                        rs.getString("name"), rs.getString("type"), rs.getDate("start_date"));
                }
            }
        }
    }

    private static void retrieveAnonymousDonations(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q11: Retrieve Anonymous Donations");
        System.out.print("Enter Target Month (1-12): "); int month = sc.nextInt(); sc.nextLine();
        System.out.print("Enter Target Year: "); int year = sc.nextInt(); sc.nextLine();
        
        String sql = "{CALL sp_RetrieveAnonymousDonations(?, ?)}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setInt(1, month);
            stmt.setInt(2, year);
            
            try (ResultSet rs = stmt.executeQuery()) {
       
                System.out.println("\n Anonymous Donation Summary for " + month + "/" + year);
                
                //this format puts results in column format
                System.out.printf("%-15s | %-15s | %-15s\n", "Period", "Total ($)", "Average ($)");
                
                while (rs.next()) { //checls for multiple donations
                    System.out.printf("%-15s | %-15.2f | %-15.2f\n", 
                        rs.getString("DonationPeriod"), rs.getDouble("TotalDonation"), rs.getDouble("AverageDonation"));
                }
            }
        }
    }

    private static void retrieveRangersInTeam(Connection conn, Scanner sc) throws SQLException {
        System.out.println("Q12: Retrieve Rangers in Team");
        System.out.print("Enter Team ID: "); String teamID = sc.nextLine();
        
        String sql = "{CALL sp_RetrieveRangersInTeam(?)}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, teamID);
            try (ResultSet rs = stmt.executeQuery()) {
                System.out.println("\n--- Rangers in Team " + teamID + " ---");
                
                //this format puts results in column format
                System.out.printf("%-20s | %-10s | %-50s | %-10s\n", "Name", "Service (Yrs)", "Certifications", "Role");
                
                while (rs.next()) {
                    String name = rs.getString("first") + " " + rs.getString("last");
                    System.out.printf("%-20s | %-10d | %-50s | %-10s\n", 
                        name, rs.getInt("years_of_service"), rs.getString("Certifications"), rs.getString("TeamRole"));
                }
            }
        }
    }

    private static void retrieveAllIndividuals(Connection conn) throws SQLException {
        System.out.println("Q13: Retrieve All Individuals");
        
        String sql = "{CALL sp_RetrieveAllIndividuals}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                System.out.println("\n All Individuals");
                
                //this format puts results in column format
                System.out.printf("%-35s | %-20s | %-50s | %-15s\n", "ID", "Name", "Address", "Subscribed");
                
                while (rs.next()) { //lists all individuals
                    String name = rs.getString("first") + " " + rs.getString("last");
                    String address = rs.getString("street") + ", " + rs.getString("city") + ", " + rs.getString("state") + " " + rs.getString("zip_code");
                    System.out.printf("%-35s | %-20s | %-50s | %-15s\n", 
                        rs.getString("id"), name, address, rs.getBoolean("subscribed") ? "YES" : "NO");
                }
            }
        }
    }



    private static void updateResearcherSalary(Connection conn) throws SQLException {
        System.out.println("Q14: Updating Researcher Salaries");
        String sql = "{CALL sp_UpdateResearcherSalary}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            int rowsAffected = stmt.executeUpdate();
            System.out.println("Success: Researcher salaries updated (3% increase for those overseeing >1 team). Rows affected: " + rowsAffected);
        }
    }

    private static void deleteExpiredVisitors(Connection conn) throws SQLException {
        System.out.println("Q15: Deleting Expired Visitors");
        String sql = "{CALL sp_DeleteExpiredVisitors}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.executeUpdate();
            System.out.println("Success: Visitors who were not enrolled and had expired passes have been deleted.");
        }
    }

  
    
    //Q16: Import: enter new teams from a csv file
  //Q16: Import: enter new teams from a csv file
    private static void importTeamsFromFile(Connection conn, Scanner sc) throws SQLException, IOException {
        System.out.println("Q16: Import New Teams from File");
        //file format is now FocusArea,LeaderID,TeamID
        System.out.print("Enter input file name (ex: teams.csv). Format: FocusArea,LeaderID,TeamID: "); 
        String fileName = sc.nextLine();
        int teamsImported = 0;

        try (BufferedReader br = new BufferedReader(new FileReader(fileName))) {
            String line;
            //SQL string must have 3 placeholders
            String sql = "{CALL sp_InsertRangerTeamAndLeader(?, ?, ?)}"; 
            try (CallableStatement stmt = conn.prepareCall(sql)) {
            	
                //loops through all rows to import
                while ((line = br.readLine()) != null) {
                    String[] data = line.split(",");
                    //must have 3 data elements now
                    if (data.length < 3) continue; 
                    
                    String focusArea = data[0].trim();
                    String leaderID = data[1].trim();
                    String teamID = data[2].trim(); // New: Get TeamID from CSV

                    stmt.setString(1, focusArea);
                    stmt.setString(2, leaderID);
                    stmt.setString(3, teamID); // Use TeamID from CSV
                    
                    stmt.executeUpdate();
                    teamsImported++;
                }
            }
        } 
        catch (FileNotFoundException e) {
            System.out.println("Error: File not found: " + fileName);
            return;
        }
        System.out.println(teamsImported + " new ranger teams imported successfully from " + fileName);
    }

    //Q17: Export: Retrieve names and mailing addresses of all people on the mailing list
    private static void exportMailingListToFile(Connection conn, Scanner sc) throws SQLException, IOException {
        System.out.println("Q17: Export Mailing List to File");
        System.out.print("Enter output file name (e.g., mailing_list.txt): ");
        String fileName = sc.nextLine();
        
        String query = "SELECT first, last, street, city, state, zip_code FROM Person WHERE subscribed = 1 ORDER BY last, first;";
        
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query);
             FileWriter fw = new FileWriter(fileName);
             PrintWriter pw = new PrintWriter(fw)) {
            
            //write header
            pw.println("Name|Street|City|State|Zip Code");

            int recordsExported = 0;
            while (rs.next()) {
                String name = rs.getString("first") + " " + rs.getString("last");
                String street = rs.getString("street");
                String city = rs.getString("city");
                String state = rs.getString("state");
                String zip = rs.getString("zip_code");
                
                //write data row (pipe-separated)
                pw.printf("%s|%s|%s|%s|%s\n", name, street, city, state, zip);
                recordsExported++;
            }
            System.out.println(recordsExported + " mailing list records exported to " + fileName + " successfully.");
        }
    }