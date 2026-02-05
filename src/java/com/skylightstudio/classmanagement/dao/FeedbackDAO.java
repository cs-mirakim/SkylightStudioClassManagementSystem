package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.Feedback;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class FeedbackDAO {

    // Submit feedback
    public boolean submitFeedback(Feedback feedback) throws SQLException {
        String sql = "INSERT INTO feedback (instructorID, classID, teachingSkill, "
                + "communication, supportInteraction, punctuality, overallRating, "
                + "comments, feedbackDate, submissionTime) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, feedback.getInstructorID());
            stmt.setInt(2, feedback.getClassID());
            stmt.setInt(3, feedback.getTeachingSkill());
            stmt.setInt(4, feedback.getCommunication());
            stmt.setInt(5, feedback.getSupportInteraction());
            stmt.setInt(6, feedback.getPunctuality());
            stmt.setInt(7, feedback.getOverallRating());
            stmt.setString(8, feedback.getComments());
            stmt.setDate(9, new Date(feedback.getFeedbackDate().getTime()));

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    // Get feedback for a specific class
    public List<Feedback> getFeedbackForClass(int classId) throws SQLException {
        List<Feedback> feedbackList = new ArrayList<>();
        String sql = "SELECT * FROM feedback WHERE classID = ? ORDER BY submissionTime DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Feedback feedback = mapResultSetToFeedback(rs);
                feedbackList.add(feedback);
            }
        }
        return feedbackList;
    }

    // Get average rating for an instructor
    public Map<String, Double> getAverageRatingsForInstructor(int instructorId) throws SQLException {
        Map<String, Double> averages = new HashMap<>();
        String sql = "SELECT "
                + "AVG(teachingSkill) as avgTeaching, "
                + "AVG(communication) as avgCommunication, "
                + "AVG(supportInteraction) as avgSupport, "
                + "AVG(punctuality) as avgPunctuality, "
                + "AVG(overallRating) as avgOverall "
                + "FROM feedback WHERE instructorID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                averages.put("teaching", roundToTwoDecimals(rs.getDouble("avgTeaching")));
                averages.put("communication", roundToTwoDecimals(rs.getDouble("avgCommunication")));
                averages.put("support", roundToTwoDecimals(rs.getDouble("avgSupport")));
                averages.put("punctuality", roundToTwoDecimals(rs.getDouble("avgPunctuality")));
                averages.put("overall", roundToTwoDecimals(rs.getDouble("avgOverall")));
            }
        }
        return averages;
    }

    // Check if feedback exists for class and instructor
    public boolean feedbackExists(int classId, int instructorId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM feedback WHERE classID = ? AND instructorID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        }
        return false;
    }

    // Get total feedback count for instructor
    public int getFeedbackCountForInstructor(int instructorId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM feedback WHERE instructorID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }

    // Helper method to map ResultSet to Feedback object
    private Feedback mapResultSetToFeedback(ResultSet rs) throws SQLException {
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
        feedback.setSubmissionTime(rs.getTimestamp("submissionTime"));
        return feedback;
    }

    // Helper method to round to two decimals
    private double roundToTwoDecimals(double value) {
        return Math.round(value * 100.0) / 100.0;
    }
}
