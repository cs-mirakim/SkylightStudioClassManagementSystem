/*package com.skylightstudio.classmanagement.controller;
import com.skylightstudio.classmanagement.dao.NotificationDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.PrintWriter;

@WebServlet(name = "InboxMessagesInstructorServlet", urlPatterns = {"/instructor/notifications/*"})
public class InboxMessagesInstructorServlet extends HttpServlet {

    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("../general/login.jsp");
            return;
        }
        
        Integer instructorId = (Integer) session.getAttribute("instructorId");
        if (instructorId == null) {
            response.sendRedirect("../general/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("count".equals(action)) {
            // Get unread count
            int count = notificationDAO.getUnreadNotificationCount(instructorId);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"count\":" + count + "}");
            }
            
        } else {
            // Forward to JSP page
            request.getRequestDispatcher("/instructor/inboxMessages_instructor.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }
        
        Integer instructorId = (Integer) session.getAttribute("instructorId");
        if (instructorId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not an instructor");
            return;
        }
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            
            if ("markAsRead".equals(action)) {
                try {
                    int notificationId = Integer.parseInt(request.getParameter("notificationId"));
                    boolean success = notificationDAO.markAsRead(notificationId, instructorId);
                    out.print("{\"success\":" + success + "}");
                } catch (NumberFormatException e) {
                    out.print("{\"success\":false,\"error\":\"Invalid notification ID\"}");
                }
                
            } else if ("markAllAsRead".equals(action)) {
                boolean success = notificationDAO.markAllAsRead(instructorId);
                if (success) {
                    int newCount = notificationDAO.getUnreadNotificationCount(instructorId);
                    out.print("{\"success\":true,\"count\":" + newCount + "}");
                } else {
                    out.print("{\"success\":false}");
                }
                
            } else {
                out.print("{\"success\":false,\"error\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\":false,\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles instructor notifications";
    }
}*/