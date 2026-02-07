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
        response.setContentType("text/html;charset=UTF-8");
        String action = request.getParameter("action");

        try {
            if ("list".equals(action)) {
                getAllInstructors(response);
            } else if ("details".equals(action)) {
                getInstructorDetails(request, response);
            } else if ("stats".equals(action)) {
                getStats(response);  // ✅ Ini dah betul
            } else if ("performance".equals(action)) {
                getPerformanceData(request, response);  // ⚠️ Action lama
            } else if ("completePerformance".equals(action)) {  // ✅ ACTION BARU
                getCompletePerformanceData(request, response);  // PASTIKAN METHOD INI WUJUD
            } else if ("checkClasses".equals(action)) {
                checkInstructorClasses(request, response);
            } else {
                request.getRequestDispatcher("/admin/monitor_instructor.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + e.getMessage());
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
            out.print("<dateJoined>" + formatDate(instructor.get("dateJoined")) + "</dateJoined>");
            out.print("<status>" + escapeXml(instructor.get("instructorStatus").toString()) + "</status>");
            out.print("<registrationStatus>" + escapeXml(instructor.get("registrationStatus").toString()) + "</registrationStatus>");
            out.print("</instructor>");
        }
        out.print("</instructors>");
    }

    private void getInstructorDetails(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int instructorId = Integer.parseInt(request.getParameter("id"));

        // Get instructor from database
        com.skylightstudio.classmanagement.model.Instructor instructor = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Instructor not found");
            return;
        }

        // Get registration details
        com.skylightstudio.classmanagement.model.Registration registration
                = registrationDAO.getRegistrationById(instructor.getRegisterID());

        // ========== PERUBAHAN 1: GUNA CONFIRMED CLASSES SAHAJA ==========
        // Get performance stats - CONFIRMED CLASSES SAHAJA
        ClassConfirmationDAO classConfirmationDAO = new ClassConfirmationDAO();
        // GUNA METHOD BARU: countConfirmedClassesForInstructor() bukan countClassesForInstructor()
        int totalConfirmedClasses = classConfirmationDAO.countConfirmedClassesForInstructor(instructorId);
        int cancelledClasses = classConfirmationDAO.countCancelledClassesForInstructor(instructorId);
        int completedClasses = totalConfirmedClasses - cancelledClasses;

        // ========== PERUBAHAN 2: GET ALL 5 AVERAGE RATINGS ==========
        // Get ALL 5 average ratings
        FeedbackDAO feedbackDAO = new FeedbackDAO();
        Map<String, Double> averageRatings = feedbackDAO.getAverageRatingsForInstructor(instructorId);

        // Dapatkan semua 5 rating
        double avgTeaching = averageRatings.getOrDefault("teaching", 0.0);
        double avgCommunication = averageRatings.getOrDefault("communication", 0.0);
        double avgSupport = averageRatings.getOrDefault("support", 0.0);
        double avgPunctuality = averageRatings.getOrDefault("punctuality", 0.0);
        double avgOverallRating = averageRatings.getOrDefault("overall", 0.0);

        // ========== PERUBAHAN 3: KIRA AVERAGE DARI 5 RATING ==========
        // Kira total semua rating
        double totalAllRatings = avgTeaching + avgCommunication + avgSupport + avgPunctuality + avgOverallRating;
        // Kira average (bahagi dengan 5)
        double averageAllRatings = totalAllRatings / 5.0;

        // Handle NaN atau infinite values
        if (Double.isNaN(averageAllRatings) || Double.isInfinite(averageAllRatings)) {
            averageAllRatings = 0.0;
        }

        int feedbackCount = feedbackDAO.getFeedbackCountForInstructor(instructorId);

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<details>");

        // ========== BASIC INFORMATION ==========
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

        // ========== PERUBAHAN 4: UPDATE CLASS STATS DENGAN CONFIRMED CLASSES ==========
        out.print("<totalClasses>" + totalConfirmedClasses + "</totalClasses>");
        out.print("<cancelledClasses>" + cancelledClasses + "</cancelledClasses>");
        out.print("<completedClasses>" + completedClasses + "</completedClasses>");

        // ========== PERUBAHAN 5: TAMBAH SEMUA 5 RATING DALAM XML ==========
        // Output semua 5 rating untuk frontend kira average
        out.print("<avgTeaching>" + String.format("%.1f", avgTeaching) + "</avgTeaching>");
        out.print("<avgCommunication>" + String.format("%.1f", avgCommunication) + "</avgCommunication>");
        out.print("<avgSupport>" + String.format("%.1f", avgSupport) + "</avgSupport>");
        out.print("<avgPunctuality>" + String.format("%.1f", avgPunctuality) + "</avgPunctuality>");
        out.print("<overallRating>" + String.format("%.1f", avgOverallRating) + "</overallRating>");

        // ========== PERUBAHAN 6: TAMBAH AVERAGE SEMUA RATING (untuk reference) ==========
        out.print("<averageAllRatings>" + String.format("%.1f", averageAllRatings) + "</averageAllRatings>");
        out.print("<feedbackCount>" + feedbackCount + "</feedbackCount>");

        // ========== PROFILE IMAGE PATH ==========
        String profileImage = instructor.getProfileImageFilePath();
        if (profileImage != null && !profileImage.isEmpty() && !profileImage.equals("null")) {
            // Pastikan path relatif benar
            if (!profileImage.startsWith("../")) {
                profileImage = "../" + profileImage;
            }
            out.print("<profileImage>" + escapeXml(profileImage) + "</profileImage>");
        } else {
            out.print("<profileImage>../profile_pictures/instructor/dummy.png</profileImage>");
        }

        // ========== CERTIFICATION PATH ==========
        String certification = instructor.getCertificationFilePath();
        System.out.println("DEBUG - Original certification path: " + certification);

        if (certification != null && !certification.isEmpty() && !certification.equals("null")) {
            // Normalize path
            certification = certification.trim();

            // Jika path sudah relative, biarkan saja
            if (!certification.startsWith("../") && !certification.startsWith("/")) {
                certification = "../" + certification;
            }

            // Pastikan tidak ada double slashes
            certification = certification.replace("//", "/");

            System.out.println("DEBUG - Processed certification path: " + certification);

            out.print("<certification>" + escapeXml(certification) + "</certification>");

            // Get file name for display
            String fileName = getFileNameFromPath(certification);
            out.print("<certificationFileName>" + escapeXml(fileName) + "</certificationFileName>");
        } else {
            System.out.println("DEBUG - No certification found, using dummy");
            out.print("<certification>../certifications/instructor/dummy.pdf</certification>");
            out.print("<certificationFileName>dummy.pdf</certificationFileName>");
        }

        out.print("</details>");
    }

    // Helper method untuk mendapatkan nama file dari path
    private String getFileNameFromPath(String path) {
        if (path == null || path.isEmpty()) {
            return "No file";
        }
        // Ambil bagian terakhir dari path (nama file)
        String[] parts = path.split("/");
        return parts[parts.length - 1];
    }

    // PERUBAHAN: Update calculation untuk average rating
    private void getStats(HttpServletResponse response) throws SQLException, IOException {
        List<Map<String, Object>> instructors = registrationDAO.getAllInstructorRegistrations();

        int activeCount = 0;
        int inactiveCount = 0;
        int newThisMonth = 0;
        double totalOverallRating = 0;
        int ratedCount = 0;

        // Get current month/year
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

            // Check if joined this month
            java.sql.Timestamp dateJoined = (java.sql.Timestamp) instructor.get("dateJoined");
            if (dateJoined != null) {
                cal.setTime(dateJoined);
                int joinMonth = cal.get(java.util.Calendar.MONTH) + 1;
                int joinYear = cal.get(java.util.Calendar.YEAR);

                if (joinMonth == currentMonth && joinYear == currentYear) {
                    newThisMonth++;
                }
            }

            // Get ALL 5 ratings untuk instructor ini
            Integer instructorId = (Integer) instructor.get("instructorID");
            Map<String, Double> ratings = feedbackDAO.getAverageRatingsForInstructor(instructorId);

            // KIRA AVERAGE DARI 5 RATING
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
        out.print("<avgOverallRating>" + String.format("%.1f", avgRating) + "</avgOverallRating>"); // NAMA TAG BERUBAH
        out.print("</stats>");
    }

    private void getPerformanceData(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int instructorId = Integer.parseInt(request.getParameter("id"));
        String period = request.getParameter("period");

        // Get instructor
        com.skylightstudio.classmanagement.model.Instructor instructor
                = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Instructor not found");
            return;
        }

        // Get performance data
        int totalClasses = getTotalClassesForInstructor(instructorId);
        int cancelledClasses = getCancelledClassesForInstructor(instructorId);
        int completedClasses = totalClasses - cancelledClasses;
        double completionRate = totalClasses > 0 ? (completedClasses * 100.0 / totalClasses) : 0;

        // Get average ratings
        Map<String, Double> averageRatings = feedbackDAO.getAverageRatingsForInstructor(instructorId);
        double overall = averageRatings.getOrDefault("overall", 0.0);
        double teaching = averageRatings.getOrDefault("teaching", 0.0);
        double communication = averageRatings.getOrDefault("communication", 0.0);
        double support = averageRatings.getOrDefault("support", 0.0);
        double punctuality = averageRatings.getOrDefault("punctuality", 0.0);

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<performance>");
        out.print("<instructorName>" + escapeXml(instructor.getName()) + "</instructorName>");
        out.print("<overallRating>" + String.format("%.1f", overall) + "</overallRating>");
        out.print("<totalClasses>" + totalClasses + "</totalClasses>");
        out.print("<cancelled>" + cancelledClasses + "</cancelled>");
        out.print("<completion>" + String.format("%.0f", completionRate) + "%</completion>");
        out.print("<teaching>" + String.format("%.1f", teaching) + "</teaching>");
        out.print("<communication>" + String.format("%.1f", communication) + "</communication>");
        out.print("<support>" + String.format("%.1f", support) + "</support>");
        out.print("<punctuality>" + String.format("%.1f", punctuality) + "</punctuality>");
        out.print("</performance>");
    }

    // TAMBAHAN: Check jika instructor ada assigned classes
    private void checkInstructorClasses(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        int instructorId = Integer.parseInt(request.getParameter("id"));

        // Check if instructor has assigned classes
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

    // TAMBAHAN: Helper untuk format time
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

        // Set default content type to XML
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

        // Set content type to XML
        response.setContentType("text/xml;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // Debug log parameters
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

        // Get current admin ID from session
        Integer adminId = (Integer) request.getSession().getAttribute("adminID");
        if (adminId == null) {
            // If no session, use default admin ID 1 for testing
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

        // ========== TAMBAHAN: Pemeriksaan untuk deactivate ==========
        if ("inactive".equals(newStatus) && "active".equals(currentStatus)) {
            // Cek jika instructor ada assigned classes
            List<Map<String, Object>> assignedClasses = getAssignedClassesForInstructor(instructorId);

            if (!assignedClasses.isEmpty()) {
                System.out.println("DEBUG - Instructor has " + assignedClasses.size() + " assigned classes");

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    conn.setAutoCommit(false); // Start transaction

                    int promotedCount = 0;
                    int cancelledCount = 0;
                    int withdrawnCount = 0;

                    // Process each assigned class
                    for (Map<String, Object> classData : assignedClasses) {
                        int classId = (Integer) classData.get("classID");
                        String action = (String) classData.get("action");
                        String className = (String) classData.get("className");
                        java.sql.Date classDate = (java.sql.Date) classData.get("classDate");
                        java.sql.Time classStartTime = (java.sql.Time) classData.get("classStartTime");

                        System.out.println("DEBUG - Processing class ID: " + classId + ", Action: " + action);

                        // Calculate hours remaining until class
                        long classDateTime = classDate.getTime() + classStartTime.getTime();
                        long now = System.currentTimeMillis();
                        long hoursRemaining = (classDateTime - now) / (1000 * 60 * 60);

                        // Get class details
                        Map<String, Object> classDetails = classDAO.getClassWithInstructors(classId);

                        if ("confirmed".equals(action)) {
                            // Instructor adalah main instructor untuk class ini

                            if (classDetails != null && classDetails.containsKey("reliefInstructor")) {
                                // Ada relief instructor - promote ke confirmed
                                Map<String, Object> reliefInstructor = (Map<String, Object>) classDetails.get("reliefInstructor");
                                int reliefInstructorId = (Integer) reliefInstructor.get("id");
                                String reliefInstructorName = (String) reliefInstructor.get("name");

                                // Promote relief to confirmed
                                promoteReliefInstructor(conn, classId, reliefInstructorId);

                                // Set current instructor to cancelled
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - replaced by relief instructor " + reliefInstructorName);

                                promotedCount++;
                                System.out.println("DEBUG - Promoted relief instructor " + reliefInstructorName
                                        + " for class ID: " + classId);

                            } else if (hoursRemaining >= 24) {
                                // Takde relief, tapi masih ada >24 jam - class tetap active, cari instructor lain
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class available for new instructor assignment");

                                withdrawnCount++;
                                System.out.println("DEBUG - Class " + classId + " remains active, looking for new instructor");

                            } else if (hoursRemaining < 24 && hoursRemaining >= 0) {
                                // Takde relief & <24 jam - cancel class
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class cancelled (less than 24 hours, no relief)");

                                // Set class to inactive
                                classDAO.updateClassStatus(classId, "inactive");

                                cancelledCount++;
                                System.out.println("DEBUG - Class " + classId + " cancelled due to <24 hours");

                            } else {
                                // Class sudah lepas
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class already passed");

                                withdrawnCount++;
                            }

                        } else if ("pending".equals(action)) {
                            // Instructor adalah relief instructor (pending)
                            // Just cancel the pending request
                            cancelInstructorFromClass(conn, classId, instructorId,
                                    "Instructor deactivated - relief request cancelled");

                            withdrawnCount++;
                            System.out.println("DEBUG - Cancelled pending relief for class ID: " + classId);
                        }
                    }

                    // Update instructor status after processing all classes
                    boolean success = instructorDAO.updateInstructorStatus(instructorId, newStatus, adminId);

                    if (success) {
                        conn.commit(); // Commit transaction

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
                        conn.rollback(); // Rollback if update fails
                        out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result>"
                                + "<message>Failed to update instructor status</message></response>");
                    }

                    return; // Return here since we've processed classes

                } catch (Exception e) {
                    if (conn != null) {
                        try {
                            conn.rollback();
                        } catch (SQLException ex) {
                            // Ignore
                        }
                    }
                    System.err.println("DEBUG - Error processing classes: " + e.getMessage());
                    e.printStackTrace();
                    // Continue with normal status update if error occurs
                } finally {
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException e) {
                            // Ignore
                        }
                    }
                }
            }
        }
        // ========== END TAMBAHAN ==========

        // Original code untuk activate atau jika takde assigned classes
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

    // ========== TAMBAHAN: Helper methods baru ==========
    /**
     * Get all assigned classes (confirmed or pending) for an instructor
     */
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

    /**
     * Promote relief instructor to confirmed
     */
    private void promoteReliefInstructor(Connection conn, int classId, int reliefInstructorId) throws SQLException {
        String sql = "UPDATE class_confirmation SET action = 'confirmed', actionAt = CURRENT_TIMESTAMP "
                + "WHERE classID = ? AND instructorID = ? AND action = 'pending'";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, classId);
            stmt.setInt(2, reliefInstructorId);
            stmt.executeUpdate();
        }
    }

    /**
     * Cancel instructor from a class
     */
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

    // Helper methods
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

    private int getTotalClassesForInstructor(int instructorId) throws SQLException {
        // This is a simplified implementation
        // In real app, you would have a proper method in DAO
        return 0; // Placeholder
    }

    private int getCancelledClassesForInstructor(int instructorId) throws SQLException {
        // This is a simplified implementation
        // In real app, you would have a proper method in DAO
        return 0; // Placeholder
    }

    // Di MonitorInstructorServlet.java, tambahkan method baru:
    private void handleJsonRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        // Read JSON from request
        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String json = sb.toString();
        System.out.println("DEBUG - JSON received: " + json);

        // Parse JSON (gunakan library seperti Jackson/Gson, atau manual untuk sederhana)
        // Untuk contoh sederhana, kita parse manual
        // ...
    }

    // Di dalam class MonitorInstructorServlet, tambahkan method ini:
    private Map<String, Object> getCompletePerformanceData(int instructorId, String period) throws SQLException {
        Map<String, Object> performanceData = new HashMap<>();

        // Get instructor details
        com.skylightstudio.classmanagement.model.Instructor instructor
                = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            return performanceData;
        }

        // Get class statistics
        int totalClasses = classConfirmationDAO.countClassesForInstructor(instructorId);
        int cancelledClasses = classConfirmationDAO.countCancelledClassesForInstructor(instructorId);
        int completedClasses = totalClasses - cancelledClasses;
        double completionRate = totalClasses > 0 ? (completedClasses * 100.0 / totalClasses) : 0;

        // Get feedback ratings
        Map<String, Double> averageRatings = feedbackDAO.getAverageRatingsForInstructor(instructorId);
        double overallRating = averageRatings.getOrDefault("overall", 0.0);
        double teaching = averageRatings.getOrDefault("teaching", 0.0);
        double communication = averageRatings.getOrDefault("communication", 0.0);
        double support = averageRatings.getOrDefault("support", 0.0);
        double punctuality = averageRatings.getOrDefault("punctuality", 0.0);

        // Get highest and lowest ratings
        Map<String, Double> ratingExtremes = getRatingExtremes(instructorId);

        // Get monthly trend data (last 6 months)
        List<Map<String, Object>> monthlyTrend = getMonthlyPerformanceTrend(instructorId, 6);

        // Put all data into map
        performanceData.put("instructorName", instructor.getName());
        performanceData.put("overallRating", overallRating);
        performanceData.put("totalClasses", totalClasses);
        performanceData.put("cancelledClasses", cancelledClasses);
        performanceData.put("completionRate", completionRate);
        performanceData.put("teaching", teaching);
        performanceData.put("communication", communication);
        performanceData.put("support", support);
        performanceData.put("punctuality", punctuality);
        performanceData.put("ratingExtremes", ratingExtremes);
        performanceData.put("monthlyTrend", monthlyTrend);

        return performanceData;
    }

    // Method untuk mendapatkan highest dan lowest rating
    private Map<String, Double> getRatingExtremes(int instructorId) throws SQLException {
        Map<String, Double> extremes = new HashMap<>();

        String sql = "SELECT "
                + "MIN(teachingSkill) as minTeaching, MAX(teachingSkill) as maxTeaching, "
                + "MIN(communication) as minCommunication, MAX(communication) as maxCommunication, "
                + "MIN(supportInteraction) as minSupport, MAX(supportInteraction) as maxSupport, "
                + "MIN(punctuality) as minPunctuality, MAX(punctuality) as maxPunctuality, "
                + "MIN(overallRating) as minOverall, MAX(overallRating) as maxOverall "
                + "FROM feedback WHERE instructorID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                extremes.put("minTeaching", rs.getDouble("minTeaching"));
                extremes.put("maxTeaching", rs.getDouble("maxTeaching"));
                extremes.put("minCommunication", rs.getDouble("minCommunication"));
                extremes.put("maxCommunication", rs.getDouble("maxCommunication"));
                extremes.put("minSupport", rs.getDouble("minSupport"));
                extremes.put("maxSupport", rs.getDouble("maxSupport"));
                extremes.put("minPunctuality", rs.getDouble("minPunctuality"));
                extremes.put("maxPunctuality", rs.getDouble("maxPunctuality"));
                extremes.put("minOverall", rs.getDouble("minOverall"));
                extremes.put("maxOverall", rs.getDouble("maxOverall"));
            }
        }

        return extremes;
    }

    // Method untuk mendapatkan trend bulanan
    private List<Map<String, Object>> getMonthlyPerformanceTrend(int instructorId, int months) throws SQLException {
        List<Map<String, Object>> monthlyData = new ArrayList<>();

        String sql = "SELECT "
                + "EXTRACT(MONTH FROM f.feedbackDate) as month, "
                + "EXTRACT(YEAR FROM f.feedbackDate) as year, "
                + "AVG(f.overallRating) as avgRating, "
                + "COUNT(DISTINCT f.classID) as classCount "
                + "FROM feedback f "
                + "JOIN class c ON f.classID = c.classID "
                + "WHERE f.instructorID = ? "
                + "AND f.feedbackDate >= DATEADD(MONTH, -?, CURRENT_DATE) "
                + "GROUP BY EXTRACT(YEAR FROM f.feedbackDate), EXTRACT(MONTH FROM f.feedbackDate) "
                + "ORDER BY year, month";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            stmt.setInt(2, months);
            ResultSet rs = stmt.executeQuery();

            String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

            while (rs.next()) {
                Map<String, Object> monthData = new HashMap<>();
                int monthNum = rs.getInt("month");

                monthData.put("month", monthNames[monthNum - 1]);
                monthData.put("avgRating", rs.getDouble("avgRating"));
                monthData.put("classCount", rs.getInt("classCount"));

                monthlyData.add(monthData);
            }
        }

        return monthlyData;
    }

    // METHOD BARU: Get complete performance data dengan semua rating
    // METHOD BARU: Get complete performance data dengan semua rating DAN FILTER PERIOD
    private void getCompletePerformanceData(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        int instructorId = Integer.parseInt(request.getParameter("id"));
        String period = request.getParameter("period");

        System.out.println("DEBUG - getCompletePerformanceData: instructorId=" + instructorId + ", period=" + period);

        // Get instructor
        com.skylightstudio.classmanagement.model.Instructor instructor
                = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Instructor not found");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();

            // ========== SET DATE RANGE BASED ON PERIOD ==========
            java.sql.Date sqlStartDate = null;

            if (!"all".equals(period)) {
                java.util.Calendar cal = java.util.Calendar.getInstance();

                if ("3months".equals(period)) {
                    cal.add(java.util.Calendar.MONTH, -3);
                } else if ("6months".equals(period)) {
                    cal.add(java.util.Calendar.MONTH, -6);
                } else if ("1year".equals(period)) {
                    cal.add(java.util.Calendar.YEAR, -1);
                } else {
                    // Default ke 3 bulan
                    cal.add(java.util.Calendar.MONTH, -3);
                }

                sqlStartDate = new java.sql.Date(cal.getTimeInMillis());
                System.out.println("DEBUG - Start date for period " + period + ": " + sqlStartDate);
            }

            // ========== GET FILTERED RATINGS (GUNA METHOD DAO YANG ADA) ==========
            FeedbackDAO feedbackDAO = new FeedbackDAO();

            // Gunakan method DAO yang ada
            Map<String, Double> ratings = feedbackDAO.getAverageRatingsForInstructor(instructorId);

            // Untuk filter date, kita perlu query manual
            Map<String, Double> filteredRatings = new HashMap<>();
            if (sqlStartDate != null) {
                // Query dengan date filter
                filteredRatings = getFilteredRatings(conn, instructorId, sqlStartDate);
            } else {
                // No filter, use all ratings
                filteredRatings = ratings;
            }

            double avgTeaching = filteredRatings.getOrDefault("teaching", 0.0);
            double avgCommunication = filteredRatings.getOrDefault("communication", 0.0);
            double avgSupport = filteredRatings.getOrDefault("support", 0.0);
            double avgPunctuality = filteredRatings.getOrDefault("punctuality", 0.0);
            double avgOverall = filteredRatings.getOrDefault("overall", 0.0);

            // Handle NaN
            if (Double.isNaN(avgTeaching)) {
                avgTeaching = 0.0;
            }
            if (Double.isNaN(avgCommunication)) {
                avgCommunication = 0.0;
            }
            if (Double.isNaN(avgSupport)) {
                avgSupport = 0.0;
            }
            if (Double.isNaN(avgPunctuality)) {
                avgPunctuality = 0.0;
            }
            if (Double.isNaN(avgOverall)) {
                avgOverall = 0.0;
            }

            System.out.println("DEBUG - Filtered Ratings:");
            System.out.println("  Teaching: " + avgTeaching);
            System.out.println("  Communication: " + avgCommunication);
            System.out.println("  Support: " + avgSupport);
            System.out.println("  Punctuality: " + avgPunctuality);
            System.out.println("  Overall: " + avgOverall);

            // ========== GET CLASS STATISTICS (GUNA METHOD DAO YANG ADA) ==========
            ClassConfirmationDAO ccDAO = new ClassConfirmationDAO();
            int totalConfirmedClasses = ccDAO.countConfirmedClassesForInstructor(instructorId);
            int cancelledClasses = ccDAO.countCancelledClassesForInstructor(instructorId);
            int completedClasses = totalConfirmedClasses - cancelledClasses;
            double completionRate = totalConfirmedClasses > 0
                    ? (completedClasses * 100.0 / totalConfirmedClasses) : 0;

            // ========== GET HIGHEST AND LOWEST RATINGS ==========
            Map<String, Double> highestRatings = getHighestRatings(conn, instructorId, sqlStartDate);
            Map<String, Double> lowestRatings = getLowestRatings(conn, instructorId, sqlStartDate);

            double highestTeaching = highestRatings.getOrDefault("teaching", avgTeaching);
            double highestCommunication = highestRatings.getOrDefault("communication", avgCommunication);
            double highestSupport = highestRatings.getOrDefault("support", avgSupport);
            double highestPunctuality = highestRatings.getOrDefault("punctuality", avgPunctuality);
            double highestOverall = highestRatings.getOrDefault("overall", avgOverall);

            double lowestTeaching = lowestRatings.getOrDefault("teaching", avgTeaching);
            double lowestCommunication = lowestRatings.getOrDefault("communication", avgCommunication);
            double lowestSupport = lowestRatings.getOrDefault("support", avgSupport);
            double lowestPunctuality = lowestRatings.getOrDefault("punctuality", avgPunctuality);
            double lowestOverall = lowestRatings.getOrDefault("overall", avgOverall);

            // ========== GET MONTHLY TREND DATA ==========
            List<Map<String, Object>> monthlyTrend = getMonthlyTrend(conn, instructorId, sqlStartDate);

            System.out.println("DEBUG - Monthly trend data points: " + monthlyTrend.size());

            // ========== GENERATE XML RESPONSE ==========
            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();

            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<performance>");

            // Basic Info
            out.print("<instructorName>" + escapeXml(instructor.getName()) + "</instructorName>");
            out.print("<period>" + escapeXml(period) + "</period>");

            // Class Statistics
            out.print("<totalClasses>" + totalConfirmedClasses + "</totalClasses>");
            out.print("<cancelled>" + cancelledClasses + "</cancelled>");
            out.print("<completion>" + String.format("%.0f", completionRate) + "%</completion>");

            // All 5 Ratings (Average)
            out.print("<teaching>" + String.format("%.1f", avgTeaching) + "</teaching>");
            out.print("<communication>" + String.format("%.1f", avgCommunication) + "</communication>");
            out.print("<support>" + String.format("%.1f", avgSupport) + "</support>");
            out.print("<punctuality>" + String.format("%.1f", avgPunctuality) + "</punctuality>");
            out.print("<overallRating>" + String.format("%.1f", avgOverall) + "</overallRating>");

            // Highest Ratings
            out.print("<teachingHighest>" + String.format("%.1f", highestTeaching) + "</teachingHighest>");
            out.print("<communicationHighest>" + String.format("%.1f", highestCommunication) + "</communicationHighest>");
            out.print("<supportHighest>" + String.format("%.1f", highestSupport) + "</supportHighest>");
            out.print("<punctualityHighest>" + String.format("%.1f", highestPunctuality) + "</punctualityHighest>");
            out.print("<overallHighest>" + String.format("%.1f", highestOverall) + "</overallHighest>");

            // Lowest Ratings
            out.print("<teachingLowest>" + String.format("%.1f", lowestTeaching) + "</teachingLowest>");
            out.print("<communicationLowest>" + String.format("%.1f", lowestCommunication) + "</communicationLowest>");
            out.print("<supportLowest>" + String.format("%.1f", lowestSupport) + "</supportLowest>");
            out.print("<punctualityLowest>" + String.format("%.1f", lowestPunctuality) + "</punctualityLowest>");
            out.print("<overallLowest>" + String.format("%.1f", lowestOverall) + "</overallLowest>");

            // Monthly Trend Data
            out.print("<monthlyTrend>");

            if (monthlyTrend.isEmpty()) {
                // Jika tiada data, hantar 6 bulan kosong
                System.out.println("DEBUG - No monthly trend data found, generating empty months");
                String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun"};
                for (String month : monthNames) {
                    out.print("<month>");
                    out.print("<name>" + month + "</name>");
                    out.print("<rating>0.0</rating>");
                    out.print("<totalClasses>0</totalClasses>");
                    out.print("</month>");
                }
            } else {
                for (Map<String, Object> monthData : monthlyTrend) {
                    out.print("<month>");
                    out.print("<name>" + escapeXml(monthData.get("month").toString()) + "</name>");
                    out.print("<rating>" + String.format("%.1f", monthData.get("avgRating")) + "</rating>");
                    out.print("<totalClasses>" + monthData.get("totalClasses") + "</totalClasses>");
                    out.print("</month>");
                }
            }

            out.print("</monthlyTrend>");

            out.print("</performance>");

            System.out.println("DEBUG - XML response generated successfully for period: " + period);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

// ========== HELPER METHODS ==========
// Helper untuk get filtered ratings
    private Map<String, Double> getFilteredRatings(Connection conn, int instructorId, java.sql.Date startDate)
            throws SQLException {

        Map<String, Double> ratings = new HashMap<>();

        String sql = "SELECT "
                + "AVG(teachingSkill) as avgTeaching, "
                + "AVG(communication) as avgCommunication, "
                + "AVG(supportInteraction) as avgSupport, "
                + "AVG(punctuality) as avgPunctuality, "
                + "AVG(overallRating) as avgOverall "
                + "FROM feedback WHERE instructorID = ? AND feedbackDate >= ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, instructorId);
            stmt.setDate(2, startDate);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                ratings.put("teaching", rs.getDouble("avgTeaching"));
                ratings.put("communication", rs.getDouble("avgCommunication"));
                ratings.put("support", rs.getDouble("avgSupport"));
                ratings.put("punctuality", rs.getDouble("avgPunctuality"));
                ratings.put("overall", rs.getDouble("avgOverall"));
            }
        }

        // Handle null values
        for (String key : new String[]{"teaching", "communication", "support", "punctuality", "overall"}) {
            if (!ratings.containsKey(key) || Double.isNaN(ratings.get(key))) {
                ratings.put(key, 0.0);
            }
        }

        return ratings;
    }

// Helper untuk get highest ratings
    private Map<String, Double> getHighestRatings(Connection conn, int instructorId, java.sql.Date startDate)
            throws SQLException {

        Map<String, Double> highestRatings = new HashMap<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("MAX(teachingSkill) as maxTeaching, ")
                .append("MAX(communication) as maxCommunication, ")
                .append("MAX(supportInteraction) as maxSupport, ")
                .append("MAX(punctuality) as maxPunctuality, ")
                .append("MAX(overallRating) as maxOverall ")
                .append("FROM feedback WHERE instructorID = ? ");

        if (startDate != null) {
            sql.append("AND feedbackDate >= ? ");
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            stmt.setInt(1, instructorId);
            if (startDate != null) {
                stmt.setDate(2, startDate);
            }

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                highestRatings.put("teaching", rs.getDouble("maxTeaching"));
                highestRatings.put("communication", rs.getDouble("maxCommunication"));
                highestRatings.put("support", rs.getDouble("maxSupport"));
                highestRatings.put("punctuality", rs.getDouble("maxPunctuality"));
                highestRatings.put("overall", rs.getDouble("maxOverall"));
            }
        }

        return highestRatings;
    }

// Helper untuk get lowest ratings
    private Map<String, Double> getLowestRatings(Connection conn, int instructorId, java.sql.Date startDate)
            throws SQLException {

        Map<String, Double> lowestRatings = new HashMap<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("MIN(teachingSkill) as minTeaching, ")
                .append("MIN(communication) as minCommunication, ")
                .append("MIN(supportInteraction) as minSupport, ")
                .append("MIN(punctuality) as minPunctuality, ")
                .append("MIN(overallRating) as minOverall ")
                .append("FROM feedback WHERE instructorID = ? AND teachingSkill > 0 ");

        if (startDate != null) {
            sql.append("AND feedbackDate >= ? ");
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            stmt.setInt(1, instructorId);
            if (startDate != null) {
                stmt.setDate(2, startDate);
            }

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                lowestRatings.put("teaching", rs.getDouble("minTeaching"));
                lowestRatings.put("communication", rs.getDouble("minCommunication"));
                lowestRatings.put("support", rs.getDouble("minSupport"));
                lowestRatings.put("punctuality", rs.getDouble("minPunctuality"));
                lowestRatings.put("overall", rs.getDouble("minOverall"));
            }
        }

        return lowestRatings;
    }

// Helper untuk get monthly trend
    private List<Map<String, Object>> getMonthlyTrend(Connection conn, int instructorId, java.sql.Date startDate)
            throws SQLException {

        List<Map<String, Object>> monthlyData = new ArrayList<>();

        // Tentukan berapa bulan nak papar berdasarkan period
        int monthsToShow = 6; // default

        // Query untuk dapatkan rating bulanan
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("TO_CHAR(feedbackDate, 'Mon') as month_name, ")
                .append("EXTRACT(MONTH FROM feedbackDate) as month_num, ")
                .append("AVG(overallRating) as avg_rating, ")
                .append("COUNT(*) as feedback_count ")
                .append("FROM feedback WHERE instructorID = ? ");

        if (startDate != null) {
            sql.append("AND feedbackDate >= ? ");
        }

        sql.append("GROUP BY TO_CHAR(feedbackDate, 'Mon'), EXTRACT(MONTH FROM feedbackDate) ")
                .append("ORDER BY EXTRACT(MONTH FROM feedbackDate) DESC ")
                .append("FETCH FIRST ? ROWS ONLY");

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            stmt.setInt(1, instructorId);
            int paramIndex = 2;

            if (startDate != null) {
                stmt.setDate(paramIndex, startDate);
                paramIndex++;
            }
            stmt.setInt(paramIndex, monthsToShow);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> monthData = new HashMap<>();
                monthData.put("month", rs.getString("month_name"));
                monthData.put("avgRating", rs.getDouble("avg_rating"));
                monthData.put("totalClasses", rs.getInt("feedback_count")); // Ini sebenarnya feedback count
                monthlyData.add(monthData);
            }

            // Jika tiada data sebenar, return empty list
            if (monthlyData.isEmpty()) {
                System.out.println("DEBUG - No monthly trend data in database");
            }
        }

        return monthlyData;
    }

    // Helper methods untuk dapatkan highest dan lowest ratings
    private Map<String, Double> getHighestRatingsForInstructor(int instructorId, java.sql.Date startDate)
            throws SQLException {

        Map<String, Double> highestRatings = new HashMap<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT "
                    + "MAX(teachingSkill) as maxTeaching, "
                    + "MAX(communication) as maxCommunication, "
                    + "MAX(supportInteraction) as maxSupport, "
                    + "MAX(punctuality) as maxPunctuality "
                    + "FROM feedback WHERE instructorID = ? ";

            if (startDate != null) {
                sql += "AND feedbackDate >= ? ";
            }

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, instructorId);

            if (startDate != null) {
                stmt.setDate(2, startDate);
            }

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                highestRatings.put("teaching", rs.getDouble("maxTeaching"));
                highestRatings.put("communication", rs.getDouble("maxCommunication"));
                highestRatings.put("support", rs.getDouble("maxSupport"));
                highestRatings.put("punctuality", rs.getDouble("maxPunctuality"));
            }

            stmt.close();
        } finally {
            if (conn != null) {
                conn.close();
            }
        }

        return highestRatings;
    }

    private Map<String, Double> getLowestRatingsForInstructor(int instructorId, java.sql.Date startDate)
            throws SQLException {

        Map<String, Double> lowestRatings = new HashMap<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT "
                    + "MIN(teachingSkill) as minTeaching, "
                    + "MIN(communication) as minCommunication, "
                    + "MIN(supportInteraction) as minSupport, "
                    + "MIN(punctuality) as minPunctuality "
                    + "FROM feedback WHERE instructorID = ? AND teachingSkill > 0 ";

            if (startDate != null) {
                sql += "AND feedbackDate >= ? ";
            }

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, instructorId);

            if (startDate != null) {
                stmt.setDate(2, startDate);
            }

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                lowestRatings.put("teaching", rs.getDouble("minTeaching"));
                lowestRatings.put("communication", rs.getDouble("minCommunication"));
                lowestRatings.put("support", rs.getDouble("minSupport"));
                lowestRatings.put("punctuality", rs.getDouble("minPunctuality"));
            }

            stmt.close();
        } finally {
            if (conn != null) {
                conn.close();
            }
        }

        return lowestRatings;
    }

    private List<Map<String, Object>> getMonthlyPerformanceTrend(int instructorId, java.sql.Date startDate)
            throws SQLException {

        List<Map<String, Object>> monthlyData = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            // Query untuk dapatkan data bulanan
            String sql = "SELECT "
                    + "TO_CHAR(f.feedbackDate, 'Mon') as month, "
                    + "EXTRACT(MONTH FROM f.feedbackDate) as monthNum, "
                    + "AVG(f.overallRating) as avgRating, "
                    + "COUNT(DISTINCT f.feedbackID) as feedbackCount, "
                    + "COUNT(DISTINCT cc.classID) as totalClasses "
                    + "FROM feedback f "
                    + "LEFT JOIN class_confirmation cc ON f.instructorID = cc.instructorID "
                    + "AND EXTRACT(MONTH FROM f.feedbackDate) = EXTRACT(MONTH FROM c.classDate) "
                    + "AND EXTRACT(YEAR FROM f.feedbackDate) = EXTRACT(YEAR FROM c.classDate) "
                    + "LEFT JOIN class c ON cc.classID = c.classID "
                    + "WHERE f.instructorID = ? ";

            if (startDate != null) {
                sql += "AND f.feedbackDate >= ? ";
            }

            sql += "GROUP BY TO_CHAR(f.feedbackDate, 'Mon'), EXTRACT(MONTH FROM f.feedbackDate) "
                    + "ORDER BY EXTRACT(MONTH FROM f.feedbackDate) DESC "
                    + "FETCH FIRST 6 ROWS ONLY";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, instructorId);

            if (startDate != null) {
                stmt.setDate(2, startDate);
            }

            ResultSet rs = stmt.executeQuery();

            // Jika tiada data, return dummy data
            if (!rs.isBeforeFirst()) {
                // Return dummy data untuk testing
                String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun"};
                for (String month : months) {
                    Map<String, Object> monthData = new HashMap<>();
                    monthData.put("month", month);
                    monthData.put("avgRating", "4.0");
                    monthData.put("totalClasses", "5");
                    monthlyData.add(monthData);
                }
            } else {
                while (rs.next()) {
                    Map<String, Object> monthData = new HashMap<>();
                    monthData.put("month", rs.getString("month"));
                    monthData.put("avgRating", String.format("%.1f", rs.getDouble("avgRating")));
                    monthData.put("totalClasses", rs.getInt("totalClasses"));
                    monthlyData.add(monthData);
                }
            }

            stmt.close();
        } finally {
            if (conn != null) {
                conn.close();
            }
        }

        return monthlyData;
    }
}
