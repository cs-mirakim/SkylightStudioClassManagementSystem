package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.Instructor;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InstructorDAO {

    // Hash password using SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = md.digest(password.getBytes());

            // Convert byte array to hexadecimal string
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    // Create new instructor
    public boolean createInstructor(Instructor instructor) throws SQLException {
        String sql = "INSERT INTO instructor (registerID, username, password, name, email, phone, nric, "
                + "profileImageFilePath, BOD, certificationFilePath, yearOfExperience, address) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructor.getRegisterID());
            stmt.setString(2, instructor.getUsername());

            // Hash password before storing
            String hashedPassword = hashPassword(instructor.getPassword());
            stmt.setString(3, hashedPassword);

            stmt.setString(4, instructor.getName());
            stmt.setString(5, instructor.getEmail());
            stmt.setString(6, instructor.getPhone());
            stmt.setString(7, instructor.getNric());
            stmt.setString(8, instructor.getProfileImageFilePath());

            // Handle Date conversion
            if (instructor.getBod() != null) {
                stmt.setDate(9, instructor.getBod());
            } else {
                stmt.setNull(9, Types.DATE);
            }

            stmt.setString(10, instructor.getCertificationFilePath());

            // Handle yearOfExperience
            if (instructor.getYearOfExperience() != null) {
                stmt.setInt(11, instructor.getYearOfExperience());
            } else {
                stmt.setNull(11, Types.INTEGER);
            }

            stmt.setString(12, instructor.getAddress());

            return stmt.executeUpdate() > 0;
        }
    }

    // Get instructor by ID
    public Instructor getInstructorById(int instructorID) throws SQLException {
        String sql = "SELECT * FROM instructor WHERE instructorID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorID);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractInstructorFromResultSet(rs);
            }
            return null;
        }
    }

    // Get instructor by email (NEW METHOD - untuk login)
    public Instructor getInstructorByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM instructor WHERE email = ? AND status = 'active'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractInstructorFromResultSet(rs);
            }
            return null;
        }
    }

    // Get instructor by username (keep for other uses)
    public Instructor getInstructorByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM instructor WHERE username = ? AND status = 'active'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractInstructorFromResultSet(rs);
            }
            return null;
        }
    }

    // Validate login using EMAIL (UPDATED - removed status filter)
    public Instructor validateLogin(String email, String password) throws SQLException {
        String hashedPassword = hashPassword(password);
        // REMOVED: AND status = 'active' dari WHERE clause
        String sql = "SELECT * FROM instructor WHERE email = ? AND password = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            stmt.setString(2, hashedPassword);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractInstructorFromResultSet(rs);
            }
            return null;
        }
    }

    // Get all active instructors
    public List<Instructor> getAllActiveInstructors() throws SQLException {
        String sql = "SELECT * FROM instructor WHERE status = 'active' ORDER BY name";
        List<Instructor> instructors = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                instructors.add(extractInstructorFromResultSet(rs));
            }
        }
        return instructors;
    }

    // Get pending instructors (for admin approval)
    public List<Instructor> getPendingInstructors() throws SQLException {
        String sql = "SELECT i.* FROM instructor i "
                + "JOIN registration r ON i.registerID = r.registerID "
                + "WHERE r.status = 'pending' ORDER BY i.dateJoined";
        List<Instructor> instructors = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                instructors.add(extractInstructorFromResultSet(rs));
            }
        }
        return instructors;
    }

    // Approve instructor
    public boolean approveInstructor(int instructorID, int approvedByAdminID) throws SQLException {
        String sql = "UPDATE instructor SET status = 'active', reviewedBy = ?, reviewedAt = CURRENT_TIMESTAMP "
                + "WHERE instructorID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, approvedByAdminID);
            stmt.setInt(2, instructorID);

            return stmt.executeUpdate() > 0;
        }
    }

    // Update instructor
    public boolean updateInstructor(Instructor instructor) throws SQLException {
        String sql = "UPDATE instructor SET name = ?, email = ?, phone = ?, nric = ?, "
                + "profileImageFilePath = ?, BOD = ?, certificationFilePath = ?, "
                + "yearOfExperience = ?, address = ?, status = ? WHERE instructorID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, instructor.getName());
            stmt.setString(2, instructor.getEmail());
            stmt.setString(3, instructor.getPhone());
            stmt.setString(4, instructor.getNric());
            stmt.setString(5, instructor.getProfileImageFilePath());

            if (instructor.getBod() != null) {
                stmt.setDate(6, instructor.getBod());
            } else {
                stmt.setNull(6, Types.DATE);
            }

            stmt.setString(7, instructor.getCertificationFilePath());

            if (instructor.getYearOfExperience() != null) {
                stmt.setInt(8, instructor.getYearOfExperience());
            } else {
                stmt.setNull(8, Types.INTEGER);
            }

            stmt.setString(9, instructor.getAddress());
            stmt.setString(10, instructor.getStatus());
            stmt.setInt(11, instructor.getInstructorID());

            return stmt.executeUpdate() > 0;
        }
    }

    // Update password
    public boolean updatePassword(int instructorID, String newPassword) throws SQLException {
        String hashedPassword = hashPassword(newPassword);
        String sql = "UPDATE instructor SET password = ? WHERE instructorID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, hashedPassword);
            stmt.setInt(2, instructorID);

            return stmt.executeUpdate() > 0;
        }
    }

    // Helper method to extract Instructor from ResultSet
    private Instructor extractInstructorFromResultSet(ResultSet rs) throws SQLException {
        Instructor instructor = new Instructor();
        instructor.setInstructorID(rs.getInt("instructorID"));
        instructor.setRegisterID(rs.getInt("registerID"));
        instructor.setUsername(rs.getString("username"));
        instructor.setPassword(rs.getString("password"));
        instructor.setName(rs.getString("name"));
        instructor.setEmail(rs.getString("email"));
        instructor.setPhone(rs.getString("phone"));
        instructor.setNric(rs.getString("nric"));
        instructor.setProfileImageFilePath(rs.getString("profileImageFilePath"));
        instructor.setBod(rs.getDate("BOD"));
        instructor.setCertificationFilePath(rs.getString("certificationFilePath"));
        instructor.setYearOfExperience(rs.getInt("yearOfExperience"));
        instructor.setAddress(rs.getString("address"));
        instructor.setStatus(rs.getString("status"));
        instructor.setDateJoined(rs.getTimestamp("dateJoined"));
        instructor.setReviewedBy(rs.getInt("reviewedBy"));
        instructor.setReviewedAt(rs.getTimestamp("reviewedAt"));
        return instructor;
    }

    // Update password by email (for forgot password)
    public boolean updatePasswordByEmail(String email, String newPassword) throws SQLException {
        String hashedPassword = hashPassword(newPassword);
        String sql = "UPDATE instructor SET password = ? WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, hashedPassword);
            stmt.setString(2, email);

            int rows = stmt.executeUpdate();
            System.out.println("[InstructorDAO] Password updated for email " + email + ": " + (rows > 0));
            return rows > 0;
        }
    }
}
