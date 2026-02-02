package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.ClassConfirmation;
import com.skylightstudio.classmanagement.model.Class;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.*;
import java.sql.Date;

public class ClassConfirmationDAO {

    public boolean confirmAsMainInstructor(int classId, int instructorId) {
        ClassDAO classDao = new ClassDAO();
        int instructorCount = classDao.countInstructorsForClass(classId);

        if (instructorCount >= 2) {
            return false;
        }

        if (classDao.isInstructorInClass(classId, instructorId)) {
            return false;
        }

        Class cls = classDao.getClassById(classId);
        if (cls == null || !"active".equals(cls.getClassStatus())) {
            return false;
        }

        String sql = "INSERT INTO class_confirmation (classID, instructorID, action, actionAt) "
                + "VALUES (?, ?, 'confirmed', CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean requestAsReliefInstructor(int classId, int instructorId) {
        ClassDAO classDao = new ClassDAO();
        int instructorCount = classDao.countInstructorsForClass(classId);

        if (instructorCount >= 2) {
            return false;
        }

        if (classDao.isInstructorInClass(classId, instructorId)) {
            return false;
        }

        Map<String, Object> classDetails = classDao.getClassWithInstructors(classId);
        if (classDetails == null || !classDetails.containsKey("mainInstructor")) {
            return false;
        }

        Class cls = classDao.getClassById(classId);
        if (cls == null || !"active".equals(cls.getClassStatus())) {
            return false;
        }

        String sql = "INSERT INTO class_confirmation (classID, instructorID, action, actionAt) "
                + "VALUES (?, ?, 'pending', CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean withdrawFromClass(int classId, int instructorId) {
        ClassConfirmation current = getLatestConfirmation(classId, instructorId);
        if (current == null) {
            return false;
        }

        String currentAction = current.getAction();

        if ("confirmed".equals(currentAction)) {
            promoteReliefToMain(classId);
        }

        String sql = "UPDATE class_confirmation SET action = 'cancelled', "
                + "cancelledAt = CURRENT_TIMESTAMP, "
                + "cancellationReason = 'Instructor withdrew' "
                + "WHERE classID = ? AND instructorID = ? AND action IN ('confirmed', 'pending')";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public void promoteReliefToMain(int classId) {
        String getReliefSql = "SELECT instructorID FROM class_confirmation "
                + "WHERE classID = ? AND action = 'pending' "
                + "ORDER BY actionAt ASC FETCH FIRST 1 ROWS ONLY";

        String updateSql = "UPDATE class_confirmation SET action = 'confirmed', "
                + "actionAt = CURRENT_TIMESTAMP "
                + "WHERE classID = ? AND instructorID = ? AND action = 'pending'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement getStmt = conn.prepareStatement(getReliefSql);
                PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {

            getStmt.setInt(1, classId);
            ResultSet rs = getStmt.executeQuery();

            if (rs.next()) {
                int reliefInstructorId = rs.getInt("instructorID");

                updateStmt.setInt(1, classId);
                updateStmt.setInt(2, reliefInstructorId);
                updateStmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public ClassConfirmation getLatestConfirmation(int classId, int instructorId) {
        String sql = "SELECT * FROM class_confirmation "
                + "WHERE classID = ? AND instructorID = ? "
                + "ORDER BY actionAt DESC FETCH FIRST 1 ROWS ONLY";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                ClassConfirmation cc = new ClassConfirmation();
                cc.setConfirmID(rs.getInt("confirmID"));
                cc.setClassID(rs.getInt("classID"));
                cc.setInstructorID(rs.getInt("instructorID"));
                cc.setAction(rs.getString("action"));
                cc.setActionAt(rs.getTimestamp("actionAt"));
                cc.setCancellationReason(rs.getString("cancellationReason"));
                cc.setCancelledAt(rs.getTimestamp("cancelledAt"));
                return cc;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ClassConfirmation> getConfirmationsForClass(int classId) {
        List<ClassConfirmation> confirmations = new ArrayList<>();
        String sql = "SELECT cc.*, i.name FROM class_confirmation cc "
                + "JOIN instructor i ON cc.instructorID = i.instructorID "
                + "WHERE cc.classID = ? "
                + "ORDER BY cc.actionAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ClassConfirmation cc = new ClassConfirmation();
                cc.setConfirmID(rs.getInt("confirmID"));
                cc.setClassID(rs.getInt("classID"));
                cc.setInstructorID(rs.getInt("instructorID"));
                cc.setAction(rs.getString("action"));
                cc.setActionAt(rs.getTimestamp("actionAt"));
                cc.setCancellationReason(rs.getString("cancellationReason"));
                cc.setCancelledAt(rs.getTimestamp("cancelledAt"));
                confirmations.add(cc);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return confirmations;
    }

    public String getInstructorStatus(int classId, int instructorId) {
        ClassConfirmation cc = getLatestConfirmation(classId, instructorId);
        if (cc == null) {
            return null;
        }

        if ("cancelled".equals(cc.getAction())) {
            return null;
        }
        return cc.getAction();
    }

    // Tambahkan method ini di ClassConfirmationDAO.java
    public List<Map<String, Object>> getCancelledClasses() throws SQLException {
        String sql = "SELECT cc.*, i.name as instructorName, i.email as instructorEmail, "
                + "c.className, c.classType, c.classLevel, c.classDate, "
                + "c.classStartTime, c.classEndTime, c.location "
                + "FROM class_confirmation cc "
                + "JOIN instructor i ON cc.instructorID = i.instructorID "
                + "JOIN class c ON cc.classID = c.classID "
                + "WHERE cc.action = 'cancelled' "
                + "ORDER BY cc.cancelledAt DESC";

        List<Map<String, Object>> cancelledClasses = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> cancelledClass = new HashMap<>();
                cancelledClass.put("confirmID", rs.getInt("confirmID"));
                cancelledClass.put("classID", rs.getInt("classID"));
                cancelledClass.put("instructorID", rs.getInt("instructorID"));
                cancelledClass.put("instructorName", rs.getString("instructorName"));
                cancelledClass.put("instructorEmail", rs.getString("instructorEmail"));
                cancelledClass.put("className", rs.getString("className"));
                cancelledClass.put("classType", rs.getString("classType"));
                cancelledClass.put("classLevel", rs.getString("classLevel"));
                cancelledClass.put("classDate", rs.getDate("classDate"));
                cancelledClass.put("classStartTime", rs.getTime("classStartTime"));
                cancelledClass.put("classEndTime", rs.getTime("classEndTime"));
                cancelledClass.put("location", rs.getString("location"));
                cancelledClass.put("cancellationReason", rs.getString("cancellationReason"));
                cancelledClass.put("cancelledAt", rs.getTimestamp("cancelledAt"));
                cancelledClass.put("actionAt", rs.getTimestamp("actionAt"));

                cancelledClasses.add(cancelledClass);
            }
        }
        return cancelledClasses;
    }

    // Add these methods to ClassConfirmationDAO.java
// Get completed relief classes for instructor
    public List<Map<String, Object>> getCompletedReliefClasses(int instructorId) throws SQLException {
        List<Map<String, Object>> reliefClasses = new ArrayList<>();

        String sql = "SELECT c.classID, c.className, c.classType, c.classDate, "
                + "c.classStartTime, c.classEndTime, c.location, "
                + "cc.actionAt as confirmationDate, "
                + "(SELECT COUNT(*) FROM booking b WHERE b.classID = c.classID) as studentsAttended, "
                + "(SELECT AVG(f.rating) FROM feedback f WHERE f.classID = c.classID) as avgRating "
                + "FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? "
                + "AND cc.action = 'confirmed' "
                + "AND c.classStatus = 'completed' "
                + "AND c.classDate < CURRENT_DATE "
                + "ORDER BY c.classDate DESC "
                + "FETCH FIRST 5 ROWS ONLY";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> relief = new HashMap<>();
                relief.put("className", rs.getString("className"));
                relief.put("classDate", rs.getDate("classDate"));
                relief.put("classStartTime", rs.getTime("classStartTime"));
                relief.put("location", rs.getString("location"));
                relief.put("studentsAttended", rs.getInt("studentsAttended"));

                double avgRating = rs.getDouble("avgRating");
                if (!rs.wasNull()) {
                    relief.put("rating", Math.round(avgRating * 10.0) / 10.0);
                } else {
                    relief.put("rating", "No ratings yet");
                }

                reliefClasses.add(relief);
            }
        }
        return reliefClasses;
    }

// Get pending relief positions for instructor
    public List<Map<String, Object>> getPendingReliefPositions(int instructorId) throws SQLException {
        List<Map<String, Object>> pendingPositions = new ArrayList<>();

        String sql = "SELECT c.classID, c.className, "
                + "(SELECT COUNT(*) FROM class_confirmation cc2 WHERE cc2.classID = c.classID AND cc2.action = 'pending' AND cc2.actionAt < cc.actionAt) + 1 as position, "
                + "(SELECT i.name FROM class_confirmation cc3 JOIN instructor i ON cc3.instructorID = i.instructorID WHERE cc3.classID = c.classID AND cc3.action = 'pending' ORDER BY cc3.actionAt ASC FETCH FIRST 1 ROW ONLY) as firstInLine "
                + "FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? "
                + "AND cc.action = 'pending' "
                + "AND c.classDate >= CURRENT_DATE "
                + "ORDER BY c.classDate, cc.actionAt";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> position = new HashMap<>();
                position.put("className", rs.getString("className"));
                position.put("position", rs.getInt("position"));
                position.put("firstInLine", rs.getString("firstInLine"));
                pendingPositions.add(position);
            }
        }
        return pendingPositions;
    }

// Get weekly summary statistics
    public Map<String, Object> getWeeklySummary(int instructorId, Date startDate, Date endDate) throws SQLException {
        Map<String, Object> summary = new HashMap<>();

        String sql = "SELECT "
                + "COUNT(CASE WHEN cc.action = 'confirmed' THEN 1 END) as confirmedClasses, "
                + "COUNT(CASE WHEN cc.action = 'pending' THEN 1 END) as pendingClasses "
                + "FROM class_confirmation cc "
                + "JOIN class c ON cc.classID = c.classID "
                + "WHERE cc.instructorID = ? "
                + "AND c.classDate BETWEEN ? AND ? "
                + "AND c.classStatus = 'active'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            stmt.setDate(2, startDate);
            stmt.setDate(3, endDate);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                summary.put("confirmedClasses", rs.getInt("confirmedClasses"));
                summary.put("pendingClasses", rs.getInt("pendingClasses"));
            }
        }
        return summary;
    }
}
