package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.InstructorDAO;
import com.skylightstudio.classmanagement.dao.RegistrationDAO;
import com.skylightstudio.classmanagement.dao.ClassConfirmationDAO;
import com.skylightstudio.classmanagement.dao.FeedbackDAO;
import com.skylightstudio.classmanagement.dao.ClassDAO;
import com.skylightstudio.classmanagement.model.Class;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin/monitor-instructor")
public class MonitorInstructorServlet extends HttpServlet {

    private InstructorDAO instructorDAO;
    private RegistrationDAO registrationDAO;
    private ClassConfirmationDAO classConfirmationDAO;
    private FeedbackDAO feedbackDAO;
    private ClassDAO classDAO;

    @Override
    public void init() throws ServletException {
        instructorDAO = new InstructorDAO();
        registrationDAO = new RegistrationDAO();
        classConfirmationDAO = new ClassConfirmationDAO();
        feedbackDAO = new FeedbackDAO();
        classDAO = new ClassDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        System.out.println("=== DEBUG doGet ===");
        System.out.println("Action: " + action);
        System.out.println("Request URI: " + request.getRequestURI());

        try {
            if ("list".equals(action)) {
                getAllInstructors(response);
            } else if ("details".equals(action)) {
                getInstructorDetails(request, response);
            } else if ("stats".equals(action)) {
                getStats(response);
            } else if ("performance".equals(action)) {
                getPerformanceData(request, response);
            } else if ("completePerformance".equals(action)) {
                System.out.println("✅ Calling getCompletePerformanceData()");
                getCompletePerformanceData(request, response);
            } else if ("checkClasses".equals(action)) {
                checkInstructorClasses(request, response);
            } else if ("getAvailableYears".equals(action)) {
                getAvailableYears(request, response);
            } else {
                request.getRequestDispatcher("/admin/monitor_instructor.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            System.err.println("❌ SQL ERROR in doGet:");
            System.err.println("Action: " + action);
            System.err.println("Error Message: " + e.getMessage());
            e.printStackTrace();

            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error>");
            out.print("<message>" + escapeXml(e.getMessage()) + "</message>");
            out.print("</error>");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            System.err.println("❌ GENERAL ERROR in doGet:");
            System.err.println("Action: " + action);
            System.err.println("Error Message: " + e.getMessage());
            e.printStackTrace();

            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error>");
            out.print("<message>" + escapeXml(e.getMessage()) + "</message>");
            out.print("</error>");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void getAllInstructors(HttpServletResponse response) throws SQLException, IOException {
        List<Map<String, Object>> instructorRegistrations = registrationDAO.getAllInstructorRegistrations();

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<instructors>");
        for (Map<String, Object> instructor : instructorRegistrations) {
            out.print("<instructor>");
            out.print("<id>" + instructor.get("instructorID") + "</id>");
            out.print("<name>" + escapeXml(instructor.get("name").toString()) + "</name>");
            out.print("<email>" + escapeXml(instructor.get("email").toString()) + "</email>");
            out.print("<experience>" + getExperienceString(instructor.get("yearOfExperience")) + "</experience>");

            String profileImage = (String) instructor.get("profileImageFilePath");
            if (profileImage != null && !profileImage.isEmpty() && !profileImage.equals("null")) {
                if (!profileImage.startsWith("../")) {
                    profileImage = "../" + profileImage;
                }
                out.print("<profileImage>" + escapeXml(profileImage) + "</profileImage>");
            } else {
                out.print("<profileImage>../profile_pictures/instructor/dummy.png</profileImage>");
            }

            Object dateJoined = instructor.get("dateJoined");
            if (dateJoined != null) {
                out.print("<dateJoined>" + formatDate(dateJoined) + "</dateJoined>");
            } else {
                out.print("<dateJoined>Not available</dateJoined>");
            }

            out.print("<status>" + escapeXml(instructor.get("instructorStatus").toString()) + "</status>");
            out.print("<registrationStatus>" + escapeXml(instructor.get("registrationStatus").toString()) + "</registrationStatus>");
            out.print("</instructor>");
        }
        out.print("</instructors>");
    }

    private void getInstructorDetails(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int instructorId = Integer.parseInt(request.getParameter("id"));

        com.skylightstudio.classmanagement.model.Instructor instructor = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Instructor not found");
            return;
        }

        com.skylightstudio.classmanagement.model.Registration registration
                = registrationDAO.getRegistrationById(instructor.getRegisterID());

        int totalConfirmedClasses = classConfirmationDAO.countConfirmedClassesForInstructor(instructorId);
        int cancelledClasses = classConfirmationDAO.countCancelledClassesForInstructor(instructorId);
        int completedClasses = totalConfirmedClasses - cancelledClasses;

        Map<String, Double> averageRatings = feedbackDAO.getAverageRatingsForInstructor(instructorId);

        double avgTeaching = averageRatings.getOrDefault("teaching", 0.0);
        double avgCommunication = averageRatings.getOrDefault("communication", 0.0);
        double avgSupport = averageRatings.getOrDefault("support", 0.0);
        double avgPunctuality = averageRatings.getOrDefault("punctuality", 0.0);
        double avgOverallRating = averageRatings.getOrDefault("overall", 0.0);

        double totalAllRatings = avgTeaching + avgCommunication + avgSupport + avgPunctuality + avgOverallRating;
        double averageAllRatings = totalAllRatings / 5.0;

        if (Double.isNaN(averageAllRatings) || Double.isInfinite(averageAllRatings)) {
            averageAllRatings = 0.0;
        }

        int feedbackCount = feedbackDAO.getFeedbackCountForInstructor(instructorId);

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<details>");

        out.print("<name>" + escapeXml(instructor.getName()) + "</name>");
        out.print("<email>" + escapeXml(instructor.getEmail()) + "</email>");
        out.print("<phone>" + escapeXml(instructor.getPhone()) + "</phone>");
        out.print("<nric>" + escapeXml(instructor.getNric()) + "</nric>");

        if (instructor.getBod() != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMMM yyyy");
            out.print("<bod>" + sdf.format(instructor.getBod()) + "</bod>");
        } else {
            out.print("<bod>Not specified</bod>");
        }

        if (instructor.getDateJoined() != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
            out.print("<dateJoined>" + sdf.format(instructor.getDateJoined()) + "</dateJoined>");
        } else {
            out.print("<dateJoined>Not available</dateJoined>");
        }

        out.print("<experience>" + getExperienceString(instructor.getYearOfExperience()) + "</experience>");
        out.print("<address>" + escapeXml(instructor.getAddress()) + "</address>");
        out.print("<instructorStatus>" + escapeXml(instructor.getStatus()) + "</instructorStatus>");

        if (registration != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy hh:mm a");
            out.print("<regDate>" + sdf.format(registration.getRegisterDate()) + "</regDate>");
            out.print("<regStatus>" + escapeXml(registration.getStatus()) + "</regStatus>");
            out.print("<userType>" + escapeXml(registration.getUserType()) + "</userType>");
        }

        out.print("<totalClasses>" + totalConfirmedClasses + "</totalClasses>");
        out.print("<cancelledClasses>" + cancelledClasses + "</cancelledClasses>");
        out.print("<completedClasses>" + completedClasses + "</completedClasses>");

        out.print("<avgTeaching>" + String.format("%.1f", avgTeaching) + "</avgTeaching>");
        out.print("<avgCommunication>" + String.format("%.1f", avgCommunication) + "</avgCommunication>");
        out.print("<avgSupport>" + String.format("%.1f", avgSupport) + "</avgSupport>");
        out.print("<avgPunctuality>" + String.format("%.1f", avgPunctuality) + "</avgPunctuality>");

        out.print("<overallRating>" + String.format("%.1f", averageAllRatings) + "</overallRating>");
        out.print("<averageAllRatings>" + String.format("%.1f", averageAllRatings) + "</averageAllRatings>");
        out.print("<feedbackCount>" + feedbackCount + "</feedbackCount>");

        String profileImage = instructor.getProfileImageFilePath();
        if (profileImage != null && !profileImage.isEmpty() && !profileImage.equals("null")) {
            if (!profileImage.startsWith("../")) {
                profileImage = "../" + profileImage;
            }
            out.print("<profileImage>" + escapeXml(profileImage) + "</profileImage>");
        } else {
            out.print("<profileImage>../profile_pictures/instructor/dummy.png</profileImage>");
        }

        String certification = instructor.getCertificationFilePath();
        System.out.println("DEBUG - Original certification path: " + certification);

        if (certification != null && !certification.isEmpty() && !certification.equals("null")) {
            certification = certification.trim();
            if (!certification.startsWith("../") && !certification.startsWith("/")) {
                certification = "../" + certification;
            }
            certification = certification.replace("//", "/");

            System.out.println("DEBUG - Processed certification path: " + certification);

            out.print("<certification>" + escapeXml(certification) + "</certification>");

            String fileName = getFileNameFromPath(certification);
            out.print("<certificationFileName>" + escapeXml(fileName) + "</certificationFileName>");
        } else {
            System.out.println("DEBUG - No certification found, using dummy");
            out.print("<certification>../certifications/instructor/dummy.pdf</certification>");
            out.print("<certificationFileName>dummy.pdf</certificationFileName>");
        }

        out.print("</details>");
    }

    private String getFileNameFromPath(String path) {
        if (path == null || path.isEmpty()) {
            return "No file";
        }
        String[] parts = path.split("/");
        return parts[parts.length - 1];
    }

    private void getStats(HttpServletResponse response) throws SQLException, IOException {
        List<Map<String, Object>> instructors = registrationDAO.getAllInstructorRegistrations();

        int activeCount = 0;
        int inactiveCount = 0;
        int newThisMonth = 0;
        double totalOverallRating = 0;
        int ratedCount = 0;

        java.util.Calendar cal = java.util.Calendar.getInstance();
        int currentMonth = cal.get(java.util.Calendar.MONTH) + 1;
        int currentYear = cal.get(java.util.Calendar.YEAR);

        for (Map<String, Object> instructor : instructors) {
            String status = instructor.get("instructorStatus").toString();

            if ("active".equals(status)) {
                activeCount++;
            } else {
                inactiveCount++;
            }

            java.sql.Timestamp dateJoined = (java.sql.Timestamp) instructor.get("dateJoined");
            if (dateJoined != null) {
                cal.setTime(dateJoined);
                int joinMonth = cal.get(java.util.Calendar.MONTH) + 1;
                int joinYear = cal.get(java.util.Calendar.YEAR);

                if (joinMonth == currentMonth && joinYear == currentYear) {
                    newThisMonth++;
                }
            }

            Integer instructorId = (Integer) instructor.get("instructorID");
            Map<String, Double> ratings = feedbackDAO.getAverageRatingsForInstructor(instructorId);

            double teaching = ratings.getOrDefault("teaching", 0.0);
            double communication = ratings.getOrDefault("communication", 0.0);
            double support = ratings.getOrDefault("support", 0.0);
            double punctuality = ratings.getOrDefault("punctuality", 0.0);
            double overall = ratings.getOrDefault("overall", 0.0);

            double averageAllRatings = (teaching + communication + support + punctuality + overall) / 5.0;

            if (averageAllRatings > 0) {
                totalOverallRating += averageAllRatings;
                ratedCount++;
            }
        }

        double avgRating = ratedCount > 0 ? totalOverallRating / ratedCount : 0;

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<stats>");
        out.print("<active>" + activeCount + "</active>");
        out.print("<inactive>" + inactiveCount + "</inactive>");
        out.print("<newThisMonth>" + newThisMonth + "</newThisMonth>");
        out.print("<avgOverallRating>" + String.format("%.1f", avgRating) + "</avgOverallRating>");
        out.print("</stats>");
    }

    private void getPerformanceData(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int instructorId = Integer.parseInt(request.getParameter("id"));
        String period = request.getParameter("period");

        if (period == null || period.trim().isEmpty()) {
            period = "all";
        }

        com.skylightstudio.classmanagement.model.Instructor instructor
                = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Instructor not found");
            return;
        }

        int totalClasses = classConfirmationDAO.countConfirmedClassesForInstructor(instructorId);
        int cancelledClasses = classConfirmationDAO.countCancelledClassesForInstructor(instructorId);
        int completedClasses = totalClasses - cancelledClasses;
        double completionRate = totalClasses > 0 ? (completedClasses * 100.0 / totalClasses) : 0;

        Map<String, Double> averageRatings = feedbackDAO.getAverageRatingsForInstructor(instructorId);
        double overall = averageRatings.getOrDefault("overall", 0.0);
        double teaching = averageRatings.getOrDefault("teaching", 0.0);
        double communication = averageRatings.getOrDefault("communication", 0.0);
        double support = averageRatings.getOrDefault("support", 0.0);
        double punctuality = averageRatings.getOrDefault("punctuality", 0.0);

        double correctOverallRating = (teaching + communication + support + punctuality + overall) / 5.0;
        if (Double.isNaN(correctOverallRating) || Double.isInfinite(correctOverallRating)) {
            correctOverallRating = 0.0;
        }

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<performance>");
        out.print("<instructorName>" + escapeXml(instructor.getName()) + "</instructorName>");
        out.print("<overallRating>" + String.format("%.1f", correctOverallRating) + "</overallRating>");
        out.print("<totalClasses>" + totalClasses + "</totalClasses>");
        out.print("<cancelled>" + cancelledClasses + "</cancelled>");
        out.print("<completion>" + String.format("%.0f", completionRate) + "%</completion>");
        out.print("<teaching>" + String.format("%.1f", teaching) + "</teaching>");
        out.print("<communication>" + String.format("%.1f", communication) + "</communication>");
        out.print("<support>" + String.format("%.1f", support) + "</support>");
        out.print("<punctuality>" + String.format("%.1f", punctuality) + "</punctuality>");
        out.print("</performance>");
    }

    private void getAvailableYears(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int instructorId = Integer.parseInt(request.getParameter("id"));

        response.setContentType("text/xml;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        out.print("<years>");

        String sql = "SELECT DISTINCT YEAR(feedbackDate) as year_num FROM feedback WHERE instructorID = ? AND feedbackDate IS NOT NULL "
                + "UNION "
                + "SELECT DISTINCT YEAR(c.classDate) as year_num FROM class_confirmation cc "
                + "INNER JOIN class c ON cc.classID = c.classID "
                + "WHERE cc.instructorID = ? AND c.classDate IS NOT NULL "
                + "ORDER BY year_num DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, instructorId);
            stmt.setInt(2, instructorId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                out.print("<year>" + rs.getInt("year_num") + "</year>");
            }
        }

        out.print("</years>");
    }

    private void checkInstructorClasses(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        int instructorId = Integer.parseInt(request.getParameter("id"));

        List<Map<String, Object>> assignedClasses = getAssignedClassesForInstructor(instructorId);

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<classCheck>");
        out.print("<hasClasses>" + (!assignedClasses.isEmpty()) + "</hasClasses>");
        out.print("<classCount>" + assignedClasses.size() + "</classCount>");

        if (!assignedClasses.isEmpty()) {
            out.print("<classes>");
            for (Map<String, Object> classData : assignedClasses) {
                out.print("<class>");
                out.print("<id>" + classData.get("classID") + "</id>");
                out.print("<name>" + escapeXml(classData.get("className").toString()) + "</name>");
                out.print("<action>" + escapeXml(classData.get("action").toString()) + "</action>");
                out.print("<date>" + formatDate(classData.get("classDate")) + "</date>");
                out.print("<startTime>" + formatTime(classData.get("classStartTime")) + "</startTime>");
                out.print("</class>");
            }
            out.print("</classes>");
        }

        out.print("</classCheck>");
    }

    private String formatTime(Object time) {
        if (time == null) {
            return "Not available";
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
            return sdf.format(time);
        } catch (Exception e) {
            return "Not available";
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/xml;charset=UTF-8");

        String action = request.getParameter("action");

        System.out.println("=== DEBUG POST REQUEST ===");
        System.out.println("Action: " + action);
        System.out.println("Request parameters:");
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            System.out.println("  " + paramName + ": " + request.getParameter(paramName));
        }

        try {
            if ("toggleStatus".equals(action)) {
                toggleInstructorStatus(request, response);
            } else {
                System.out.println("DEBUG - Invalid action: " + action);
                PrintWriter out = response.getWriter();
                out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Invalid action: " + escapeXml(action) + "</message></response>");
            }
        } catch (SQLException e) {
            System.err.println("DEBUG - SQL Exception: " + e.getMessage());
            e.printStackTrace();
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Database error: " + escapeXml(e.getMessage()) + "</message></response>");
        } catch (Exception e) {
            System.err.println("DEBUG - General Exception: " + e.getMessage());
            e.printStackTrace();
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Server error: " + escapeXml(e.getMessage()) + "</message></response>");
        }
    }

    private void toggleInstructorStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        response.setContentType("text/xml;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String idParam = request.getParameter("id");
        String newStatusParam = request.getParameter("newStatus");

        System.out.println("DEBUG - toggleStatus parameters:");
        System.out.println("  id: " + idParam);
        System.out.println("  newStatus: " + newStatusParam);

        if (idParam == null || newStatusParam == null) {
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Missing parameters</message></response>");
            return;
        }

        int instructorId;
        try {
            instructorId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Invalid instructor ID</message></response>");
            return;
        }

        String newStatus = newStatusParam;

        Integer adminId = (Integer) request.getSession().getAttribute("adminID");
        if (adminId == null) {
            adminId = 1;
        }

        System.out.println("DEBUG - Admin ID: " + adminId);

        com.skylightstudio.classmanagement.model.Instructor instructor
                = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            System.out.println("DEBUG - Instructor not found: " + instructorId);
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Instructor not found</message></response>");
            return;
        }

        String currentStatus = instructor.getStatus();
        System.out.println("DEBUG - Current instructor status: " + currentStatus);

        if ("inactive".equals(newStatus) && "active".equals(currentStatus)) {
            List<Map<String, Object>> assignedClasses = getAssignedClassesForInstructor(instructorId);

            if (!assignedClasses.isEmpty()) {
                System.out.println("DEBUG - Instructor has " + assignedClasses.size() + " assigned classes");

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    conn.setAutoCommit(false);

                    int promotedCount = 0;
                    int cancelledCount = 0;
                    int withdrawnCount = 0;

                    for (Map<String, Object> classData : assignedClasses) {
                        int classId = (Integer) classData.get("classID");
                        String action = (String) classData.get("action");
                        String className = (String) classData.get("className");
                        java.sql.Date classDate = (java.sql.Date) classData.get("classDate");
                        java.sql.Time classStartTime = (java.sql.Time) classData.get("classStartTime");

                        System.out.println("DEBUG - Processing class ID: " + classId + ", Action: " + action);

                        long classDateTime = classDate.getTime() + classStartTime.getTime();
                        long now = System.currentTimeMillis();
                        long hoursRemaining = (classDateTime - now) / (1000 * 60 * 60);

                        Map<String, Object> classDetails = classDAO.getClassWithInstructors(classId);

                        if ("confirmed".equals(action)) {
                            if (classDetails != null && classDetails.containsKey("reliefInstructor")) {
                                Map<String, Object> reliefInstructor = (Map<String, Object>) classDetails.get("reliefInstructor");
                                int reliefInstructorId = (Integer) reliefInstructor.get("id");
                                String reliefInstructorName = (String) reliefInstructor.get("name");

                                promoteReliefInstructor(conn, classId, reliefInstructorId);
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - replaced by relief instructor " + reliefInstructorName);

                                promotedCount++;
                                System.out.println("DEBUG - Promoted relief instructor " + reliefInstructorName
                                        + " for class ID: " + classId);

                            } else if (hoursRemaining >= 24) {
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class available for new instructor assignment");
                                withdrawnCount++;
                                System.out.println("DEBUG - Class " + classId + " remains active, looking for new instructor");

                            } else if (hoursRemaining < 24 && hoursRemaining >= 0) {
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class cancelled (less than 24 hours, no relief)");
                                classDAO.updateClassStatus(classId, "inactive");
                                cancelledCount++;
                                System.out.println("DEBUG - Class " + classId + " cancelled due to <24 hours");

                            } else {
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class already passed");
                                withdrawnCount++;
                            }

                        } else if ("pending".equals(action)) {
                            cancelInstructorFromClass(conn, classId, instructorId,
                                    "Instructor deactivated - relief request cancelled");
                            withdrawnCount++;
                            System.out.println("DEBUG - Cancelled pending relief for class ID: " + classId);
                        }
                    }

                    boolean success = instructorDAO.updateInstructorStatus(instructorId, newStatus, adminId);

                    if (success) {
                        conn.commit();

                        String message = "Instructor deactivated successfully. ";
                        if (promotedCount > 0) {
                            message += promotedCount + " class(es) had relief instructor promoted. ";
                        }
                        if (cancelledCount > 0) {
                            message += cancelledCount + " class(es) were cancelled (no relief within 24 hours). ";
                        }
                        if (withdrawnCount > 0) {
                            message += withdrawnCount + " class(es) had instructor withdrawn. ";
                        }

                        out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>success</result>"
                                + "<message>" + escapeXml(message) + "</message>"
                                + "<newStatus>" + escapeXml(newStatus) + "</newStatus>"
                                + "<totalClasses>" + assignedClasses.size() + "</totalClasses>"
                                + "<promoted>" + promotedCount + "</promoted>"
                                + "<cancelled>" + cancelledCount + "</cancelled>"
                                + "<withdrawn>" + withdrawnCount + "</withdrawn>"
                                + "</response>");
                    } else {
                        conn.rollback();
                        out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result>"
                                + "<message>Failed to update instructor status</message></response>");
                    }

                    return;

                } catch (Exception e) {
                    if (conn != null) {
                        try {
                            conn.rollback();
                        } catch (SQLException ex) {
                        }
                    }
                    System.err.println("DEBUG - Error processing classes: " + e.getMessage());
                    e.printStackTrace();
                } finally {
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException e) {
                        }
                    }
                }
            }
        }

        boolean success;

        try {
            success = instructorDAO.updateInstructorStatus(instructorId, newStatus, adminId);
            System.out.println("DEBUG - Update success: " + success);

            if (success) {
                out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>success</result>"
                        + "<message>Status updated successfully</message>"
                        + "<newStatus>" + escapeXml(newStatus) + "</newStatus></response>");
            } else {
                out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result>"
                        + "<message>Failed to update status in database</message></response>");
            }
        } catch (Exception e) {
            System.err.println("DEBUG - Exception during update: " + e.getMessage());
            e.printStackTrace();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result>"
                    + "<message>Database error: " + escapeXml(e.getMessage()) + "</message></response>");
        }
    }

    private List<Map<String, Object>> getAssignedClassesForInstructor(int instructorId) throws SQLException {
        List<Map<String, Object>> assignedClasses = new ArrayList<>();

        String sql = "SELECT cc.classID, cc.action, c.className, c.classDate, c.classStartTime, "
                + "c.classEndTime, c.location, c.classStatus "
                + "FROM class_confirmation cc "
                + "JOIN class c ON cc.classID = c.classID "
                + "WHERE cc.instructorID = ? AND cc.action IN ('confirmed', 'pending') "
                + "AND (cc.cancelledAt IS NULL OR cc.cancelledAt = '') "
                + "AND c.classStatus = 'active' "
                + "ORDER BY c.classDate, c.classStartTime";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> classData = new HashMap<>();
                classData.put("classID", rs.getInt("classID"));
                classData.put("action", rs.getString("action"));
                classData.put("className", rs.getString("className"));
                classData.put("classDate", rs.getDate("classDate"));
                classData.put("classStartTime", rs.getTime("classStartTime"));
                classData.put("classEndTime", rs.getTime("classEndTime"));
                classData.put("location", rs.getString("location"));
                classData.put("classStatus", rs.getString("classStatus"));
                assignedClasses.add(classData);
            }
        }

        return assignedClasses;
    }

    private void promoteReliefInstructor(Connection conn, int classId, int reliefInstructorId) throws SQLException {
        String sql = "UPDATE class_confirmation SET action = 'confirmed', actionAt = CURRENT_TIMESTAMP "
                + "WHERE classID = ? AND instructorID = ? AND action = 'pending'";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, classId);
            stmt.setInt(2, reliefInstructorId);
            stmt.executeUpdate();
        }
    }

    private void cancelInstructorFromClass(Connection conn, int classId, int instructorId, String reason)
            throws SQLException {

        String sql = "UPDATE class_confirmation SET action = 'cancelled', "
                + "cancelledAt = CURRENT_TIMESTAMP, "
                + "cancellationReason = ? "
                + "WHERE classID = ? AND instructorID = ? AND action IN ('confirmed', 'pending')";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, reason);
            stmt.setInt(2, classId);
            stmt.setInt(3, instructorId);
            stmt.executeUpdate();
        }
    }

    private String escapeXml(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String getExperienceString(Object years) {
        if (years == null) {
            return "Not specified";
        }
        try {
            int y = Integer.parseInt(years.toString());
            if (y >= 5) {
                return "5+ years";
            }
            return y + " year" + (y != 1 ? "s" : "");
        } catch (NumberFormatException e) {
            return "Not specified";
        }
    }

    private String formatDate(Object date) {
        if (date == null) {
            return "Not available";
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
            return sdf.format(date);
        } catch (Exception e) {
            return "Not available";
        }
    }

    // ========== COMPLETE PERFORMANCE DATA WITH YEAR/MONTH FILTER ==========
    private void getCompletePerformanceData(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        System.out.println("=== getCompletePerformanceData START ===");

        String idParam = request.getParameter("id");
        String yearParam = request.getParameter("year");
        String monthParam = request.getParameter("month");

        System.out.println("ID param: " + idParam);
        System.out.println("Year param: " + yearParam);
        System.out.println("Month param: " + monthParam);

        if (idParam == null || idParam.trim().isEmpty()) {
            System.err.println("❌ ERROR: Missing instructor ID");
            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error><message>Missing instructor ID</message></error>");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int instructorId;
        try {
            instructorId = Integer.parseInt(idParam);
            System.out.println("✅ Parsed instructor ID: " + instructorId);
        } catch (NumberFormatException e) {
            System.err.println("❌ ERROR: Invalid instructor ID format: " + idParam);
            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error><message>Invalid instructor ID</message></error>");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Integer selectedYear = null;
        Integer selectedMonth = null;

        if (yearParam != null && !yearParam.trim().isEmpty()) {
            try {
                selectedYear = Integer.parseInt(yearParam);
                System.out.println("✅ Selected year: " + selectedYear);
            } catch (NumberFormatException e) {
                System.out.println("⚠️ Invalid year format: " + yearParam);
            }
        }

        if (monthParam != null && !monthParam.trim().isEmpty() && selectedYear != null) {
            try {
                selectedMonth = Integer.parseInt(monthParam);
                System.out.println("✅ Selected month: " + selectedMonth);
            } catch (NumberFormatException e) {
                System.out.println("⚠️ Invalid month format: " + monthParam);
            }
        }

        System.out.println("Final filters - Year: " + selectedYear + ", Month: " + selectedMonth);

        try {
            com.skylightstudio.classmanagement.model.Instructor instructor
                    = instructorDAO.getInstructorById(instructorId);

            if (instructor == null) {
                System.err.println("❌ ERROR: Instructor not found with ID: " + instructorId);
                response.setContentType("text/xml;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
                out.print("<error><message>Instructor not found</message></error>");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            System.out.println("✅ Found instructor: " + instructor.getName());

            int totalConfirmedClasses = getFilteredTotalClasses(instructorId, selectedYear, selectedMonth);
            int cancelledClasses = getFilteredClassCount(instructorId, selectedYear, selectedMonth, "cancelled");
            int completedClasses = totalConfirmedClasses - cancelledClasses;
            double completionRate = totalConfirmedClasses > 0
                    ? (completedClasses * 100.0 / totalConfirmedClasses) : 0;

            System.out.println("Total classes: " + totalConfirmedClasses);
            System.out.println("Cancelled: " + cancelledClasses);
            System.out.println("Completed: " + completedClasses);
            System.out.println("Completion rate: " + completionRate);

            Map<String, Double> ratings = getFilteredAverageRatings(instructorId, selectedYear, selectedMonth);

            double avgTeaching = ratings.getOrDefault("teaching", 0.0);
            double avgCommunication = ratings.getOrDefault("communication", 0.0);
            double avgSupport = ratings.getOrDefault("support", 0.0);
            double avgPunctuality = ratings.getOrDefault("punctuality", 0.0);
            double avgOverall = ratings.getOrDefault("overall", 0.0);

            if (Double.isNaN(avgTeaching)) {
                avgTeaching = 0;
            }
            if (Double.isNaN(avgCommunication)) {
                avgCommunication = 0;
            }
            if (Double.isNaN(avgSupport)) {
                avgSupport = 0;
            }
            if (Double.isNaN(avgPunctuality)) {
                avgPunctuality = 0;
            }
            if (Double.isNaN(avgOverall)) {
                avgOverall = 0;
            }

            double correctOverallRating = (avgTeaching + avgCommunication + avgSupport + avgPunctuality + avgOverall) / 5.0;
            if (Double.isNaN(correctOverallRating) || Double.isInfinite(correctOverallRating)) {
                correctOverallRating = 0.0;
            }

            System.out.println("Correct Overall Rating: " + correctOverallRating);

            Map<String, Object> ratingExtremes = getRatingExtremesForPeriod(instructorId, selectedYear, selectedMonth);
            System.out.println("✅ Rating extremes retrieved");

            List<Map<String, Object>> trendData;
            String trendGranularity;

            if (selectedYear != null && selectedMonth != null) {
                trendData = getDailyTrendForMonth(instructorId, selectedYear, selectedMonth);
                trendGranularity = "daily";
                System.out.println("Using daily trend for " + selectedYear + "-" + selectedMonth);
            } else if (selectedYear != null) {
                trendData = getMonthlyTrendForYear(instructorId, selectedYear);
                trendGranularity = "monthly";
                System.out.println("Using monthly trend for year " + selectedYear);
            } else {
                trendData = getYearlyTrend(instructorId);
                trendGranularity = "yearly";
                System.out.println("Using yearly trend");
            }

            System.out.println("Trend data points: " + trendData.size());

            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();

            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<performance>");

            out.print("<instructorName>" + escapeXml(instructor.getName()) + "</instructorName>");

            out.print("<totalClasses>" + totalConfirmedClasses + "</totalClasses>");
            out.print("<cancelled>" + cancelledClasses + "</cancelled>");
            out.print("<completed>" + completedClasses + "</completed>");
            out.print("<completion>" + String.format("%.0f", completionRate) + "%</completion>");

            out.print("<teaching>" + String.format("%.1f", avgTeaching) + "</teaching>");
            out.print("<communication>" + String.format("%.1f", avgCommunication) + "</communication>");
            out.print("<support>" + String.format("%.1f", avgSupport) + "</support>");
            out.print("<punctuality>" + String.format("%.1f", avgPunctuality) + "</punctuality>");
            out.print("<overallRating>" + String.format("%.1f", correctOverallRating) + "</overallRating>");

            out.print("<teachingHighest>" + ratingExtremes.getOrDefault("maxTeaching", "-") + "</teachingHighest>");
            out.print("<communicationHighest>" + ratingExtremes.getOrDefault("maxCommunication", "-") + "</communicationHighest>");
            out.print("<supportHighest>" + ratingExtremes.getOrDefault("maxSupport", "-") + "</supportHighest>");
            out.print("<punctualityHighest>" + ratingExtremes.getOrDefault("maxPunctuality", "-") + "</punctualityHighest>");
            out.print("<overallHighest>" + ratingExtremes.getOrDefault("maxOverall", "-") + "</overallHighest>");

            out.print("<teachingLowest>" + ratingExtremes.getOrDefault("minTeaching", "-") + "</teachingLowest>");
            out.print("<communicationLowest>" + ratingExtremes.getOrDefault("minCommunication", "-") + "</communicationLowest>");
            out.print("<supportLowest>" + ratingExtremes.getOrDefault("minSupport", "-") + "</supportLowest>");
            out.print("<punctualityLowest>" + ratingExtremes.getOrDefault("minPunctuality", "-") + "</punctualityLowest>");
            out.print("<overallLowest>" + ratingExtremes.getOrDefault("minOverall", "-") + "</overallLowest>");

            out.print("<trendData granularity=\"" + trendGranularity + "\">");
            for (Map<String, Object> trendPoint : trendData) {
                out.print("<point>");
                out.print("<name>" + trendPoint.get("name") + "</name>");
                out.print("<rating>" + trendPoint.get("rating") + "</rating>");
                out.print("<totalClasses>" + trendPoint.get("totalClasses") + "</totalClasses>");
                out.print("</point>");
            }
            out.print("</trendData>");

            out.print("</performance>");

            System.out.println("✅ XML response sent successfully");
            System.out.println("=== getCompletePerformanceData END ===");

        } catch (SQLException e) {
            System.err.println("❌ SQL ERROR in getCompletePerformanceData:");
            e.printStackTrace();

            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error><message>Database error: " + escapeXml(e.getMessage()) + "</message></error>");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            System.err.println("❌ GENERAL ERROR in getCompletePerformanceData:");
            e.printStackTrace();

            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error><message>Server error: " + escapeXml(e.getMessage()) + "</message></error>");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private int getFilteredTotalClasses(int instructorId, Integer year, Integer month) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as count FROM class_confirmation cc ")
                .append("INNER JOIN class c ON cc.classID = c.classID ")
                .append("WHERE cc.instructorID = ? AND cc.action = 'confirmed' ");

        if (year != null) {
            sql.append("AND YEAR(c.classDate) = ? ");
        }
        if (month != null && year != null) {
            sql.append("AND MONTH(c.classDate) = ? ");
        }

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            stmt.setInt(paramIndex++, instructorId);

            if (year != null) {
                stmt.setInt(paramIndex++, year);
            }
            if (month != null && year != null) {
                stmt.setInt(paramIndex++, month);
            }

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }

    private int getFilteredClassCount(int instructorId, Integer year, Integer month, String actionType) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as count FROM class_confirmation cc ")
                .append("INNER JOIN class c ON cc.classID = c.classID ")
                .append("WHERE cc.instructorID = ? AND cc.action = ? ");

        if (year != null) {
            sql.append("AND YEAR(c.classDate) = ? ");
        }
        if (month != null && year != null) {
            sql.append("AND MONTH(c.classDate) = ? ");
        }

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            stmt.setInt(paramIndex++, instructorId);
            stmt.setString(paramIndex++, actionType);

            if (year != null) {
                stmt.setInt(paramIndex++, year);
            }
            if (month != null && year != null) {
                stmt.setInt(paramIndex++, month);
            }

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }

    private Map<String, Double> getFilteredAverageRatings(int instructorId, Integer year, Integer month) throws SQLException {
        Map<String, Double> ratings = new HashMap<>();
        ratings.put("teaching", 0.0);
        ratings.put("communication", 0.0);
        ratings.put("support", 0.0);
        ratings.put("punctuality", 0.0);
        ratings.put("overall", 0.0);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("AVG(teachingSkill) as avgTeaching, ")
                .append("AVG(communication) as avgCommunication, ")
                .append("AVG(supportInteraction) as avgSupport, ")
                .append("AVG(punctuality) as avgPunctuality, ")
                .append("AVG(overallRating) as avgOverall ")
                .append("FROM feedback WHERE instructorID = ? ");

        if (year != null) {
            sql.append("AND YEAR(feedbackDate) = ? ");
        }
        if (month != null && year != null) {
            sql.append("AND MONTH(feedbackDate) = ? ");
        }

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            stmt.setInt(paramIndex++, instructorId);

            if (year != null) {
                stmt.setInt(paramIndex++, year);
            }
            if (month != null && year != null) {
                stmt.setInt(paramIndex++, month);
            }

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                ratings.put("teaching", rs.getDouble("avgTeaching"));
                ratings.put("communication", rs.getDouble("avgCommunication"));
                ratings.put("support", rs.getDouble("avgSupport"));
                ratings.put("punctuality", rs.getDouble("avgPunctuality"));
                ratings.put("overall", rs.getDouble("avgOverall"));
            }
        }
        return ratings;
    }

    private Map<String, Object> getRatingExtremesForPeriod(int instructorId, Integer year, Integer month) throws SQLException {
        Map<String, Object> extremes = new HashMap<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("MAX(teachingSkill) as maxTeaching, ")
                .append("MIN(teachingSkill) as minTeaching, ")
                .append("MAX(communication) as maxCommunication, ")
                .append("MIN(communication) as minCommunication, ")
                .append("MAX(supportInteraction) as maxSupport, ")
                .append("MIN(supportInteraction) as minSupport, ")
                .append("MAX(punctuality) as maxPunctuality, ")
                .append("MIN(punctuality) as minPunctuality, ")
                .append("MAX(overallRating) as maxOverall, ")
                .append("MIN(overallRating) as minOverall ")
                .append("FROM feedback WHERE instructorID = ? ");

        if (year != null) {
            sql.append("AND YEAR(feedbackDate) = ? ");
        }
        if (month != null && year != null) {
            sql.append("AND MONTH(feedbackDate) = ? ");
        }

        String noData = "-";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            stmt.setInt(paramIndex++, instructorId);

            if (year != null) {
                stmt.setInt(paramIndex++, year);
            }
            if (month != null && year != null) {
                stmt.setInt(paramIndex++, month);
            }

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                double maxTeaching = rs.getDouble("maxTeaching");
                extremes.put("maxTeaching", rs.wasNull() ? noData : String.format("%.1f", maxTeaching));

                double minTeaching = rs.getDouble("minTeaching");
                extremes.put("minTeaching", rs.wasNull() ? noData : String.format("%.1f", minTeaching));

                double maxCommunication = rs.getDouble("maxCommunication");
                extremes.put("maxCommunication", rs.wasNull() ? noData : String.format("%.1f", maxCommunication));

                double minCommunication = rs.getDouble("minCommunication");
                extremes.put("minCommunication", rs.wasNull() ? noData : String.format("%.1f", minCommunication));

                double maxSupport = rs.getDouble("maxSupport");
                extremes.put("maxSupport", rs.wasNull() ? noData : String.format("%.1f", maxSupport));

                double minSupport = rs.getDouble("minSupport");
                extremes.put("minSupport", rs.wasNull() ? noData : String.format("%.1f", minSupport));

                double maxPunctuality = rs.getDouble("maxPunctuality");
                extremes.put("maxPunctuality", rs.wasNull() ? noData : String.format("%.1f", maxPunctuality));

                double minPunctuality = rs.getDouble("minPunctuality");
                extremes.put("minPunctuality", rs.wasNull() ? noData : String.format("%.1f", minPunctuality));

                double maxOverall = rs.getDouble("maxOverall");
                extremes.put("maxOverall", rs.wasNull() ? noData : String.format("%.1f", maxOverall));

                double minOverall = rs.getDouble("minOverall");
                extremes.put("minOverall", rs.wasNull() ? noData : String.format("%.1f", minOverall));
            } else {
                extremes.put("maxTeaching", noData);
                extremes.put("minTeaching", noData);
                extremes.put("maxCommunication", noData);
                extremes.put("minCommunication", noData);
                extremes.put("maxSupport", noData);
                extremes.put("minSupport", noData);
                extremes.put("maxPunctuality", noData);
                extremes.put("minPunctuality", noData);
                extremes.put("maxOverall", noData);
                extremes.put("minOverall", noData);
            }
        }

        return extremes;
    }

    private List<Map<String, Object>> getDailyTrendForMonth(int instructorId, int year, int month) throws SQLException {
        List<Map<String, Object>> dailyData = new ArrayList<>();

        String sql = "SELECT "
                + "DAY(feedbackDate) as day_num, "
                + "(AVG(teachingSkill) + AVG(communication) + AVG(supportInteraction) + AVG(punctuality) + AVG(overallRating)) / 5 as avg_rating "
                + "FROM feedback "
                + "WHERE instructorID = ? "
                + "AND YEAR(feedbackDate) = ? "
                + "AND MONTH(feedbackDate) = ? "
                + "GROUP BY DAY(feedbackDate) "
                + "ORDER BY DAY(feedbackDate)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            stmt.setInt(2, year);
            stmt.setInt(3, month);

            ResultSet rs = stmt.executeQuery();

            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.set(year, month - 1, 1);
            int daysInMonth = cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH);

            double[] ratingsByDay = new double[daysInMonth + 1];
            boolean[] hasData = new boolean[daysInMonth + 1];

            while (rs.next()) {
                int day = rs.getInt("day_num");
                ratingsByDay[day] = rs.getDouble("avg_rating");
                hasData[day] = true;
            }

            String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

            for (int day = 1; day <= daysInMonth; day++) {
                Map<String, Object> dayData = new HashMap<>();
                dayData.put("name", day + " " + monthNames[month - 1] + " " + year);
                if (hasData[day]) {
                    dayData.put("rating", String.format("%.1f", ratingsByDay[day]));
                } else {
                    dayData.put("rating", "0");
                }
                dayData.put("totalClasses", "0");
                dailyData.add(dayData);
            }
        }

        return dailyData;
    }

    private List<Map<String, Object>> getMonthlyTrendForYear(int instructorId, int year) throws SQLException {
        List<Map<String, Object>> monthlyData = new ArrayList<>();

        String classSql = "SELECT "
                + "MONTH(c.classDate) as month_num, "
                + "COUNT(*) as class_count "
                + "FROM class_confirmation cc "
                + "INNER JOIN class c ON cc.classID = c.classID "
                + "WHERE cc.instructorID = ? AND cc.action = 'confirmed' "
                + "AND YEAR(c.classDate) = ? "
                + "GROUP BY MONTH(c.classDate)";

        String ratingSql = "SELECT "
                + "MONTH(feedbackDate) as month_num, "
                + "(AVG(teachingSkill) + AVG(communication) + AVG(supportInteraction) + AVG(punctuality) + AVG(overallRating)) / 5 as avg_rating "
                + "FROM feedback "
                + "WHERE instructorID = ? "
                + "AND YEAR(feedbackDate) = ? "
                + "GROUP BY MONTH(feedbackDate)";

        String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

        Map<Integer, Integer> classCounts = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(classSql)) {
            stmt.setInt(1, instructorId);
            stmt.setInt(2, year);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                classCounts.put(rs.getInt("month_num"), rs.getInt("class_count"));
            }
        }

        Map<Integer, Double> ratingsByMonth = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(ratingSql)) {
            stmt.setInt(1, instructorId);
            stmt.setInt(2, year);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                ratingsByMonth.put(rs.getInt("month_num"), rs.getDouble("avg_rating"));
            }
        }

        for (int month = 1; month <= 12; month++) {
            Map<String, Object> monthData = new HashMap<>();
            monthData.put("name", monthNames[month - 1] + " " + year);

            Double rating = ratingsByMonth.get(month);
            if (rating != null && rating > 0) {
                monthData.put("rating", String.format("%.1f", rating));
            } else {
                monthData.put("rating", "0");
            }

            Integer classCount = classCounts.get(month);
            monthData.put("totalClasses", classCount != null ? String.valueOf(classCount) : "0");
            monthlyData.add(monthData);
        }

        return monthlyData;
    }

    private List<Map<String, Object>> getYearlyTrend(int instructorId) throws SQLException {
        List<Map<String, Object>> yearlyData = new ArrayList<>();

        String sql = "SELECT "
                + "YEAR(feedbackDate) as year_num, "
                + "(AVG(teachingSkill) + AVG(communication) + AVG(supportInteraction) + AVG(punctuality) + AVG(overallRating)) / 5 as avg_rating "
                + "FROM feedback "
                + "WHERE instructorID = ? "
                + "GROUP BY YEAR(feedbackDate) "
                + "ORDER BY YEAR(feedbackDate) DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> yearData = new HashMap<>();
                int yearNum = rs.getInt("year_num");

                yearData.put("name", String.valueOf(yearNum));
                yearData.put("rating", String.format("%.1f", rs.getDouble("avg_rating")));
                yearData.put("totalClasses", "0");

                yearlyData.add(yearData);
            }
        }

        return yearlyData;
    }
}
