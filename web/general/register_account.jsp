package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.AdminDAO;
import com.skylightstudio.classmanagement.dao.InstructorDAO;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

@WebServlet("/checkEmail")
public class CheckEmailServlet extends HttpServlet {
    
    private AdminDAO adminDAO;
    private InstructorDAO instructorDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        adminDAO = new AdminDAO();
        instructorDAO = new InstructorDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            sendJsonResponse(response, false, "Email is required");
            return;
        }
        
        boolean adminExists = adminDAO.isEmailExists(email);
        boolean instructorExists = instructorDAO.isEmailExists(email);
        
        boolean isAvailable = !(adminExists || instructorExists);
        
        sendJsonResponse(response, isAvailable, isAvailable ? "Available" : "Already registered");
    }
    
    private void sendJsonResponse(HttpServletResponse response, boolean available, String message) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        out.print("{\"available\": " + available + ", \"message\": \"" + message + "\"}");
        out.flush();
    }
}