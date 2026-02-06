/*package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.*;
import com.skylightstudio.classmanagement.model.*;
import com.skylightstudio.classmanagement.util.SessionUtil;
import com.skylightstudio.classmanagement.util.DBConnection;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import java.sql.Date;

@WebServlet(name = "DashboardInstructorServlet", urlPatterns = {"/dashboard_instructor"})
public class DashboardInstructorServlet extends HttpServlet {

    private static final String JSON_RESPONSE = "json";
    private static final String HTML_RESPONSE = "html";

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("[DEBUG] ===== DashboardInstructorServlet START =====");
        System.out.println("[DEBUG] Request URL: " + request.getRequestURL());
        System.out.println("[DEBUG] Query String: " + request.getQueryString());
        
        HttpSession session = request.getSession();
        
        // Check response type parameter
        String responseType = request.getParameter("responseType");
        if (responseType == null) {
            responseType = HTML_RESPONSE; // default to HTML for JSP forwarding
        }
        
        System.out.println("[DEBUG] Response type: " + responseType);
        
        // If JSON response is requested, handle it differently
        if (JSON_RESPONSE.equalsIgnoreCase(responseType)) {
            handleJsonResponse(request, response, session);
            return;
        }
        
        // Original HTML/JSP response handling
        handleHtmlResponse(request, response, session);
    }

    private void handleJsonResponse(HttpServletRequest request, HttpServletResponse response, HttpSession session) 
            throws IOException {
        
        System.out.println("[DEBUG] Handling JSON response");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Check if user is instructor
        if (!SessionUtil.checkInstructorAccess(session)) {
            System.out.println("[DEBUG] Instructor access denied for JSON response");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Instructor access required\", \"code\": 401}");
            return;
        }
        
        Instructor instructor = SessionUtil.getInstructorObject(session);
        if (instructor == null) {
            System.out.println("[DEBUG] Instructor object is null for JSON response");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Session expired\", \"code\": 401}");
            return;
        }
        
        System.out.println("[DEBUG] JSON response for instructor: " + instructor.getName() + " (ID: " + instructor.getInstructorID() + ")");
        
        try {
            // Get current date
            Date currentDate = new Date(System.currentTimeMillis());
            
            // Create DAO instances
            ClassDAO classDAO = new ClassDAO();
            ClassConfirmationDAO confirmationDAO = new ClassConfirmationDAO();
            FeedbackDAO feedbackDAO = new FeedbackDAO();
            
            // 1. Get today's classes
            List<Map<String, Object>> todaysClasses = classDAO.getTodaysClassesForInstructor(
                instructor.getInstructorID(), currentDate
            );
            
            // 2. Get week overview data
            Calendar cal = Calendar.getInstance();
            cal.setTime(currentDate);
            
            // Set to start of week (Sunday)
            cal.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
            Date weekStart = new Date(cal.getTimeInMillis());
            
            // Set to end of week (Saturday)
            cal.add(Calendar.DAY_OF_WEEK, 6);
            Date weekEnd = new Date(cal.getTimeInMillis());
            
            // Get weekly classes
            List<Map<String, Object>> weeklyClasses = classDAO.getWeeklyClassesForInstructor(
                instructor.getInstructorID(), weekStart, weekEnd
            );
            
            // 3. Get relief class updates
            List<Map<String, Object>> reliefUpdates = new ArrayList<>();
            
            // Get completed relief classes
            List<Map<String, Object>> completedRelief = confirmationDAO.getCompletedReliefClasses(instructor.getInstructorID());
            if (completedRelief != null && !completedRelief.isEmpty()) {
                Map<String, Object> completedSection = new HashMap<>();
                completedSection.put("type", "completed");
                completedSection.put("classes", completedRelief);
                completedSection.put("count", completedRelief.size());
                reliefUpdates.add(completedSection);
            }
            
            // Get pending relief positions
            List<Map<String, Object>> pendingPositions = confirmationDAO.getPendingReliefPositions(instructor.getInstructorID());
            if (pendingPositions != null && !pendingPositions.isEmpty()) {
                Map<String, Object> pendingSection = new HashMap<>();
                pendingSection.put("type", "pending");
                pendingSection.put("positions", pendingPositions);
                reliefUpdates.add(pendingSection);
            }
            
            // 4. Get available classes for relief
            List<Map<String, Object>> availableClasses = classDAO.getAvailableClassesForRelief(instructor.getInstructorID());
            
            // 5. Get instructor statistics
            Calendar nowCal = Calendar.getInstance();
            int currentMonth = nowCal.get(Calendar.MONTH) + 1;
            int currentYear = nowCal.get(Calendar.YEAR);
            
            Map<String, Object> stats = classDAO.getInstructorStatistics(
                instructor.getInstructorID(), currentMonth, currentYear
            );
            
            // 6. Get weekly summary
            Map<String, Object> weeklySummary = confirmationDAO.getWeeklySummary(
                instructor.getInstructorID(), weekStart, weekEnd
            );
            
            // 7. Get instructor's average rating
            double avgRating = feedbackDAO.getAverageRatingForInstructor(instructor.getInstructorID());
            
            // Build JSON response
            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("success", true);
            jsonResponse.put("instructorId", instructor.getInstructorID());
            jsonResponse.put("instructorName", instructor.getName());
            jsonResponse.put("instructorEmail", instructor.getEmail());
            
            // Today's classes
            jsonResponse.put("todaysClasses", todaysClasses != null ? todaysClasses : new ArrayList<>());
            jsonResponse.put("todaysClassesCount", todaysClasses != null ? todaysClasses.size() : 0);
            
            // Weekly classes
            jsonResponse.put("weeklyClasses", weeklyClasses != null ? weeklyClasses : new ArrayList<>());
            jsonResponse.put("weeklyClassesCount", weeklyClasses != null ? weeklyClasses.size() : 0);
            
            // Relief updates
            jsonResponse.put("reliefUpdates", reliefUpdates);
            
            // Available classes for relief
            jsonResponse.put("availableClasses", availableClasses != null ? availableClasses : new ArrayList<>());
            jsonResponse.put("availableClassesCount", availableClasses != null ? availableClasses.size() : 0);
            
            // Statistics
            Map<String, Object> statistics = new HashMap<>();
            Integer classesThisMonth = (Integer) stats.get("classesThisMonth");
            Integer todayClasses = (Integer) stats.get("todayClasses");
            
            statistics.put("classesThisMonth", classesThisMonth != null ? classesThisMonth : 0);
            statistics.put("todayClasses", todayClasses != null ? todayClasses : 0);
            statistics.put("avgRating", String.format("%.1f", avgRating));
            
            if (weeklySummary != null) {
                statistics.put("weeklySummary", weeklySummary);
            }
            
            jsonResponse.put("statistics", statistics);
            
            // Dates
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            jsonResponse.put("currentDate", dateFormat.format(currentDate));
            jsonResponse.put("weekStart", dateFormat.format(weekStart));
            jsonResponse.put("weekEnd", dateFormat.format(weekEnd));
            
            // Convert to JSON string
            String jsonOutput = convertToJson(jsonResponse);
            System.out.println("[DEBUG] JSON response size: " + jsonOutput.length() + " characters");
            
            out.print(jsonOutput);
            
        } catch (Exception e) {
            System.err.println("[ERROR] Exception in JSON response: " + e.getMessage());
            e.printStackTrace();
            
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Error loading dashboard data: " + e.getMessage());
            errorResponse.put("error", e.getClass().getName());
            
            out.print(convertToJson(errorResponse));
        }
        
        System.out.println("[DEBUG] ===== DashboardInstructorServlet JSON END =====");
    }
    
    private void handleHtmlResponse(HttpServletRequest request, HttpServletResponse response, HttpSession session) 
            throws ServletException, IOException {
        
        System.out.println("[DEBUG] Handling HTML response (original flow)");
        
        // Check if user is instructor
        if (!SessionUtil.checkInstructorAccess(session)) {
            System.out.println("[DEBUG] Instructor access denied. Redirecting to login.");
            response.sendRedirect("../general/login.jsp?error=instructor_access_required");
            return;
        }
        
        Instructor instructor = SessionUtil.getInstructorObject(session);
        if (instructor == null) {
            System.out.println("[DEBUG] Instructor object is null. Redirecting to login.");
            response.sendRedirect("../general/login.jsp?error=session_expired");
            return;
        }
        
        System.out.println("[DEBUG] Instructor found: " + instructor.getName() + " (ID: " + instructor.getInstructorID() + ")");
        
        try {
            // Original HTML/JSP response code from your servlet
            // ... (salin semua code original anda dari sini ke bawah)
            // Get current date
            Date currentDate = new Date(System.currentTimeMillis());
            System.out.println("[DEBUG] Current date: " + currentDate);
            
            // Create DAO instances
            ClassDAO classDAO = new ClassDAO();
            ClassConfirmationDAO confirmationDAO = new ClassConfirmationDAO();
            FeedbackDAO feedbackDAO = new FeedbackDAO();
            
            // 1. Get today's classes for the instructor
            System.out.println("[DEBUG] Fetching today's classes for instructor ID: " + instructor.getInstructorID());
            List<Map<String, Object>> todaysClasses = classDAO.getTodaysClassesForInstructor(
                instructor.getInstructorID(), currentDate
            );
            System.out.println("[DEBUG] Today's classes count: " + (todaysClasses != null ? todaysClasses.size() : "null"));
            
            // Add QR code paths to today's classes
            if (todaysClasses != null) {
                for (Map<String, Object> classItem : todaysClasses) {
                    Integer classId = (Integer) classItem.get("classID");
                    System.out.println("[DEBUG] Processing class ID: " + classId + " for QR code");
                    com.skylightstudio.classmanagement.model.Class classObj = classDAO.getClassById(classId);
                    if (classObj != null) {
                        classItem.put("qrcodeFilePath", classObj.getQrcodeFilePath());
                        System.out.println("[DEBUG] QR code path for class " + classId + ": " + classObj.getQrcodeFilePath());
                    } else {
                        System.out.println("[DEBUG] Class object not found for ID: " + classId);
                    }
                }
            }
            
            // 2. Get week overview data
            Calendar cal = Calendar.getInstance();
            cal.setTime(currentDate);
            
            // Set to start of week (Sunday)
            cal.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
            Date weekStart = new Date(cal.getTimeInMillis());
            
            // Set to end of week (Saturday)
            cal.add(Calendar.DAY_OF_WEEK, 6);
            Date weekEnd = new Date(cal.getTimeInMillis());
            
            System.out.println("[DEBUG] Week start: " + weekStart + ", Week end: " + weekEnd);
            
            // Get weekly classes
            System.out.println("[DEBUG] Fetching weekly classes...");
            List<Map<String, Object>> weeklyClasses = classDAO.getWeeklyClassesForInstructor(
                instructor.getInstructorID(), weekStart, weekEnd
            );
            System.out.println("[DEBUG] Weekly classes count: " + (weeklyClasses != null ? weeklyClasses.size() : "null"));
            
            // Organize weekly classes by day
            Map<Integer, List<Map<String, Object>>> weeklyClassesByDay = new HashMap<>();
            if (weeklyClasses != null) {
                for (Map<String, Object> classData : weeklyClasses) {
                    Date classDate = (Date) classData.get("classDate");
                    cal.setTime(classDate);
                    int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
                    
                    if (!weeklyClassesByDay.containsKey(dayOfWeek)) {
                        weeklyClassesByDay.put(dayOfWeek, new ArrayList<>());
                    }
                    weeklyClassesByDay.get(dayOfWeek).add(classData);
                }
            }
            
            // Create week data structure for JSP
            List<Map<String, Object>> weekClasses = new ArrayList<>();
            String[] dayNames = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
            
            Calendar tempCal = Calendar.getInstance();
            tempCal.setTime(weekStart);
            
            System.out.println("[DEBUG] Building week data structure...");
            for (int i = 0; i < 7; i++) {
                Map<String, Object> dayData = new HashMap<>();
                dayData.put("dayName", dayNames[i]);
                dayData.put("date", tempCal.get(Calendar.DAY_OF_MONTH));
                
                // Check if today
                Calendar todayCal = Calendar.getInstance();
                boolean isToday = 
                    tempCal.get(Calendar.YEAR) == todayCal.get(Calendar.YEAR) &&
                    tempCal.get(Calendar.MONTH) == todayCal.get(Calendar.MONTH) &&
                    tempCal.get(Calendar.DAY_OF_MONTH) == todayCal.get(Calendar.DAY_OF_MONTH);
                dayData.put("isToday", isToday);
                
                // Get classes for this day
                List<Map<String, Object>> dayClasses = new ArrayList<>();
                int dayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
                
                if (weeklyClassesByDay.containsKey(dayOfWeek)) {
                    List<Map<String, Object>> dayClassData = weeklyClassesByDay.get(dayOfWeek);
                    for (Map<String, Object> classObj : dayClassData) {
                        Map<String, Object> classInfo = new HashMap<>();
                        classInfo.put("title", classObj.get("className"));
                        
                        Time startTime = (Time) classObj.get("classStartTime");
                        Calendar timeCal = Calendar.getInstance();
                        timeCal.setTime(startTime);
                        int hour = timeCal.get(Calendar.HOUR_OF_DAY);
                        if (hour > 12) hour -= 12;
                        if (hour == 0) hour = 12;
                        int minute = timeCal.get(Calendar.MINUTE);
                        String ampm = timeCal.get(Calendar.AM_PM) == Calendar.AM ? "AM" : "PM";
                        String timeStr = String.format("%d:%02d %s", hour, minute, ampm);
                        
                        classInfo.put("time", timeStr);
                        
                        String confirmationStatus = (String) classObj.get("confirmationStatus");
                        String type = "confirmed".equals(confirmationStatus) ? "confirm" : "pending";
                        classInfo.put("type", type);
                        
                        dayClasses.add(classInfo);
                    }
                }
                
                dayData.put("classes", dayClasses);
                weekClasses.add(dayData);
                
                tempCal.add(Calendar.DAY_OF_MONTH, 1);
            }
            System.out.println("[DEBUG] Week classes data built: " + weekClasses.size() + " days");
            
            // 3. Get relief class updates
            List<Map<String, Object>> reliefUpdates = new ArrayList<>();
            
            // Get completed relief classes
            System.out.println("[DEBUG] Fetching completed relief classes...");
            List<Map<String, Object>> completedRelief = confirmationDAO.getCompletedReliefClasses(instructor.getInstructorID());
            System.out.println("[DEBUG] Completed relief classes count: " + (completedRelief != null ? completedRelief.size() : "null"));
            if (completedRelief != null && !completedRelief.isEmpty()) {
                Map<String, Object> completedSection = new HashMap<>();
                completedSection.put("type", "completed");
                completedSection.put("classes", completedRelief);
                completedSection.put("count", completedRelief.size());
                reliefUpdates.add(completedSection);
            }
            
            // Get pending relief positions
            System.out.println("[DEBUG] Fetching pending relief positions...");
            List<Map<String, Object>> pendingPositions = confirmationDAO.getPendingReliefPositions(instructor.getInstructorID());
            System.out.println("[DEBUG] Pending positions count: " + (pendingPositions != null ? pendingPositions.size() : "null"));
            if (pendingPositions != null && !pendingPositions.isEmpty()) {
                Map<String, Object> pendingSection = new HashMap<>();
                pendingSection.put("type", "pending");
                pendingSection.put("positions", pendingPositions);
                reliefUpdates.add(pendingSection);
            }
            System.out.println("[DEBUG] Relief updates count: " + reliefUpdates.size());
            
            // 4. Get available classes for relief
            System.out.println("[DEBUG] Fetching available classes for relief...");
            List<Map<String, Object>> availableClasses = classDAO.getAvailableClassesForRelief(instructor.getInstructorID());
            System.out.println("[DEBUG] Available classes count: " + (availableClasses != null ? availableClasses.size() : "null"));
            
            // 5. Get instructor statistics
            Calendar nowCal = Calendar.getInstance();
            int currentMonth = nowCal.get(Calendar.MONTH) + 1;
            int currentYear = nowCal.get(Calendar.YEAR);
            
            System.out.println("[DEBUG] Fetching instructor statistics...");
            Map<String, Object> stats = classDAO.getInstructorStatistics(
                instructor.getInstructorID(), currentMonth, currentYear
            );
            
            // 6. Get weekly summary
            System.out.println("[DEBUG] Fetching weekly summary...");
            Map<String, Object> weeklySummary = confirmationDAO.getWeeklySummary(
                instructor.getInstructorID(), weekStart, weekEnd
            );
            
            // 7. Get instructor's average rating from feedback
            System.out.println("[DEBUG] Fetching average rating...");
            double avgRating = feedbackDAO.getAverageRatingForInstructor(instructor.getInstructorID());
            System.out.println("[DEBUG] Average rating: " + avgRating);
            
            // Set all attributes to request
            System.out.println("[DEBUG] Setting request attributes...");
            request.setAttribute("instructor", instructor);
            request.setAttribute("todaysClasses", todaysClasses);
            request.setAttribute("weekClasses", weekClasses);
            request.setAttribute("reliefUpdates", reliefUpdates);
            request.setAttribute("availableClasses", availableClasses);
            request.setAttribute("weeklySummary", weeklySummary);
            
            // Set statistics - handle null values
            Integer classesThisMonth = (Integer) stats.get("classesThisMonth");
            if (classesThisMonth == null) {
                classesThisMonth = 0;
                System.out.println("[DEBUG] classesThisMonth was null, setting to 0");
            }
            request.setAttribute("classesThisMonth", classesThisMonth);
            System.out.println("[DEBUG] classesThisMonth: " + classesThisMonth);
            
            String formattedRating = String.format("%.1f", avgRating);
            request.setAttribute("avgRating", formattedRating);
            System.out.println("[DEBUG] avgRating (formatted): " + formattedRating);
            
            Integer todayClasses = (Integer) stats.get("todayClasses");
            if (todayClasses == null) {
                todayClasses = 0;
                System.out.println("[DEBUG] todayClasses was null, setting to 0");
            }
            request.setAttribute("todayClasses", todayClasses);
            System.out.println("[DEBUG] todayClasses: " + todayClasses);
            
            // Set dates
            request.setAttribute("currentDate", currentDate);
            request.setAttribute("weekStart", weekStart);
            request.setAttribute("weekEnd", weekEnd);
            
            // Calculate available classes count
            int availableClassesCount = 0;
            if (availableClasses != null) {
                for (Map<String, Object> availableClass : availableClasses) {
                    Integer instructorCount = (Integer) availableClass.get("instructorCount");
                    if (instructorCount != null && instructorCount < 2) { // Class can have max 2 instructors
                        availableClassesCount++;
                    }
                }
            }
            request.setAttribute("availableClassesCount", availableClassesCount);
            System.out.println("[DEBUG] availableClassesCount: " + availableClassesCount);
            
            System.out.println("[DEBUG] All attributes set. Forwarding to JSP...");
            
            // Forward to JSP
            request.getRequestDispatcher("../instructor/dashboard_instructor.jsp").forward(request, response);
            
            System.out.println("[DEBUG] ===== DashboardInstructorServlet HTML END =====");
            
        } catch (Exception e) {
            System.err.println("[ERROR] Exception in DashboardInstructorServlet:");
            e.printStackTrace();
            request.setAttribute("error", "Error loading dashboard: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    // Helper method to convert Map to JSON
    private String convertToJson(Map<String, Object> data) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        
        boolean first = true;
        for (Map.Entry<String, Object> entry : data.entrySet()) {
            if (!first) {
                json.append(",");
            }
            first = false;
            
            json.append("\"").append(entry.getKey()).append("\":");
            Object value = entry.getValue();
            
            if (value instanceof String) {
                json.append("\"").append(escapeJson((String) value)).append("\"");
            } else if (value instanceof Number || value instanceof Boolean) {
                json.append(value);
            } else if (value instanceof List) {
                json.append(convertListToJson((List<?>) value));
            } else if (value instanceof Map) {
                json.append(convertToJson((Map<String, Object>) value));
            } else if (value == null) {
                json.append("null");
            } else {
                json.append("\"").append(escapeJson(value.toString())).append("\"");
            }
        }
        
        json.append("}");
        return json.toString();
    }
    
    private String convertListToJson(List<?> list) {
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        boolean first = true;
        for (Object item : list) {
            if (!first) {
                json.append(",");
            }
            first = false;
            
            if (item instanceof Map) {
                json.append(convertToJson((Map<String, Object>) item));
            } else if (item instanceof String) {
                json.append("\"").append(escapeJson((String) item)).append("\"");
            } else if (item instanceof Number || item instanceof Boolean) {
                json.append(item);
            } else {
                json.append("\"").append(escapeJson(item.toString())).append("\"");
            }
        }
        
        json.append("]");
        return json.toString();
    }
    
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Instructor Dashboard Servlet (HTML and JSON support)";
    }
}*/