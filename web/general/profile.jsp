<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Simulate user data (in real app, this would come from session/database)
    String userRole = "admin"; // or "instructor"
    String userId = "1";
    String username = "johndoe";
    String name = "John Doe";
    String email = "john@skylightstudio.com";
    String phone = "+60 12-345 6789";
    String nric = "901010-10-1010";
    String bod = "1990-10-10";
    String certification = "admin_certificate.pdf";
    String address = "123 Studio Street, Creative City, 50000";
    String status = "active";
    String dateJoined = "2023-01-15 09:30:00";
    String profileImage = "default_profile.jpg";
    String yearOfExperience = "5"; // For instructor only

    // Check if in edit mode
    boolean editMode = false;
    if (request.getParameter("edit") != null) {
        editMode = request.getParameter("edit").equals("true");
    }
%>

<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%
    // Check if user is logged in
    if (!SessionUtil.isLoggedIn(session)) {
        // Redirect to login page if not logged in
        response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_this_page");
        return;
    }
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

                <!-- Profile Content -->
                <form id="profileForm" action="profile_save.jsp" method="POST" 
                      class="grid grid-cols-1 md:grid-cols-2 gap-8"
                      enctype="multipart/form-data">
                    <input type="hidden" name="editMode" value="<%= editMode%>">

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
                                         src="../util/profiles/<%= profileImage%>" 
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
                                        <%= phone != null ? phone : "Not provided"%>
                                    </div>
                                    <% } %>
                                </div>

                                <div>
                                    <label for="nric" class="block text-sm font-medium mb-1 text-espresso">
                                        NRIC
                                    </label>
                                    <% if (editMode) {%>
                                    <input id="nric" name="nric" type="text" required
                                           pattern="\d{6}-\d{2}-\d{4}"
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
                                    <% if (editMode) {%>
                                    <input id="bod" name="bod" type="date" required
                                           value="<%= bod%>"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= bod%>
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
                                    <input id="yearOfExperience" name="yearOfExperience" type="number" required min="0"
                                           value="<%= yearOfExperience%>"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                                    <% } else {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg text-espresso">
                                        <%= yearOfExperience%> years
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
                                    <% if (certification != null && !certification.isEmpty()) {%>
                                    <div class="p-3 bg-cloud border border-blush rounded-lg">
                                        <div class="flex justify-between items-center">
                                            <span class="text-espresso truncate">
                                                <%= certification%>
                                            </span>
                                            <a href="../util/certifications/<%= certification%>" 
                                               target="_blank"
                                               class="text-dusty hover:text-dustyHover font-medium text-sm">
                                                View
                                            </a>
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
                                <% } else if (certification == null || certification.isEmpty()) { %>
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
                                    <%= address%>
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

        <jsp:include page="../util/footer.jsp" />

        <jsp:include page="../util/sidebar.jsp" />

        <script src="../util/sidebar.js"></script>

        <script>
                                               // Preview profile image when new file is selected (only in edit mode)
                                               function previewProfileImage(event) {
                                                   const file = event.target.files[0];
                                                   if (file) {
                                                       const reader = new FileReader();
                                                       reader.onload = function (e) {
                                                           document.getElementById('profilePreview').src = e.target.result;
                                                       };
                                                       reader.readAsDataURL(file);
                                                   }
                                               }

                                               // Password validation (only in edit mode)
                                               function validatePassword() {
                                                   const newPassword = document.getElementById('newPassword');
                                                   const confirmPassword = document.getElementById('confirmPassword');
                                                   const feedback = document.getElementById('passwordFeedback');

                                                   if (!newPassword || !confirmPassword)
                                                       return true;

                                                   if (newPassword.value && confirmPassword.value) {
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

                                                       feedback.textContent = 'Passwords match ✓';
                                                       feedback.className = 'text-xs mt-2 text-successTextDark';
                                                       return true;
                                                   }

                                                   return true;
                                               }

                                               // File size validation (only in edit mode)
                                               function validateFileSize(fileInput, maxSizeMB) {
                                                   if (fileInput && fileInput.files.length > 0) {
                                                       const fileSize = fileInput.files[0].size / 1024 / 1024; // in MB
                                                       if (fileSize > maxSizeMB) {
                                                           alert(`File size must be less than ${maxSizeMB}MB`);
                                                           fileInput.value = '';
                                                           return false;
                                                       }
                                                   }
                                                   return true;
                                               }

                                               // Form submission (only in edit mode)
            <% if (editMode) { %>
                                               document.getElementById('profileForm').addEventListener('submit', function (e) {
                                                   e.preventDefault();

                                                   // Validate file sizes
                                                   const profileImage = document.getElementById('profileImageInput');
                                                   const certification = document.getElementById('certificationInput');

                                                   if (!validateFileSize(profileImage, 2) || !validateFileSize(certification, 5)) {
                                                       return;
                                                   }

                                                   // Validate passwords if entered
                                                   const currentPassword = document.getElementById('currentPassword');
                                                   const newPassword = document.getElementById('newPassword');
                                                   const confirmPassword = document.getElementById('confirmPassword');

                                                   if (currentPassword && newPassword && confirmPassword) {
                                                       if ((newPassword.value || confirmPassword.value) && !currentPassword.value) {
                                                           alert('Please enter your current password to change password');
                                                           return;
                                                       }

                                                       if (newPassword.value && confirmPassword.value && newPassword.value !== confirmPassword.value) {
                                                           alert('New passwords do not match');
                                                           return;
                                                       }
                                                   }

                                                   // Show success message and submit form
                                                   if (confirm('Are you sure you want to save all changes?')) {
                                                       // In real application, this would submit the form
                                                       // For demo purposes, we'll simulate a successful save
                                                       alert('Profile updated successfully!');

                                                       // Remove edit parameter and reload
                                                       setTimeout(() => {
                                                           window.location.href = window.location.pathname;
                                                       }, 1000);
                                                   }
                                               });
            <% } %>

                                               // Initialize password validation (only in edit mode)
            <% if (editMode) { %>
                                               const newPasswordInput = document.getElementById('newPassword');
                                               const confirmPasswordInput = document.getElementById('confirmPassword');

                                               if (newPasswordInput && confirmPasswordInput) {
                                                   newPasswordInput.addEventListener('input', validatePassword);
                                                   confirmPasswordInput.addEventListener('input', validatePassword);
                                               }
            <% }%>
        </script>

    </body>
</html>