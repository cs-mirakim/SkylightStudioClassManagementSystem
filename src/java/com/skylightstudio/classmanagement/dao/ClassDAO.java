package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.Class;
import com.skylightstudio.classmanagement.model.ClassConfirmation;
import com.skylightstudio.classmanagement.model.Instructor;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.*;

public class ClassDAO {
    
    // Get ALL classes that should appear for an instructor
    public List<Class> getClassesForInstructor(int instructorId) {
        List<Class> classes = new ArrayList<>();
        String sql = "SELECT c.* FROM class c " +
                    "WHERE c.classStatus = 'active' " +
                    "AND c.classDate >= CURRENT_DATE " +
                    "ORDER BY c.classDate, c.classStartTime";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Class cls = mapResultSetToClass(rs);
                classes.add(cls);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return classes;
    }
    
    // Get class by ID
    public Class getClassById(int classId) {
        String sql = "SELECT * FROM class WHERE classID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToClass(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Count instructors for a class
    public int countInstructorsForClass(int classId) {
        String sql = "SELECT COUNT(DISTINCT instructorID) as count FROM class_confirmation " +
                    "WHERE classID = ? AND action IN ('confirmed', 'pending')";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Check if instructor is already in class
    public boolean isInstructorInClass(int classId, int instructorId) {
        String sql = "SELECT COUNT(*) as count FROM class_confirmation " +
                    "WHERE classID = ? AND instructorID = ? AND action IN ('confirmed', 'pending')";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Check instructor's status in a class
    public String getInstructorStatusInClass(int classId, int instructorId) {
        String sql = "SELECT action FROM class_confirmation " +
                    "WHERE classID = ? AND instructorID = ? " +
                    "AND action IN ('confirmed', 'pending') " +
                    "ORDER BY actionAt DESC FETCH FIRST 1 ROWS ONLY";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("action");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Update class status
    public boolean updateClassStatus(int classId, String status) {
        String sql = "UPDATE class SET classStatus = ? WHERE classID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, classId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get classes that need auto-cancellation (24-hour rule)
    public List<Class> getClassesForAutoCancellation() {
        List<Class> classes = new ArrayList<>();
        String sql = "SELECT c.* FROM class c " +
                    "WHERE c.classStatus = 'active' " +
                    "AND (TIMESTAMP(c.classDate, c.classStartTime) < CURRENT_TIMESTAMP + 24 HOURS) " +
                    "AND NOT EXISTS (SELECT 1 FROM class_confirmation cc " +
                    "               WHERE cc.classID = c.classID AND cc.action = 'confirmed')";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Class cls = mapResultSetToClass(rs);
                classes.add(cls);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return classes;
    }
    
    // Get class with instructor details
    public Map<String, Object> getClassWithInstructors(int classId) {
        Map<String, Object> result = new HashMap<>();
        
        // Get class details
        Class cls = getClassById(classId);
        if (cls == null) return null;
        
        result.put("class", cls);
        
        // Get main instructor (confirmed)
        String mainSql = "SELECT cc.*, i.name FROM class_confirmation cc " +
                        "JOIN instructor i ON cc.instructorID = i.instructorID " +
                        "WHERE cc.classID = ? AND cc.action = 'confirmed' " +
                        "ORDER BY cc.actionAt DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(mainSql)) {
            
            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                ClassConfirmation main = new ClassConfirmation();
                main.setConfirmID(rs.getInt("confirmID"));
                main.setClassID(rs.getInt("classID"));
                main.setInstructorID(rs.getInt("instructorID"));
                main.setAction(rs.getString("action"));
                main.setActionAt(rs.getTimestamp("actionAt"));
                
                // Create a map for instructor details
                Map<String, Object> mainInstructor = new HashMap<>();
                mainInstructor.put("id", rs.getInt("instructorID"));
                mainInstructor.put("name", rs.getString("name"));
                mainInstructor.put("initials", getInitials(rs.getString("name")));
                result.put("mainInstructor", mainInstructor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        // Get relief instructor (pending)
        String reliefSql = "SELECT cc.*, i.name FROM class_confirmation cc " +
                          "JOIN instructor i ON cc.instructorID = i.instructorID " +
                          "WHERE cc.classID = ? AND cc.action = 'pending' " +
                          "ORDER BY cc.actionAt ASC"; // First come first served
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(reliefSql)) {
            
            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                ClassConfirmation relief = new ClassConfirmation();
                relief.setConfirmID(rs.getInt("confirmID"));
                relief.setClassID(rs.getInt("classID"));
                relief.setInstructorID(rs.getInt("instructorID"));
                relief.setAction(rs.getString("action"));
                relief.setActionAt(rs.getTimestamp("actionAt"));
                
                // Create a map for instructor details
                Map<String, Object> reliefInstructor = new HashMap<>();
                reliefInstructor.put("id", rs.getInt("instructorID"));
                reliefInstructor.put("name", rs.getString("name"));
                reliefInstructor.put("initials", getInitials(rs.getString("name")));
                result.put("reliefInstructor", reliefInstructor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return result;
    }
    
    // Helper method to get initials
    private String getInitials(String name) {
        if (name == null || name.trim().isEmpty()) return "??";
        String[] parts = name.split(" ");
        if (parts.length >= 2) {
            return (parts[0].charAt(0) + "" + parts[parts.length - 1].charAt(0)).toUpperCase();
        }
        return name.substring(0, Math.min(2, name.length())).toUpperCase();
    }
    
    // Helper method to map ResultSet to Class object
    private Class mapResultSetToClass(ResultSet rs) throws SQLException {
        Class cls = new Class();
        cls.setClassID(rs.getInt("classID"));
        cls.setClassName(rs.getString("className"));
        cls.setClassType(rs.getString("classType"));
        cls.setClassLevel(rs.getString("classLevel"));
        cls.setClassDate(rs.getDate("classDate"));
        cls.setClassStartTime(rs.getTime("classStartTime"));
        cls.setClassEndTime(rs.getTime("classEndTime"));
        cls.setNoOfParticipant(rs.getInt("noOfParticipant"));
        cls.setLocation(rs.getString("location"));
        cls.setDescription(rs.getString("description"));
        cls.setClassStatus(rs.getString("classStatus"));
        cls.setQrcodeFilePath(rs.getString("qrcodeFilePath"));
        cls.setAdminID(rs.getInt("adminID"));
        return cls;
    }
}