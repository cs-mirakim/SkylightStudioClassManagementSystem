package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.Feedback;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FeedbackDAO {
    
    // SQL Queries - UPDATED to match your database table
    private static final String INSERT_FEEDBACK = 
        "INSERT INTO feedback (instructorID, classID, teachingSkill, communication, " +
        "supportInteraction, punctuality, overallRating, comments, feedbackDate) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    private static final String GET_FEEDBACK_BY_ID = 
        "SELECT * FROM feedback WHERE feedbackID = ?";
    
    private static final String GET_FEEDBACK_BY_INSTRUCTOR = 
        "SELECT * FROM feedback WHERE instructorID = ? ORDER BY feedbackDate DESC";
    
    private static final String GET_FEEDBACK_BY_CLASS = 
        "SELECT * FROM feedback WHERE classID = ? ORDER BY feedbackDate DESC";
    
    private static final String GET_ALL_FEEDBACK = 
        "SELECT * FROM feedback ORDER BY feedbackDate DESC";
    
    private static final String GET_AVERAGE_RATINGS_BY_INSTRUCTOR = 
        "SELECT instructorID, " +
        "AVG(CAST(teachingSkill AS DOUBLE)) as avgTeaching, " +
        "AVG(CAST(communication AS DOUBLE)) as avgCommunication, " +
        "AVG(CAST(supportInteraction AS DOUBLE)) as avgSupport, " +
        "AVG(CAST(punctuality AS DOUBLE)) as avgPunctuality, " +
        "AVG(CAST(overallRating AS DOUBLE)) as avgOverall, " +
        "COUNT(*) as totalFeedbacks " +
        "FROM feedback WHERE instructorID = ? GROUP BY instructorID";
    
    // NEW METHOD: Get average rating for a specific instructor
    private static final String GET_AVERAGE_RATING = 
        "SELECT AVG(CAST(overallRating AS DOUBLE)) as avgRating " +
        "FROM feedback WHERE instructorID = ?";
    
    // NEW METHOD: Get feedback count for instructor
    private static final String GET_FEEDBACK_COUNT = 
        "SELECT COUNT(*) as feedbackCount FROM feedback WHERE instructorID = ?";
    
    // Insert feedback - UPDATED to match new SQL
    public boolean insertFeedback(Feedback feedback) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(INSERT_FEEDBACK);
            
            pstmt.setInt(1, feedback.getInstructorID());
            pstmt.setInt(2, feedback.getClassID());
            pstmt.setInt(3, feedback.getTeachingSkill());
            pstmt.setInt(4, feedback.getCommunication());
            pstmt.setInt(5, feedback.getSupportInteraction());
            pstmt.setInt(6, feedback.getPunctuality());
            pstmt.setInt(7, feedback.getOverallRating());
            
            if (feedback.getComments() != null && !feedback.getComments().trim().isEmpty()) {
                pstmt.setString(8, feedback.getComments());
            } else {
                pstmt.setNull(8, Types.VARCHAR);
            }
            
            pstmt.setDate(9, feedback.getFeedbackDate());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Error inserting feedback: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(pstmt, conn);
        }
    }
    
    // Get feedback by ID
    public Feedback getFeedbackById(int feedbackId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Feedback feedback = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(GET_FEEDBACK_BY_ID);
            pstmt.setInt(1, feedbackId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                feedback = extractFeedbackFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Error getting feedback by ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, pstmt, conn);
        }
        
        return feedback;
    }
    
    // Get all feedback for an instructor
    public List<Feedback> getFeedbackByInstructor(int instructorId) {
        return getFeedbackList(GET_FEEDBACK_BY_INSTRUCTOR, instructorId);
    }
    
    // Get all feedback for a class
    public List<Feedback> getFeedbackByClass(int classId) {
        return getFeedbackList(GET_FEEDBACK_BY_CLASS, classId);
    }
    
    // Get all feedback
    public List<Feedback> getAllFeedback() {
        return getFeedbackList(GET_ALL_FEEDBACK, 0);
    }
    
    // Get feedback summary for an instructor
    public FeedbackSummary getFeedbackSummary(int instructorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        FeedbackSummary summary = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(GET_AVERAGE_RATINGS_BY_INSTRUCTOR);
            pstmt.setInt(1, instructorId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                summary = new FeedbackSummary();
                summary.setInstructorId(instructorId);
                summary.setAvgTeaching(rs.getDouble("avgTeaching"));
                summary.setAvgCommunication(rs.getDouble("avgCommunication"));
                summary.setAvgSupport(rs.getDouble("avgSupport"));
                summary.setAvgPunctuality(rs.getDouble("avgPunctuality"));
                summary.setAvgOverall(rs.getDouble("avgOverall"));
                summary.setTotalFeedbacks(rs.getInt("totalFeedbacks"));
            }
            
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Error getting feedback summary: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, pstmt, conn);
        }
        
        return summary;
    }
    
    // NEW METHOD: Get average rating for instructor
    public double getAverageRatingForInstructor(int instructorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(GET_AVERAGE_RATING);
            pstmt.setInt(1, instructorId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                double avgRating = rs.getDouble("avgRating");
                if (!rs.wasNull()) {
                    return Math.round(avgRating * 10.0) / 10.0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Error getting average rating: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, pstmt, conn);
        }
        return 0.0;
    }
    
    // NEW METHOD: Get feedback count for instructor
    public int getFeedbackCountForInstructor(int instructorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(GET_FEEDBACK_COUNT);
            pstmt.setInt(1, instructorId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("feedbackCount");
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Error getting feedback count: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, pstmt, conn);
        }
        return 0;
    }
    
    // NEW METHOD: Get detailed feedback summary
    public Map<String, Object> getDetailedFeedbackSummary(int instructorId) {
        Map<String, Object> summary = new HashMap<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(GET_AVERAGE_RATINGS_BY_INSTRUCTOR);
            pstmt.setInt(1, instructorId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                summary.put("avgTeaching", rs.getDouble("avgTeaching"));
                summary.put("avgCommunication", rs.getDouble("avgCommunication"));
                summary.put("avgSupport", rs.getDouble("avgSupport"));
                summary.put("avgPunctuality", rs.getDouble("avgPunctuality"));
                summary.put("avgOverall", rs.getDouble("avgOverall"));
                summary.put("totalFeedbacks", rs.getInt("totalFeedbacks"));
                
                // Calculate overall average
                double overallAvg = (rs.getDouble("avgTeaching") + 
                                   rs.getDouble("avgCommunication") + 
                                   rs.getDouble("avgSupport") + 
                                   rs.getDouble("avgPunctuality") + 
                                   rs.getDouble("avgOverall")) / 5.0;
                summary.put("overallAverage", Math.round(overallAvg * 10.0) / 10.0);
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Error getting detailed feedback summary: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, pstmt, conn);
        }
        return summary;
    }
    
    // Helper method to get feedback list
    private List<Feedback> getFeedbackList(String query, int param) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Feedback> feedbackList = new ArrayList<>();
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(query);
            
            if (param > 0) {
                pstmt.setInt(1, param);
            }
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Feedback feedback = extractFeedbackFromResultSet(rs);
                feedbackList.add(feedback);
            }
            
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Error getting feedback list: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, pstmt, conn);
        }
        
        return feedbackList;
    }
    
    // Helper method to extract Feedback from ResultSet
    private Feedback extractFeedbackFromResultSet(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        
        feedback.setFeedbackID(rs.getInt("feedbackID"));
        feedback.setInstructorID(rs.getInt("instructorID"));
        feedback.setClassID(rs.getInt("classID"));
        feedback.setTeachingSkill(rs.getInt("teachingSkill"));
        feedback.setCommunication(rs.getInt("communication"));
        feedback.setSupportInteraction(rs.getInt("supportInteraction"));
        feedback.setPunctuality(rs.getInt("punctuality"));
        feedback.setOverallRating(rs.getInt("overallRating"));
        feedback.setComments(rs.getString("comments"));
        feedback.setFeedbackDate(rs.getDate("feedbackDate"));
        
        // Note: submissionTime column might not exist in your table
        try {
            feedback.setSubmissionTime(rs.getTimestamp("submissionTime"));
        } catch (SQLException e) {
            // Column doesn't exist, ignore
        }
        
        return feedback;
    }
    
    // Helper method to close resources
    private void closeResources(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) DBConnection.closeConnection(conn);
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Error closing resources: " + e.getMessage());
        }
    }
    
    private void closeResources(PreparedStatement pstmt, Connection conn) {
        closeResources(null, pstmt, conn);
    }
    
    // Inner class for feedback summary
    public static class FeedbackSummary {
        private int instructorId;
        private double avgTeaching;
        private double avgCommunication;
        private double avgSupport;
        private double avgPunctuality;
        private double avgOverall;
        private int totalFeedbacks;
        
        // Getters and setters
        public int getInstructorId() { return instructorId; }
        public void setInstructorId(int instructorId) { this.instructorId = instructorId; }
        
        public double getAvgTeaching() { return avgTeaching; }
        public void setAvgTeaching(double avgTeaching) { this.avgTeaching = avgTeaching; }
        
        public double getAvgCommunication() { return avgCommunication; }
        public void setAvgCommunication(double avgCommunication) { this.avgCommunication = avgCommunication; }
        
        public double getAvgSupport() { return avgSupport; }
        public void setAvgSupport(double avgSupport) { this.avgSupport = avgSupport; }
        
        public double getAvgPunctuality() { return avgPunctuality; }
        public void setAvgPunctuality(double avgPunctuality) { this.avgPunctuality = avgPunctuality; }
        
        public double getAvgOverall() { return avgOverall; }
        public void setAvgOverall(double avgOverall) { this.avgOverall = avgOverall; }
        
        public int getTotalFeedbacks() { return totalFeedbacks; }
        public void setTotalFeedbacks(int totalFeedbacks) { this.totalFeedbacks = totalFeedbacks; }
        
        public double getOverallAverage() {
            return (avgTeaching + avgCommunication + avgSupport + avgPunctuality + avgOverall) / 5.0;
        }
        
        @Override
        public String toString() {
            return String.format("FeedbackSummary{instructorId=%d, avgTeaching=%.2f, avgCommunication=%.2f, " +
                               "avgSupport=%.2f, avgPunctuality=%.2f, avgOverall=%.2f, totalFeedbacks=%d}",
                               instructorId, avgTeaching, avgCommunication, avgSupport, 
                               avgPunctuality, avgOverall, totalFeedbacks);
        }
    }
}