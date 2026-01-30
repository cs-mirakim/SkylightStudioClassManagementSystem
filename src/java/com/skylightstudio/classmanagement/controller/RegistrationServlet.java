package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.RegistrationDAO;
import com.skylightstudio.classmanagement.dao.AdminDAO;
import com.skylightstudio.classmanagement.dao.InstructorDAO;
import com.skylightstudio.classmanagement.model.Admin;
import com.skylightstudio.classmanagement.model.Instructor;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "RegistrationServlet", urlPatterns = {"/register"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class RegistrationServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(RegistrationServlet.class.getName());

    // Hash password using SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    // ========== NEW METHOD: SAVE FILE LIKE OTHER PROJECT ==========
    private String saveUploadedFile(Part filePart, HttpServletRequest request,
            String username, String fileType, String userRole) throws IOException {

        if (filePart == null || filePart.getSize() == 0 || filePart.getSubmittedFileName() == null) {
            logger.info("No " + fileType + " file uploaded or empty file");
            return null;
        }

        try {
            // === DEBUG LOGGING ===
            logger.info("=== FILE UPLOAD DEBUG START ===");
            logger.info("User Role: " + userRole);
            logger.info("Username: " + username);
            logger.info("File Type: " + fileType);
            logger.info("Original filename: " + filePart.getSubmittedFileName());
            logger.info("File size: " + filePart.getSize() + " bytes");

            // Determine folder based on file type and user role
            String folderName;
            if ("profile".equals(fileType)) {
                folderName = "profile_pictures/" + userRole.toLowerCase() + "/";
            } else {
                folderName = "certifications/" + userRole.toLowerCase() + "/";
            }

            // Get application context path
            ServletContext context = request.getServletContext();
            String webappPath = context.getRealPath("");

            if (webappPath == null) {
                webappPath = "";
            }

            // Fix path separator
            String fullWebappPath = webappPath;
            if (!fullWebappPath.endsWith(File.separator)) {
                fullWebappPath += File.separator;
            }
            fullWebappPath += folderName;

            // Also try to save to project directory for development
            String projectPath = "";
            try {
                File webappDir = new File(webappPath);
                File buildDir = webappDir.getParentFile(); // build folder
                if (buildDir != null) {
                    File projectRoot = buildDir.getParentFile(); // project root
                    if (projectRoot != null) {
                        projectPath = projectRoot.getAbsolutePath()
                                + File.separator + "web"
                                + File.separator + folderName;
                    }
                }
            } catch (Exception e) {
                logger.log(Level.WARNING, "Could not build project path: " + e.getMessage());
                projectPath = fullWebappPath; // fallback
            }

            logger.info("Webapp Path: " + fullWebappPath);
            logger.info("Project Path: " + projectPath);

            // Create directories
            File webappDir = new File(fullWebappPath);
            File projectDir = new File(projectPath);

            if (!webappDir.exists()) {
                boolean created = webappDir.mkdirs();
                logger.info("Created webapp directory: " + created + " at " + fullWebappPath);
            }

            if (!projectDir.exists() && !projectPath.equals(fullWebappPath)) {
                boolean created = projectDir.mkdirs();
                logger.info("Created project directory: " + created + " at " + projectPath);
            }

            // Generate unique filename
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String fileExtension = "";

            int dotIndex = originalFileName.lastIndexOf('.');
            if (dotIndex > 0) {
                fileExtension = originalFileName.substring(dotIndex).toLowerCase();
            }

            // Sanitize username for filename
            String sanitizedUsername = username.replaceAll("[^a-zA-Z0-9._-]", "_");
            String fileName = sanitizedUsername + "_" + System.currentTimeMillis() + fileExtension;

            logger.info("Generated filename: " + fileName);

            // Save to multiple locations
            String webappFilePath = fullWebappPath + fileName;
            String projectFilePath = projectPath + fileName;

            // Use the successful approach from other project
            boolean filesSaved = saveFileToMultipleLocations(filePart, webappFilePath, projectFilePath);

            logger.info("Files saved successfully: " + filesSaved);

            // Verify files exist
            File webappFile = new File(webappFilePath);
            File projectFile = new File(projectFilePath);

            logger.info("Webapp file exists: " + webappFile.exists() + ", size: "
                    + (webappFile.exists() ? webappFile.length() : 0) + " bytes");
            logger.info("Project file exists: " + projectFile.exists() + ", size: "
                    + (projectFile.exists() ? projectFile.length() : 0) + " bytes");

            logger.info("=== FILE UPLOAD DEBUG END ===");

            // Return relative path for database
            return folderName + fileName;

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in saveUploadedFile method", e);
            return null;
        }
    }

    // ========== METHOD FROM OTHER PROJECT (PROVEN TO WORK) ==========
    private boolean saveFileToMultipleLocations(Part filePart, String... filePaths) throws IOException {
        try (InputStream input = filePart.getInputStream()) {
            // Read all data first
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = input.read(buffer)) != -1) {
                baos.write(buffer, 0, bytesRead);
            }
            byte[] fileData = baos.toByteArray();

            logger.info("File data read: " + fileData.length + " bytes");

            // Write to each location
            boolean allSuccess = true;
            for (String filePath : filePaths) {
                try (FileOutputStream output = new FileOutputStream(filePath)) {
                    output.write(fileData);
                    logger.info("Saved to: " + filePath);
                } catch (IOException e) {
                    logger.log(Level.WARNING, "Failed to save to: " + filePath, e);
                    allSuccess = false;
                }
            }
            return allSuccess;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        logger.info("\n=== REGISTRATION START ===");

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            // Get form parameters
            String userType = request.getParameter("reg_role");
            String username = request.getParameter("username").trim();
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirm_password");
            String name = request.getParameter("name").trim();
            String email = request.getParameter("email").trim();
            String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";
            String nric = request.getParameter("nric").trim();
            String bodStr = request.getParameter("bod");
            String address = request.getParameter("address").trim();

            logger.info("Processing registration for: " + username + ", Role: " + userType);

            // Get file parts
            Part profileImagePart = request.getPart("profileImage");
            Part certificationPart = request.getPart("certification");

            // Validate
            if (!password.equals(confirmPassword)) {
                throw new Exception("Passwords do not match.");
            }

            nric = nric.replace("-", "");
            if (!nric.matches("\\d{12}")) {
                throw new Exception("NRIC must be 12 digits.");
            }

            // Check existing data
            RegistrationDAO registrationDAO = new RegistrationDAO();

            if (registrationDAO.isUsernameTaken(username)) {
                throw new Exception("Username '" + username + "' already taken.");
            }

            if (registrationDAO.isEmailRegistered(email)) {
                throw new Exception("Email '" + email + "' already registered.");
            }

            if (registrationDAO.isNricTaken(nric)) {
                throw new Exception("NRIC already registered.");
            }

            // Convert date
            java.sql.Date bod = null;
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date parsedDate = sdf.parse(bodStr);
                bod = new java.sql.Date(parsedDate.getTime());
            } catch (Exception e) {
                throw new Exception("Invalid date of birth format.");
            }

            // ========== SAVE FILES USING NEW METHOD ==========
            logger.info("Saving uploaded files...");

            String profileImagePath = null;
            if (profileImagePart != null && profileImagePart.getSize() > 0) {
                profileImagePath = saveUploadedFile(profileImagePart, request, username, "profile", userType);
                logger.info("Profile image path: " + profileImagePath);
            }

            String certificationPath = saveUploadedFile(certificationPart, request, username, "certification", userType);
            logger.info("Certification path: " + certificationPath);

            if (certificationPath == null) {
                throw new Exception("Certification document is required.");
            }

            // Create registration record
            String adminMessage = "admin".equals(userType)
                    ? "Auto-approved during registration"
                    : "Pending admin review";

            int registerID = registrationDAO.createRegistration(userType, adminMessage);

            if (registerID == -1) {
                throw new Exception("Failed to create registration record.");
            }

            logger.info("Registration ID created: " + registerID);

            // Create user record
            boolean userCreated = false;

            if ("admin".equals(userType)) {
                Admin admin = new Admin();
                admin.setRegisterID(registerID);
                admin.setUsername(username);
                admin.setPassword(password);
                admin.setName(name);
                admin.setEmail(email);
                admin.setPhone(phone);
                admin.setNric(nric);
                admin.setProfileImageFilePath(profileImagePath);
                admin.setBod(bod);
                admin.setCertificationFilePath(certificationPath);
                admin.setAddress(address);

                AdminDAO adminDAO = new AdminDAO();
                userCreated = adminDAO.createAdmin(admin);

            } else if ("instructor".equals(userType)) {
                String yearStr = request.getParameter("yearOfExperience");
                Integer yearOfExperience = null;
                if (yearStr != null && !yearStr.trim().isEmpty()) {
                    yearOfExperience = Integer.parseInt(yearStr);
                }

                Instructor instructor = new Instructor();
                instructor.setRegisterID(registerID);
                instructor.setUsername(username);
                instructor.setPassword(password);
                instructor.setName(name);
                instructor.setEmail(email);
                instructor.setPhone(phone);
                instructor.setNric(nric);
                instructor.setProfileImageFilePath(profileImagePath);
                instructor.setBod(bod);
                instructor.setCertificationFilePath(certificationPath);
                instructor.setYearOfExperience(yearOfExperience);
                instructor.setAddress(address);

                InstructorDAO instructorDAO = new InstructorDAO();
                userCreated = instructorDAO.createInstructor(instructor);
            }

            if (!userCreated) {
                throw new Exception("Failed to create user account.");
            }

            // SUCCESS
            logger.info("✓ Registration COMPLETED successfully!");

            HttpSession session = request.getSession();
            session.setAttribute("successMessage",
                    "admin".equals(userType)
                    ? "Admin account created successfully! You can now login."
                    : "Instructor registration submitted successfully! Please wait for admin approval.");

            response.sendRedirect(request.getContextPath() + "/general/login.jsp");

        } catch (Exception e) {
            logger.log(Level.SEVERE, "✗ Registration ERROR: " + e.getMessage());

            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/general/register_account.jsp").forward(request, response);

        } finally {
            logger.info("=== REGISTRATION END ===\n");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/general/register_account.jsp");
    }
}
