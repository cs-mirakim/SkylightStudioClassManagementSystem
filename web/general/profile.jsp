<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%@ page import="com.skylightstudio.classmanagement.model.Admin" %>
<%@ page import="com.skylightstudio.classmanagement.model.Instructor" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
    // Check if user is logged in
    if (!SessionUtil.isLoggedIn(session)) {
        response.sendRedirect("login.jsp?error=access_denied&message=Please_login_to_access_this_page");
        return;
    }

    // Get user info from session
    String userRole = SessionUtil.getUserRole(session);
    Integer userId = SessionUtil.getUserId(session);
    String userName = SessionUtil.getUserName(session);
    String userEmail = SessionUtil.getUserEmail(session);

    // Get user object based on role
    Admin admin = null;
    Instructor instructor = null;

    if ("admin".equals(userRole)) {
        admin = SessionUtil.getAdminObject(session);
    } else if ("instructor".equals(userRole)) {
        instructor = SessionUtil.getInstructorObject(session);
    }

    // Initialize variables
    String username = "";
    String name = "";
    String email = "";
    String phone = "";
    String nric = "";
    String bod = "";
    String profileImagePath = "";
    String certificationPath = "";
    String certificationFileName = "";
    String address = "";
    String status = "";
    String dateJoined = "";
    String yearOfExperience = "";

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
    SimpleDateFormat datetimeFormat = new SimpleDateFormat("dd MMM yyyy HH:mm");

    // Populate data based on role
    if (admin != null) {
        username = admin.getUsername();
        name = admin.getName();
        email = admin.getEmail();
        phone = admin.getPhone() != null ? admin.getPhone() : "";
        nric = admin.getNric() != null ? admin.getNric() : "";
        if (admin.getBod() != null) {
            bod = dateFormat.format(admin.getBod());
        }
        profileImagePath = admin.getProfileImageFilePath();
        certificationPath = admin.getCertificationFilePath();
        if (certificationPath != null && !certificationPath.isEmpty()) {
            certificationFileName = certificationPath.substring(certificationPath.lastIndexOf("/") + 1);
        }
        address = admin.getAddress() != null ? admin.getAddress() : "";
        status = admin.getStatus() != null ? admin.getStatus() : "active";
        if (admin.getDateJoined() != null) {
            dateJoined = datetimeFormat.format(admin.getDateJoined());
        }
    } else if (instructor != null) {
        username = instructor.getUsername();
        name = instructor.getName();
        email = instructor.getEmail();
        phone = instructor.getPhone() != null ? instructor.getPhone() : "";
        nric = instructor.getNric() != null ? instructor.getNric() : "";
        if (instructor.getBod() != null) {
            bod = dateFormat.format(instructor.getBod());
        }
        profileImagePath = instructor.getProfileImageFilePath();
        certificationPath = instructor.getCertificationFilePath();
        if (certificationPath != null && !certificationPath.isEmpty()) {
            certificationFileName = certificationPath.substring(certificationPath.lastIndexOf("/") + 1);
        }
        address = instructor.getAddress() != null ? instructor.getAddress() : "";
        status = instructor.getStatus() != null ? instructor.getStatus() : "inactive";
        if (instructor.getDateJoined() != null) {
            dateJoined = datetimeFormat.format(instructor.getDateJoined());
        }
        if (instructor.getYearOfExperience() != null) {
            yearOfExperience = instructor.getYearOfExperience().toString();
        }
    }

    // Default profile image if none
    String profileImageDisplay = "";
    if (profileImagePath != null && !profileImagePath.isEmpty()) {
        profileImageDisplay = "../" + profileImagePath;
    } else {
        // Generate initial letter for avatar
        String avatarLetter = "U";
        if (name != null && !name.isEmpty()) {
            avatarLetter = name.substring(0, 1).toUpperCase();
        }
        profileImageDisplay = "https://via.placeholder.com/200x200?text=" + avatarLetter;
    }

    // Check if in edit mode
    boolean editMode = false;
    if (request.getParameter("edit") != null) {
        editMode = request.getParameter("edit").equals("true");
    }

    // Get success/error messages
    String message = request.getParameter("message");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>My Profile - Skylight Studio</title>

        <!-- Font Roboto -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Tailwind Custom Palette -->
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {
                            sans: ['Roboto', 'ui-sans-serif', 'system-ui'],
                            condensed: ['Roboto Condensed', 'ui-sans-serif'],
                            mono: ['Roboto Mono', 'monospace']
                        },
                        colors: {
                            /* Primary & Background */
                            dusty: '#B36D6D',
                            dustyHover: '#965656',
                            blush: '#F2D1D1',
                            blushHover: '#E8BEBE',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',

                            /* Text */
                            espresso: '#3D3434',
                            successText: '#1E3A1E',

                            /* Blue Accents */
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',

                            /* Alerts */
                            successBg: '#A5D6A7',
                            successTextDark: '#1B5E20',

                            warningBg: '#FFCC80',
                            warningText: '#E65100',

                            dangerBg: '#EF9A9A',
                            dangerText: '#B71C1C',

                            infoBg: '#A3C1D6',
                            infoText: '#2C5555',

                            /* Chips */
                            chipRose: '#FCE4EC',
                            chipSand: '#D9C5B2',
                            chipTeal: '#6D9B9B'
                        }
                    }
                }
            }
        </script>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8
                 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Page Header -->
                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <div class="flex justify-between items-center">
                        <div>
                            <h2 class="text-xl font-semibold mb-1 text-espresso">
                                My Profile
                            </h2>
                            <p class="text-sm text-espresso/60">
                                <%= editMode ? "Edit your personal and professional information" : "View your personal and professional information"%>
                            </p>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="px-3 py-1 rounded-full text-xs font-medium 
                                  <%= "active".equals(status) ? "bg-successBg text-successTextDark" : "bg-dangerBg text-dangerText"%>">
                                <%= status.toUpperCase()%>
                            </span>
                            <span class="px-3 py-1 rounded-full text-xs font-medium bg-blush text-espresso">
                                <%= userRole.equals("admin") ? "ADMIN" : "INSTRUCTOR"%>
                            </span>

                            <% if (!editMode) { %>
                            <a href="?edit=true"
                               class="px-4 py-2 bg-dusty hover:bg-dustyHover text-whitePure rounded-lg font-medium transition-colors text-sm flex items-center gap-2">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                </svg>
                                Edit Profile
                            </a>
                            <% } else { %>
                            <div class="flex gap-2">
                                <a href="?"
                                   class="px-4 py-2 bg-cloud hover:bg-blush text-espresso rounded-lg font-medium transition-colors text-sm flex items-center gap-2 border border-blush">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                    Cancel
                                </a>
                                <button type="submit" form="profileForm"
                                        class="px-4 py-2 bg-dusty hover:bg-dustyHover text-whitePure rounded-lg font-medium transition-colors text-sm flex items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                                    </svg>
                                    Save Changes
                                </button>
                            </div>
                            <% }%>
                        </div>
                    </div>
                </div>

                <!-- Success/Error Messages -->
                <% if (message != null && !message.isEmpty()) {
                        String displayMsg = message.replace("_", " ");
                %>
                <div class="mb-6 p-4 rounded-lg border-l-4 border-successTextDark bg-successBg">
                    <p class="text-successTextDark font-medium">
                        <%= displayMsg%>
                    </p>
                </div>
                <% } %>

                <% if (error != null && !error.isEmpty()) {
                        String errorMsg = "";
                        if ("update_failed".equals(error)) {
                            errorMsg = "Failed to update profile";
                            String errorDetail = request.getParameter("message");
                            if (errorDetail != null) {
                                errorMsg += ": " + errorDetail.replace("_", " ");
                            }
                        } else if ("invalid_role".equals(error)) {
                            errorMsg = "Invalid user role";
                        } else {
                            errorMsg = error.replace("_", " ");
                        }
                %>
                <div class="mb-6 p-4 rounded-lg border-l-4 border-dangerText bg-dangerBg">
                    <p class="text-dangerText font-medium">
                        <%= errorMsg%>
                    </p>
                </div>
                <% }%>

                <!-- Profile Content -->
                <form id="profileForm" action="../profile" method="POST" 
                      class="grid grid-cols-1 md:grid-cols-2 gap-8"
                      enctype="multipart/form-data">
                    <!-- LEFT COLUMN -->
                    <div class="flex flex-col gap-6">
                        <!-- Profile Image Section -->
                        <div>
                            <h3 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">
                                Profile Image
                            </h3>

                            <div class="flex flex-col items-center gap-4">
                                <div class="w-48 h-48 rounded-full border-4 border-blush overflow-hidden bg-cloud">
                                    <img id="profilePreview" 
                                         src="<%= profileImageDisplay%>" 
                                         alt="Profile Image" 
                                         class="w-full h-full object-cover" 
                                         onerror="this.src='https://via.placeholder.com/200x200?text=No+Image'" />
                                </div>

                                <% if (editMode) { %>
                                <div class="w-full">
                                    <label for="profileImage" class="block text-sm font-medium mb-2 text-espresso">
                                        Upload New Profile Image
                                    </label>
                                    <input id="profileImageInput" name="profileImage" type="file"
                                           accept=".jpg,.jpeg,.png"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-dusty file:text-whitePure hover:file:bg-dustyHover"
                                           onchange="previewProfileImage(event)" />
                                    <p class="text-xs text-espresso/70 mt-1">Accepted formats: JPG, PNG (Max: 2MB)</p>
                                </div>
                                <% } else { %>
                                <p class="text-sm text-espresso/70">
                                    Click "Edit Profile" to change your profile image
                                </p>
                                <% } %>
                            </div>
                        </div>

                        <!-- Personal Information Section -->
                        <div>
                            <h3 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">
                                Personal Information
                            </h3>

                            <div class="space-y-4">
                                <div>
                                    <label for="name" class="block text-sm font-medium mb-1 text-espresso">
                                        Full Name
                                    </label>
                                    <% if (editMode) {%>
                                    <input id="name" name="name" type="text" required
                                           value="<%= name%>"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= name%>
                                    </div>
                                    <% } %>
                                </div>

                                <div>
                                    <label for="email" class="block text-sm font-medium mb-1 text-espresso">
                                        Email
                                    </label>
                                    <% if (editMode) {%>
                                    <input id="email" name="email" type="email" required
                                           value="<%= email%>"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= email%>
                                    </div>
                                    <% } %>
                                </div>

                                <div>
                                    <label for="phone" class="block text-sm font-medium mb-1 text-espresso">
                                        Phone Number
                                    </label>
                                    <% if (editMode) {%>
                                    <input id="phone" name="phone" type="tel"
                                           value="<%= phone%>"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= phone != null && !phone.isEmpty() ? phone : "Not provided"%>
                                    </div>
                                    <% } %>
                                </div>

                                <div>
                                    <label for="nric" class="block text-sm font-medium mb-1 text-espresso">
                                        NRIC
                                    </label>
                                    <% if (editMode) {%>
                                    <input id="nric" name="nric" type="text" required
                                           value="<%= nric%>"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= nric%>
                                    </div>
                                    <% } %>
                                </div>

                                <div>
                                    <label for="bod" class="block text-sm font-medium mb-1 text-espresso">
                                        Date of Birth
                                    </label>
                                    <% if (editMode) {
                                            // Convert date format from database to HTML input format (yyyy-MM-dd)
                                            String htmlDateFormat = "";
                                            if (bod != null && !bod.isEmpty()) {
                                                try {
                                                    // Parse from dd-MM-yyyy to Date object
                                                    SimpleDateFormat displayFormat = new SimpleDateFormat("dd-MM-yyyy");
                                                    Date dateObj = displayFormat.parse(bod);

                                                    // Convert to yyyy-MM-dd format for HTML input
                                                    SimpleDateFormat htmlFormat = new SimpleDateFormat("yyyy-MM-dd");
                                                    htmlDateFormat = htmlFormat.format(dateObj);
                                                } catch (Exception e) {
                                                    // If can't parse, try direct format (maybe already in yyyy-MM-dd)
                                                    htmlDateFormat = bod;
                                                }
                                            }
                                    %>
                                    <input id="bod" name="bod" type="date"
                                           value="<%= htmlDateFormat%>"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= bod != null && !bod.isEmpty() ? bod : "Not provided"%>
                                    </div>
                                    <% }%>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- RIGHT COLUMN -->
                    <div class="flex flex-col gap-6">
                        <!-- Account Information Section -->
                        <div>
                            <h3 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">
                                Account Information
                            </h3>

                            <div class="space-y-4">
                                <div>
                                    <label class="block text-sm font-medium mb-1 text-espresso">
                                        Username
                                    </label>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= username%>
                                    </div>
                                    <p class="text-xs text-espresso/70 mt-1">Username cannot be changed</p>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium mb-1 text-espresso">
                                        User ID
                                    </label>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= userRole.equals("admin") ? "ADM" + userId : "INS" + userId%>
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium mb-1 text-espresso">
                                        Date Joined
                                    </label>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= dateJoined%>
                                    </div>
                                </div>

                                <div>
                                    <label for="status" class="block text-sm font-medium mb-1 text-espresso">
                                        Account Status
                                    </label>
                                    <% if (editMode) {%>
                                    <select id="status" name="status"
                                            class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition">
                                        <option value="active" <%= "active".equals(status) ? "selected" : ""%>>Active</option>
                                        <option value="inactive" <%= "inactive".equals(status) ? "selected" : ""%>>Inactive</option>
                                    </select>
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= status.substring(0, 1).toUpperCase() + status.substring(1)%>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- Professional Information Section (Conditional) -->
                        <% if (userRole.equals("instructor")) { %>
                        <div>
                            <h3 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">
                                Professional Information
                            </h3>

                            <div class="space-y-4">
                                <div>
                                    <label for="yearOfExperience" class="block text-sm font-medium mb-1 text-espresso">
                                        Years of Experience
                                    </label>
                                    <% if (editMode) {%>
                                    <input id="yearOfExperience" name="yearOfExperience" type="number" min="0"
                                           value="<%= yearOfExperience%>"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= yearOfExperience != null && !yearOfExperience.isEmpty() ? yearOfExperience + " years" : "Not specified"%>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <% }%>

                        <!-- Certification Section -->
                        <div>
                            <h3 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">
                                <%= userRole.equals("admin") ? "Supporting Document" : "Certification"%>
                            </h3>

                            <div class="space-y-4">
                                <!-- Current Document -->
                                <div>
                                    <label class="block text-sm font-medium mb-1 text-espresso">
                                        Current Document
                                    </label>
                                    <% if (certificationPath != null && !certificationPath.isEmpty()) {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg">
                                        <div class="flex justify-between items-center">
                                            <span class="text-espresso truncate">
                                                <%= certificationFileName%>
                                            </span>
                                            <button type="button" 
                                                    onclick="openCertificationModal('<%= "../" + certificationPath%>', '<%= certificationFileName%>')"
                                                    class="text-dusty hover:text-dustyHover font-medium text-sm">
                                                View
                                            </button>
                                        </div>
                                    </div>
                                    <% } else { %>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso/70">
                                        No document uploaded
                                    </div>
                                    <% } %>
                                </div>

                                <!-- Upload New Document -->
                                <% if (editMode) { %>
                                <div>
                                    <label for="certification" class="block text-sm font-medium mb-1 text-espresso">
                                        Upload New Document
                                    </label>
                                    <input id="certificationInput" name="certification" type="file"
                                           accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-dusty file:text-whitePure hover:file:bg-dustyHover" />
                                    <p class="text-xs text-espresso/70 mt-1">
                                        Accepted formats: PDF, JPG, PNG, DOC (Max: 5MB)
                                    </p>
                                </div>
                                <% } else if (certificationPath == null || certificationPath.isEmpty()) { %>
                                <p class="text-sm text-espresso/70">
                                    Click "Edit Profile" to upload a document
                                </p>
                                <% } %>
                            </div>
                        </div>

                        <!-- Address Section -->
                        <div>
                            <h3 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">
                                Address
                            </h3>

                            <div>
                                <label for="address" class="block text-sm font-medium mb-1 text-espresso">
                                    Full Address
                                </label>
                                <% if (editMode) {%>
                                <textarea id="address" name="address" required rows="4"
                                          class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition resize-none"><%= address%></textarea>
                                <% } else {%>
                                <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso whitespace-pre-line">
                                    <%= address != null && !address.isEmpty() ? address : "Not provided"%>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Password Change Section (Only in Edit Mode) -->
                    <% if (editMode) { %>
                    <div class="md:col-span-2 mt-6 pt-6 border-t border-petal">
                        <h3 class="text-lg font-medium text-dusty mb-4">Change Password (Optional)</h3>

                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label for="currentPassword" class="block text-sm font-medium mb-1 text-espresso">
                                    Current Password
                                </label>
                                <input id="currentPassword" name="currentPassword" type="password"
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                            </div>

                            <div>
                                <label for="newPassword" class="block text-sm font-medium mb-1 text-espresso">
                                    New Password
                                </label>
                                <input id="newPassword" name="newPassword" type="password" minlength="6"
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                            </div>

                            <div>
                                <label for="confirmPassword" class="block text-sm font-medium mb-1 text-espresso">
                                    Confirm New Password
                                </label>
                                <input id="confirmPassword" name="confirmPassword" type="password"
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                            </div>
                        </div>
                        <p id="passwordFeedback" class="text-xs mt-2 text-espresso/70">
                            Leave password fields empty if you don't want to change password
                        </p>
                    </div>
                    <% } %>

                    <!-- Hidden submit button for form submission -->
                    <% if (editMode) { %>
                    <input type="submit" id="formSubmit" class="hidden">
                    <% } %>
                </form>

                <div class="mt-auto pt-10 text-center text-xs text-espresso/30 italic">
                    -- End of Profile Page --
                </div>

            </div>

        </main>

        <!-- Certification Modal -->
        <div id="certificationModal" class="hidden fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
            <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-5xl max-h-[90vh] flex flex-col">
                <!-- Modal Header -->
                <div class="flex items-center justify-between p-6 border-b border-petal">
                    <h3 class="text-xl font-semibold text-espresso" id="modalTitle">Document Preview</h3>
                    <button onclick="closeCertificationModal()" 
                            class="p-2 rounded-full hover:bg-blush text-espresso/60 hover:text-espresso transition-colors">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <!-- Modal Content -->
                <div class="flex-1 overflow-auto p-6" id="modalContent">
                    <!-- Content will be loaded here -->
                </div>

                <!-- Modal Footer -->
                <div class="p-4 border-t border-petal flex justify-end gap-3">
                    <a id="downloadLink" href="#" target="_blank"
                       class="px-4 py-2 bg-teal hover:bg-tealHover text-whitePure rounded-lg font-medium transition-colors text-sm flex items-center gap-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        Download
                    </a>
                    <button onclick="closeCertificationModal()"
                            class="px-4 py-2 bg-cloud hover:bg-blush text-espresso rounded-lg font-medium transition-colors text-sm border border-blush">
                        Close
                    </button>
                </div>
            </div>
        </div>

        <jsp:include page="../util/footer.jsp" />
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <script>
                        // Preview profile image when new file is selected (only in edit mode)
                        function previewProfileImage(event) {
                            const file = event.target.files[0];
                            if (file) {
                                // Validate file size (2MB max)
                                if (file.size > 2 * 1024 * 1024) {
                                    alert('Profile image must be less than 2MB');
                                    event.target.value = '';
                                    return;
                                }

                                // Validate file type
                                const validTypes = ['image/jpeg', 'image/jpg', 'image/png'];
                                if (!validTypes.includes(file.type)) {
                                    alert('Only JPG and PNG images are allowed');
                                    event.target.value = '';
                                    return;
                                }

                                const reader = new FileReader();
                                reader.onload = function (e) {
                                    document.getElementById('profilePreview').src = e.target.result;
                                };
                                reader.readAsDataURL(file);
                            }
                        }

                        // Password validation (only in edit mode)
                        function validatePassword() {
                            const currentPassword = document.getElementById('currentPassword');
                            const newPassword = document.getElementById('newPassword');
                            const confirmPassword = document.getElementById('confirmPassword');
                            const feedback = document.getElementById('passwordFeedback');

                            if (!currentPassword || !newPassword || !confirmPassword)
                                return true;

                            // Check if any password field is filled
                            const anyFilled = currentPassword.value || newPassword.value || confirmPassword.value;

                            if (!anyFilled) {
                                feedback.textContent = 'Leave password fields empty if you don\'t want to change password';
                                feedback.className = 'text-xs mt-2 text-espresso/70';
                                return true;
                            }

                            // All password fields must be filled
                            if (!currentPassword.value || !newPassword.value || !confirmPassword.value) {
                                feedback.textContent = 'Please fill all password fields to change password';
                                feedback.className = 'text-xs mt-2 text-warningText';
                                return false;
                            }

                            if (newPassword.value.length < 6) {
                                feedback.textContent = 'New password must be at least 6 characters';
                                feedback.className = 'text-xs mt-2 text-warningText';
                                return false;
                            }

                            if (newPassword.value !== confirmPassword.value) {
                                feedback.textContent = 'New passwords do not match';
                                feedback.className = 'text-xs mt-2 text-dangerText';
                                return false;
                            }

                            feedback.textContent = 'Passwords valid ?';
                            feedback.className = 'text-xs mt-2 text-successTextDark';
                            return true;
                        }

                        // File size validation
                        function validateFileSize(fileInput, maxSizeMB, fieldName) {
                            if (fileInput && fileInput.files.length > 0) {
                                const fileSize = fileInput.files[0].size / 1024 / 1024; // in MB
                                if (fileSize > maxSizeMB) {
                                    alert(fieldName + ' must be less than ' + maxSizeMB + 'MB');
                                    fileInput.value = '';
                                    return false;
                                }

                                // Validate file types
                                const file = fileInput.files[0];
                                const fileName = file.name.toLowerCase();

                                if (fileInput.id === 'profileImageInput') {
                                    if (!fileName.match(/\.(jpg|jpeg|png)$/)) {
                                        alert('Profile image must be JPG or PNG format');
                                        fileInput.value = '';
                                        return false;
                                    }
                                } else if (fileInput.id === 'certificationInput') {
                                    if (!fileName.match(/\.(pdf|jpg|jpeg|png|doc|docx)$/)) {
                                        alert('Document must be PDF, JPG, PNG, DOC, or DOCX format');
                                        fileInput.value = '';
                                        return false;
                                    }
                                }
                            }
                            return true;
                        }

                        // Certification Modal functions
                        function openCertificationModal(fileUrl, fileName) {
                            document.getElementById('modalTitle').textContent = fileName;
                            document.getElementById('downloadLink').href = fileUrl;

                            const modalContent = document.getElementById('modalContent');
                            const fileExt = fileName.split('.').pop().toLowerCase();

                            if (fileExt === 'pdf') {
                                // Show PDF embed
                                modalContent.innerHTML = `
                        <div class="w-full h-[70vh]">
                            <embed src="${fileUrl}" type="application/pdf" width="100%" height="100%" />
                            <p class="text-xs text-espresso/70 mt-2 text-center">
                                If PDF doesn't load, <a href="${fileUrl}" target="_blank" class="text-dusty hover:underline">click here to open</a>
                            </p>
                        </div>
                    `;
                            } else if (['jpg', 'jpeg', 'png'].includes(fileExt)) {
                                // Show image
                                modalContent.innerHTML = `
                        <div class="flex justify-center">
                            <img src="${fileUrl}" alt="${fileName}" class="max-w-full max-h-[70vh] object-contain rounded-lg" />
                        </div>
                    `;
                            } else {
                                // Show download link for other formats
                                modalContent.innerHTML = `
                        <div class="text-center p-8">
                            <svg class="w-16 h-16 mx-auto text-dusty mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                            <h4 class="text-lg font-medium text-espresso mb-2">Document Preview Not Available</h4>
                            <p class="text-espresso/70 mb-4">This document format cannot be previewed in browser.</p>
                            <p class="text-sm text-espresso/70">Please download the file to view it.</p>
                        </div>
                    `;
                            }

                            document.getElementById('certificationModal').classList.remove('hidden');
                        }

                        function closeCertificationModal() {
                            document.getElementById('certificationModal').classList.add('hidden');
                            document.getElementById('modalContent').innerHTML = '';
                        }

                        // Form submission validation
            <% if (editMode) { %>
                        document.getElementById('profileForm').addEventListener('submit', function (e) {
                            e.preventDefault();

                            // Validate file sizes
                            const profileImage = document.getElementById('profileImageInput');
                            const certification = document.getElementById('certificationInput');

                            if (!validateFileSize(profileImage, 2, 'Profile image') ||
                                    !validateFileSize(certification, 5, 'Document')) {
                                return;
                            }

                            // Validate passwords if entered
                            if (!validatePassword()) {
                                return;
                            }

                            // Validate NRIC format
                            const nric = document.getElementById('nric');
                            if (nric && nric.value && !nric.value.match(/^\d{12}$/)) {
                                alert('NRIC must be exactly 12 digits without dashes');
                                nric.focus();
                                return;
                            }

                            // Validate date of birth (optional)
                            const bod = document.getElementById('bod');
                            if (bod && bod.value) {
                                const birthDate = new Date(bod.value);
                                const today = new Date();
                                let age = today.getFullYear() - birthDate.getFullYear();
                                const monthDiff = today.getMonth() - birthDate.getMonth();
                                if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
                                    age--;
                                }

                                if (age < 18) {
                                    alert('You must be at least 18 years old');
                                    bod.focus();
                                    return;
                                }
                            }

                            // Validate email format
                            const email = document.getElementById('email');
                            if (email && email.value) {
                                const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                                if (!emailPattern.test(email.value)) {
                                    alert('Please enter a valid email address');
                                    email.focus();
                                    return;
                                }
                            }

                            // Show confirmation dialog
                            if (confirm('Are you sure you want to save all changes?')) {
                                // Submit the form
                                this.submit();
                            }
                        });
            <% } %>

                        // Initialize password validation listeners
            <% if (editMode) { %>
                        const currentPasswordInput = document.getElementById('currentPassword');
                        const newPasswordInput = document.getElementById('newPassword');
                        const confirmPasswordInput = document.getElementById('confirmPassword');

                        if (currentPasswordInput && newPasswordInput && confirmPasswordInput) {
                            currentPasswordInput.addEventListener('input', validatePassword);
                            newPasswordInput.addEventListener('input', validatePassword);
                            confirmPasswordInput.addEventListener('input', validatePassword);
                        }
            <% }%>

                        // Close modal with Escape key
                        document.addEventListener('keydown', function (e) {
                            if (e.key === 'Escape') {
                                closeCertificationModal();
                            }
                        });

                        // Close modal when clicking outside
                        document.getElementById('certificationModal').addEventListener('click', function (e) {
                            if (e.target.id === 'certificationModal') {
                                closeCertificationModal();
                            }
                        });
        </script>

    </body>
</html>