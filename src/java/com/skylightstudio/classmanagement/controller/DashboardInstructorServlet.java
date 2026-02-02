package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.*;
import com.skylightstudio.classmanagement.model.*;
import com.skylightstudio.classmanagement.util.SessionUtil;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "DashboardInstructorServlet", urlPatterns = {"/dashboard_instructor"})
public class DashboardInstructorServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if user is instructor
        if (!SessionUtil.checkInstructorAccess(session)) {
            response.sendRedirect("../general/login.jsp?error=instructor_access_required");
            return;
        }
        
        Instructor instructor = SessionUtil.getInstructorObject(session);
        if (instructor == null) {
            response.sendRedirect("../general/login.jsp?error=session_expired");
            return;
        }
        
        try {
            // Get current date
            Date currentDate = new Date(System.currentTimeMillis());
            
            // Create DAO instances
            ClassDAO classDAO = new ClassDAO();
            ClassConfirmationDAO confirmationDAO = new ClassConfirmationDAO();
            
            // 1. Get today's classes for the instructor
            List todaysClasses = classDAO.getTodaysClassesForInstructor(
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
            List weeklyClasses = classDAO.getWeeklyClassesForInstructor(
                instructor.getInstructorID(), weekStart, weekEnd
            );
            
            // Organize weekly classes by day
            Map weeklyClassesByDay = new HashMap();
            for (Object obj : weeklyClasses) {
                Map classData = (Map) obj;
                Date classDate = (Date) classData.get("classDate");
                cal.setTime(classDate);
                int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
                
                if (!weeklyClassesByDay.containsKey(dayOfWeek)) {
                    weeklyClassesByDay.put(dayOfWeek, new ArrayList());
                }
                ((List) weeklyClassesByDay.get(dayOfWeek)).add(classData);
            }
            
            // Create week data structure for JSP
            List weekClasses = new ArrayList();
            String[] dayNames = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
            
            Calendar tempCal = Calendar.getInstance();
            tempCal.setTime(weekStart);
            
            for (int i = 0; i < 7; i++) {
                Map dayData = new HashMap();
                dayData.put("dayName", dayNames[i]);
                dayData.put("date", new Integer(tempCal.get(Calendar.DAY_OF_MONTH)));
                
                // Check if today
                Calendar todayCal = Calendar.getInstance();
                boolean isToday = 
                    tempCal.get(Calendar.YEAR) == todayCal.get(Calendar.YEAR) &&
                    tempCal.get(Calendar.MONTH) == todayCal.get(Calendar.MONTH) &&
                    tempCal.get(Calendar.DAY_OF_MONTH) == todayCal.get(Calendar.DAY_OF_MONTH);
                dayData.put("isToday", new Boolean(isToday));
                
                // Get classes for this day
                List dayClasses = new ArrayList();
                int dayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
                
                if (weeklyClassesByDay.containsKey(dayOfWeek)) {
                    List dayClassData = (List) weeklyClassesByDay.get(dayOfWeek);
                    for (Object classObj : dayClassData) {
                        Map classData = (Map) classObj;
                        Map classInfo = new HashMap();
                        classInfo.put("title", classData.get("className"));
                        
                        Time startTime = (Time) classData.get("classStartTime");
                        Calendar timeCal = Calendar.getInstance();
                        timeCal.setTime(startTime);
                        int hour = timeCal.get(Calendar.HOUR);
                        if (hour == 0) hour = 12;
                        int minute = timeCal.get(Calendar.MINUTE);
                        String ampm = timeCal.get(Calendar.AM_PM) == Calendar.AM ? "AM" : "PM";
                        String timeStr = String.format("%d:%02d %s", hour, minute, ampm);
                        
                        classInfo.put("time", timeStr);
                        
                        String confirmationStatus = (String) classData.get("confirmationStatus");
                        String type = "confirmed".equals(confirmationStatus) ? "confirm" : "pending";
                        classInfo.put("type", type);
                        
                        dayClasses.add(classInfo);
                    }
                }
                
                dayData.put("classes", dayClasses);
                weekClasses.add(dayData);
                
                tempCal.add(Calendar.DAY_OF_MONTH, 1);
            }
            
            // 3. Get relief class updates
            List reliefUpdates = new ArrayList();
            
            // Get completed relief classes
            List completedRelief = confirmationDAO.getCompletedReliefClasses(instructor.getInstructorID());
            if (!completedRelief.isEmpty()) {
                Map completedSection = new HashMap();
                completedSection.put("type", "completed");
                completedSection.put("classes", completedRelief);
                completedSection.put("count", new Integer(completedRelief.size()));
                reliefUpdates.add(completedSection);
            }
            
            // Get pending relief positions
            List pendingPositions = confirmationDAO.getPendingReliefPositions(instructor.getInstructorID());
            if (!pendingPositions.isEmpty()) {
                Map pendingSection = new HashMap();
                pendingSection.put("type", "pending");
                pendingSection.put("positions", pendingPositions);
                reliefUpdates.add(pendingSection);
            }
            
            // 4. Get available classes for relief
            List availableClasses = classDAO.getAvailableClassesForRelief(instructor.getInstructorID());
            
            // 5. Get instructor statistics
            Calendar nowCal = Calendar.getInstance();
            int currentMonth = nowCal.get(Calendar.MONTH) + 1;
            int currentYear = nowCal.get(Calendar.YEAR);
            
            Map stats = classDAO.getInstructorStatistics(
                instructor.getInstructorID(), currentMonth, currentYear
            );
            
            // 6. Get weekly summary
            Map weeklySummary = confirmationDAO.getWeeklySummary(
                instructor.getInstructorID(), weekStart, weekEnd
            );
            
            // Set all attributes to request
            request.setAttribute("instructor", instructor);
            request.setAttribute("todaysClasses", todaysClasses);
            request.setAttribute("weekClasses", weekClasses);
            request.setAttribute("reliefUpdates", reliefUpdates);
            request.setAttribute("availableClasses", availableClasses);
            request.setAttribute("weeklySummary", weeklySummary);
            
            // Set statistics - handle null values
            Integer classesThisMonth = (Integer) stats.get("classesThisMonth");
            if (classesThisMonth == null) classesThisMonth = new Integer(0);
            request.setAttribute("classesThisMonth", classesThisMonth);
            
            Double avgRating = (Double) stats.get("avgRating");
            if (avgRating == null) avgRating = new Double(0.0);
            request.setAttribute("avgRating", avgRating);
            
            Integer todayClasses = (Integer) stats.get("todayClasses");
            if (todayClasses == null) todayClasses = new Integer(0);
            request.setAttribute("todayClasses", todayClasses);
            
            // Set dates
            request.setAttribute("currentDate", currentDate);
            request.setAttribute("weekStart", weekStart);
            request.setAttribute("weekEnd", weekEnd);
            
            // Calculate available classes count
            int availableClassesCount = 0;
            for (Object obj : availableClasses) {
                Map availableClass = (Map) obj;
                Integer instructorCount = (Integer) availableClass.get("instructorCount");
                if (instructorCount != null && instructorCount.intValue() < 2) { // Class can have max 2 instructors
                    availableClassesCount++;
                }
            }
            request.setAttribute("availableClassesCount", new Integer(availableClassesCount));
            
            // Forward to JSP
            request.getRequestDispatcher("/instructor/dashboard_instructor.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading dashboard: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
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
        return "Instructor Dashboard Servlet";
    }
}