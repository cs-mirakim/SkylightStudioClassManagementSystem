package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.FeedbackDAO;
import com.skylightstudio.classmanagement.model.Feedback;
import com.skylightstudio.classmanagement.util.SessionUtil;
import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "FeedbackServlet", urlPatterns = {"/submitFeedback"})
public class FeedbackServlet extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== FeedbackServlet.doPost() called ===");

        // Set character encoding
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || !SessionUtil.isLoggedIn(session)) {
            System.out.println("User not logged in, redirecting to login...");
            response.sendRedirect("../general/login.jsp?error=Please+login+to+submit+feedback");
            return;
        }

        System.out.println("User is logged in, proceeding with feedback submission...");

        try {
            // Get parameters from request
            String instructorIDStr = request.getParameter("instructorID");
            String classIDStr = request.getParameter("classID");
            String teachingSkillStr = request.getParameter("teachingSkill");
            String communicationStr = request.getParameter("communication");
            String supportInteractionStr = request.getParameter("supportInteraction");
            String punctualityStr = request.getParameter("punctuality");
            String overallRatingStr = request.getParameter("overallRating");
            String comments = request.getParameter("comments");

            System.out.println("[FeedbackServlet] Received parameters:");
            System.out.println("  instructorID: " + instructorIDStr);
            System.out.println("  classID: " + classIDStr);
            System.out.println("  teachingSkill: " + teachingSkillStr);
            System.out.println("  communication: " + communicationStr);
            System.out.println("  supportInteraction: " + supportInteractionStr);
            System.out.println("  punctuality: " + punctualityStr);
            System.out.println("  overallRating: " + overallRatingStr);
            System.out.println("  comments: " + (comments != null ? "present" : "null"));

            // Validate required fields
            String validationError = validateInput(
                    instructorIDStr, classIDStr, teachingSkillStr, communicationStr,
                    supportInteractionStr, punctualityStr, overallRatingStr, comments
            );

            if (validationError != null) {
                session.setAttribute("feedbackError", validationError);
                response.sendRedirect("../instructor/feedback.jsp?instructorID=" + instructorIDStr
                        + "&classID=" + classIDStr);
                return;
            }

            // Parse parameters
            Integer instructorID = Integer.parseInt(instructorIDStr);
            Integer classID = Integer.parseInt(classIDStr);
            Integer teachingSkill = Integer.parseInt(teachingSkillStr);
            Integer communication = Integer.parseInt(communicationStr);
            Integer supportInteraction = Integer.parseInt(supportInteractionStr);
            Integer punctuality = Integer.parseInt(punctualityStr);
            Integer overallRating = Integer.parseInt(overallRatingStr);

            // Additional validation for rating values
            if (teachingSkill < 1 || teachingSkill > 5 ||
                communication < 1 || communication > 5 ||
                supportInteraction < 1 || supportInteraction > 5 ||
                punctuality < 1 || punctuality > 5 ||
                overallRating < 1 || overallRating > 5) {

                session.setAttribute("feedbackError",
                    "All ratings must be between 1 and 5.");
                response.sendRedirect("../instructor/feedback.jsp?instructorID=" + instructorID +
                         "&classID=" + classID);
                return;
            }

            // Create Feedback object
            Feedback feedback = new Feedback();
            feedback.setInstructorID(instructorID);
            feedback.setClassID(classID);
            feedback.setTeachingSkill(teachingSkill);
            feedback.setCommunication(communication);
            feedback.setSupportInteraction(supportInteraction);
            feedback.setPunctuality(punctuality);
            feedback.setOverallRating(overallRating);
            feedback.setComments(comments);

            // Set feedback date (current date)
            feedback.setFeedbackDate(new Date(System.currentTimeMillis()));
            
            // Set submission time (current timestamp)
            feedback.setSubmissionTime(new Timestamp(System.currentTimeMillis()));

            System.out.println("[FeedbackServlet] Created Feedback object:");
            System.out.println(feedback.toString());

            // Save to database
            boolean success = feedbackDAO.insertFeedback(feedback);

            if (success) {
                // Success - set success message
                session.setAttribute("feedbackSuccess",
                    "Thank you! Your feedback has been submitted successfully.");

                // Redirect to success page or back to dashboard
                response.sendRedirect("../instructor/schedule_instructor.jsp?success=feedback_submitted");
            } else {
                // Database error
                session.setAttribute("feedbackError",
                    "Failed to save feedback. Please try again.");
                response.sendRedirect("../instructor/feedback.jsp?instructorID=" + instructorID
                        + "&classID=" + classID);
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            session.setAttribute("feedbackError",
                "Invalid input format. Please check your ratings (must be numbers 1-5).");
            response.sendRedirect("../instructor/feedback.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("feedbackError",
                "An unexpected error occurred: " + e.getMessage());
            response.sendRedirect("../instructor/feedback.jsp");
        }
    }

    private String validateInput(String instructorID, String classID,
                                 String teachingSkill, String communication,
                                 String supportInteraction, String punctuality,
                                 String overallRating, String comments) {

        StringBuilder error = new StringBuilder();

        // Check required fields
        if (instructorID == null || instructorID.trim().isEmpty()) {
            error.append("Instructor ID is required.<br>");
        }

        if (classID == null || classID.trim().isEmpty()) {
            error.append("Class ID is required.<br>");
        }

        // Check rating fields
        String[] fieldNames = {"Teaching Skills", "Communication", "Support & Interaction",
                              "Punctuality", "Overall Rating"};
        String[] ratingValues = {teachingSkill, communication, supportInteraction,
                                punctuality, overallRating};

        for (int i = 0; i < ratingValues.length; i++) {
            if (ratingValues[i] == null || ratingValues[i].trim().isEmpty()) {
                error.append(fieldNames[i]).append(" is required.<br>");
            } else {
                try {
                    int rating = Integer.parseInt(ratingValues[i].trim());
                    if (rating < 1 || rating > 5) {
                        error.append(fieldNames[i]).append(" must be between 1 and 5.<br>");
                    }
                } catch (NumberFormatException e) {
                    error.append(fieldNames[i]).append(" must be a number.<br>");
                }
            }
        }

        // Check comments length
        if (comments != null && comments.length() > 2000) {
            error.append("Comments cannot exceed 2000 characters.<br>");
        }

        return error.length() > 0 ? error.toString() : null;
    }

    @Override
    public String getServletInfo() {
        return "Servlet for handling feedback submission";
    }
}