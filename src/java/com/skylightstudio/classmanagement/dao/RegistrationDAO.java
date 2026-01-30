package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.Registration;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RegistrationDAO {

    // Create new registration record
    public int createRegistration(String userType, String adminMessage) throws SQLException {
        String sql = "INSERT INTO registration (userType, status, adminMessage) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, userType);

            // Auto-approve admin, pending for instructor
            String status = userType.equalsIgnoreCase("admin") ? "approved" : "pending";
            stmt.setString(2, status);

            stmt.setString(3, adminMessage);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
            return -1;
        }
    }

    // Get registration by ID
    public Registration getRegistrationById(int registerID) throws SQLException {
        String sql = "SELECT * FROM registration WHERE registerID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, registerID);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Registration registration = new Registration();
                registration.setRegisterID(rs.getInt("registerID"));
                registration.setUserType(rs.getString("userType"));
                registration.setStatus(rs.getString("status"));
                registration.setRegisterDate(rs.getTimestamp("registerDate"));
                registration.setAdminMessage(rs.getString("adminMessage"));
                return registration;
            }
            return null;
        }
    }

    // Update registration status
    public boolean updateRegistrationStatus(int registerID, String status, String adminMessage) throws SQLException {
        String sql = "UPDATE registration SET status = ?, adminMessage = ? WHERE registerID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setString(2, adminMessage);
            stmt.setInt(3, registerID);

            return stmt.executeUpdate() > 0;
        }
    }

    // Get all pending registrations
    public List<Registration> getPendingRegistrations() throws SQLException {
        String sql = "SELECT * FROM registration WHERE status = 'pending' ORDER BY registerDate DESC";
        List<Registration> registrations = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Registration registration = new Registration();
                registration.setRegisterID(rs.getInt("registerID"));
                registration.setUserType(rs.getString("userType"));
                registration.setStatus(rs.getString("status"));
                registration.setRegisterDate(rs.getTimestamp("registerDate"));
                registration.setAdminMessage(rs.getString("adminMessage"));
                registrations.add(registration);
            }
        }
        return registrations;
    }

    // Check if email already exists in any registration
    public boolean isEmailRegistered(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r "
                + "LEFT JOIN admin a ON r.registerID = a.registerID "
                + "LEFT JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE a.email = ? OR i.email = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            stmt.setString(2, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    // Check if username already exists
    public boolean isUsernameTaken(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r "
                + "LEFT JOIN admin a ON r.registerID = a.registerID "
                + "LEFT JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE a.username = ? OR i.username = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setString(2, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    // Check if NRIC already exists
    public boolean isNricTaken(String nric) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r "
                + "LEFT JOIN admin a ON r.registerID = a.registerID "
                + "LEFT JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE a.nric = ? OR i.nric = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nric);
            stmt.setString(2, nric);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }
}
