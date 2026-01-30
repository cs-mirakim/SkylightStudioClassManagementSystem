<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Class Feedback Form</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        
        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>
        
        <!-- Font Awesome for Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
            * {
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Roboto', sans-serif;
                background: #FDF8F8;
                min-height: 100vh;
            }
            
            .form-container {
                max-width: 800px;
                margin: 0 auto;
            }
            
            .question-card {
                background: #FFFFFF;
                border-radius: 12px;
                padding: 32px;
                margin-bottom: 24px;
                box-shadow: 0 2px 8px rgba(61, 52, 52, 0.06);
                border: 1px solid #EFE1E1;
                transition: all 0.3s ease;
            }
            
            .question-card:hover {
                box-shadow: 0 4px 16px rgba(61, 52, 52, 0.08);
            }
            
            .star-rating-container {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 16px;
                margin: 24px 0;
                flex-wrap: wrap;
            }
            
            .rating-label-left,
            .rating-label-right {
                font-size: 14px;
                color: #3D3434;
                font-weight: 500;
                min-width: 80px;
                text-align: center;
            }
            
            .rating-label-left {
                order: 1;
            }
            
            .star-rating {
                display: flex;
                gap: 4px;
                order: 2;
                flex-direction: row-reverse; /* Reverse the order for RTL */
            }
            
            .rating-label-right {
                order: 3;
            }
            
            .star-rating input {
                display: none;
            }
            
            .star-rating label {
                cursor: pointer;
                font-size: 40px;
                color: #F2D1D1;
                transition: all 0.2s ease;
                position: relative;
            }
            
            .star-rating label:hover,
            .star-rating label:hover ~ label,
            .star-rating input:checked ~ label {
                color: #B36D6D;
                transform: scale(1.05);
            }
            
            /* Highlight stars from right to left when selected */
            .star-rating input:checked + label {
                color: #B36D6D;
            }
            
            /* When hovering over a star, highlight it and all stars to its right (visually left) */
            .star-rating label:hover,
            .star-rating label:hover ~ label {
                color: #B36D6D;
            }
            
            /* Keep all stars after the hovered one in default color */
            .star-rating:hover label {
                color: #F2D1D1;
            }
            
            .star-rating label:hover,
            .star-rating label:hover ~ label,
            .star-rating input:checked ~ label,
            .star-rating input:checked + label {
                color: #B36D6D;
            }
            
            .rating-text {
                text-align: center;
                margin-top: 16px;
                font-size: 18px;
                font-weight: 500;
                color: #3D3434;
                min-height: 24px;
            }
            
            textarea {
                width: 100%;
                min-height: 120px;
                padding: 16px;
                border: 2px solid #EFE1E1;
                border-radius: 8px;
                font-size: 16px;
                font-family: 'Roboto', sans-serif;
                resize: vertical;
                transition: all 0.3s ease;
                background-color: #FFFFFF;
                color: #3D3434;
            }
            
            textarea:focus {
                outline: none;
                border-color: #B36D6D;
                box-shadow: 0 0 0 3px rgba(179, 109, 109, 0.1);
            }
            
            textarea::placeholder {
                color: #B36D6D;
                opacity: 0.6;
            }
            
            .submit-btn {
                background: linear-gradient(135deg, #B36D6D 0%, #965656 100%);
                color: white;
                border: none;
                padding: 16px 48px;
                font-size: 18px;
                font-weight: 500;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(179, 109, 109, 0.3);
            }
            
            .submit-btn:hover {
                background: linear-gradient(135deg, #965656 0%, #7A4545 100%);
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(179, 109, 109, 0.4);
            }
            
            .submit-btn:active {
                transform: translateY(0);
            }
            
            .submit-btn:disabled {
                background: #F2D1D1;
                color: #B36D6D;
                cursor: not-allowed;
                transform: none;
                box-shadow: none;
                opacity: 0.7;
            }
            
            .required {
                color: #B36D6D;
            }
            
            .progress-bar {
                width: 100%;
                height: 6px;
                background: #EFE1E1;
                border-radius: 3px;
                overflow: hidden;
                margin: 32px 0;
            }
            
            .progress-fill {
                height: 100%;
                background: linear-gradient(90deg, #B36D6D 0%, #965656 100%);
                transition: width 0.5s ease;
            }
            
            .form-header {
                text-align: center;
                margin-bottom: 48px;
            }
            
            .form-title {
                font-size: 32px;
                font-weight: 700;
                color: #3D3434;
                margin-bottom: 16px;
            }
            
            .form-subtitle {
                font-size: 18px;
                color: #3D3434;
                opacity: 0.8;
                max-width: 600px;
                margin: 0 auto;
                line-height: 1.6;
            }
            
            .thank-you-message {
                text-align: center;
                padding: 64px 32px;
                background: #FFFFFF;
                border-radius: 16px;
                box-shadow: 0 8px 32px rgba(61, 52, 52, 0.1);
                display: none;
                border: 1px solid #EFE1E1;
            }
            
            .thank-you-title {
                font-size: 36px;
                font-weight: 700;
                color: #3D3434;
                margin-bottom: 24px;
            }
            
            .thank-you-text {
                font-size: 18px;
                color: #3D3434;
                opacity: 0.8;
                margin-bottom: 32px;
                line-height: 1.6;
            }
            
            .back-btn {
                background: #1E3A1E;
                color: white;
                border: none;
                padding: 12px 32px;
                font-size: 16px;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.3s ease;
            }
            
            .back-btn:hover {
                background: #152915;
            }
            
            .question-number {
                display: inline-block;
                width: 32px;
                height: 32px;
                background: #B36D6D;
                color: white;
                border-radius: 50%;
                text-align: center;
                line-height: 32px;
                margin-right: 12px;
                font-weight: 500;
            }
            
            .question-text {
                font-size: 20px;
                font-weight: 500;
                color: #3D3434;
                margin-bottom: 8px;
            }
            
            .question-hint {
                font-size: 14px;
                color: #3D3434;
                opacity: 0.7;
                margin-top: 4px;
                font-style: italic;
            }
            
            .char-count {
                color: #3D3434;
                opacity: 0.7;
            }
            
            .success-check {
                color: #1E3A1E;
            }
            
            @media (max-width: 768px) {
                .question-card {
                    padding: 24px;
                }
                
                .form-title {
                    font-size: 28px;
                }
                
                .form-subtitle {
                    font-size: 16px;
                }
                
                .star-rating label {
                    font-size: 36px;
                }
                
                .submit-btn {
                    width: 100%;
                    padding: 20px;
                }
                
                .rating-label-left,
                .rating-label-right {
                    font-size: 12px;
                    min-width: 60px;
                }
            }
            
            @media (max-width: 480px) {
                .question-card {
                    padding: 20px;
                }
                
                .form-title {
                    font-size: 24px;
                }
                
                .star-rating label {
                    font-size: 32px;
                }
                
                .star-rating-container {
                    gap: 8px;
                }
                
                .rating-label-left,
                .rating-label-right {
                    font-size: 11px;
                    min-width: 50px;
                }
            }
            
            /* Notification styling with the new color palette */
            .notification-success {
                background-color: #1E3A1E;
                color: white;
            }
            
            .notification-error {
                background-color: #B36D6D;
                color: white;
            }
            
            .notification-info {
                background-color: #965656;
                color: white;
            }
        </style>
    </head>

    <body class="bg-cloud">
        <%
            // Get current date for the form
            SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy");
            String currentDate = dateFormat.format(new Date());
            
            SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
            String currentTime = timeFormat.format(new Date());
            
            // Get instructorID and classID from request parameters
            // In a real application, these would come from the session or URL parameters
            String instructorID = request.getParameter("instructorID");
            String classID = request.getParameter("classID");
            
            // For testing/demo, you can set defaults
            if (instructorID == null || instructorID.isEmpty()) {
                instructorID = "1"; // Default for testing
            }
            if (classID == null || classID.isEmpty()) {
                classID = "1"; // Default for testing
            }
        %>

        <div class="form-container p-4 md:p-8">
            <!-- Progress Bar -->
            <div class="progress-bar">
                <div id="progressFill" class="progress-fill" style="width: 0%"></div>
            </div>
            
            <!-- Form Header -->
            <div class="form-header">
                <h1 class="form-title">Class Feedback Form</h1>
                <p class="form-subtitle">
                    Please take a moment to rate your instructor's performance. 
                    Your feedback helps us improve the quality of our classes.
                </p>
                <p class="text-espresso opacity-80 mt-4">
                    <i class="far fa-calendar-alt mr-2"></i><%= currentDate %> • 
                    <i class="far fa-clock mr-2"></i><%= currentTime %>
                </p>
                <!-- Display which instructor and class this feedback is for -->
                <div class="mt-4 p-3 bg-petal rounded-lg inline-block">
                    <p class="text-espresso text-sm">
                        <i class="fas fa-chalkboard-teacher mr-2"></i>Instructor ID: <span class="font-semibold"><%= instructorID %></span> •
                        <i class="fas fa-users mr-2 ml-4"></i>Class ID: <span class="font-semibold"><%= classID %></span>
                    </p>
                </div>
            </div>

            <!-- Feedback Form -->
            <form id="feedbackForm" action="submitFeedback" method="POST" class="space-y-6">
                <!-- Hidden fields for required database columns -->
                <input type="hidden" name="instructorID" value="<%= instructorID %>">
                <input type="hidden" name="classID" value="<%= classID %>">
                <input type="hidden" name="feedbackDate" value="<%= new java.sql.Date(new java.util.Date().getTime()) %>">
                <!-- Note: submissionTime is not in your database table, but feedbackDate is -->
                
                <!-- Question 1: Teaching Skills -->
                <div class="question-card" id="question1">
                    <div class="flex items-start mb-4">
                        <span class="question-number">1</span>
                        <div>
                            <h2 class="question-text">Teaching Skills <span class="required">*</span></h2>
                            <p class="question-hint">How effectively did the instructor demonstrate and explain the exercises?</p>
                        </div>
                    </div>
                    
                    <div class="star-rating-container">
                        <span class="rating-label-left">Poor</span>
                        
                        <div class="star-rating">
                            <!-- Note: Values are reversed for RTL highlighting -->
                            <input type="radio" id="teachingSkill5" name="teachingSkill" value="5" required>
                            <label for="teachingSkill5">★</label>
                            
                            <input type="radio" id="teachingSkill4" name="teachingSkill" value="4">
                            <label for="teachingSkill4">★</label>
                            
                            <input type="radio" id="teachingSkill3" name="teachingSkill" value="3">
                            <label for="teachingSkill3">★</label>
                            
                            <input type="radio" id="teachingSkill2" name="teachingSkill" value="2">
                            <label for="teachingSkill2">★</label>
                            
                            <input type="radio" id="teachingSkill1" name="teachingSkill" value="1">
                            <label for="teachingSkill1">★</label>
                        </div>
                        
                        <span class="rating-label-right">Excellent</span>
                    </div>
                    
                    <div id="teachingSkillText" class="rating-text"></div>
                </div>
                
                <!-- Question 2: Communication -->
                <div class="question-card" id="question2">
                    <div class="flex items-start mb-4">
                        <span class="question-number">2</span>
                        <div>
                            <h2 class="question-text">Communication <span class="required">*</span></h2>
                            <p class="question-hint">How clearly did the instructor communicate instructions and provide feedback?</p>
                        </div>
                    </div>
                    
                    <div class="star-rating-container">
                        <span class="rating-label-left">Poor</span>
                        
                        <div class="star-rating">
                            <input type="radio" id="communication5" name="communication" value="5" required>
                            <label for="communication5">★</label>
                            
                            <input type="radio" id="communication4" name="communication" value="4">
                            <label for="communication4">★</label>
                            
                            <input type="radio" id="communication3" name="communication" value="3">
                            <label for="communication3">★</label>
                            
                            <input type="radio" id="communication2" name="communication" value="2">
                            <label for="communication2">★</label>
                            
                            <input type="radio" id="communication1" name="communication" value="1">
                            <label for="communication1">★</label>
                        </div>
                        
                        <span class="rating-label-right">Excellent</span>
                    </div>
                    
                    <div id="communicationText" class="rating-text"></div>
                </div>
                
                <!-- Question 3: Support & Interaction -->
                <div class="question-card" id="question3">
                    <div class="flex items-start mb-4">
                        <span class="question-number">3</span>
                        <div>
                            <h2 class="question-text">Support & Interaction <span class="required">*</span></h2>
                            <p class="question-hint">How supportive and engaging was the instructor during the session?</p>
                        </div>
                    </div>
                    
                    <div class="star-rating-container">
                        <span class="rating-label-left">Poor</span>
                        
                        <div class="star-rating">
                            <input type="radio" id="supportInteraction5" name="supportInteraction" value="5" required>
                            <label for="supportInteraction5">★</label>
                            
                            <input type="radio" id="supportInteraction4" name="supportInteraction" value="4">
                            <label for="supportInteraction4">★</label>
                            
                            <input type="radio" id="supportInteraction3" name="supportInteraction" value="3">
                            <label for="supportInteraction3">★</label>
                            
                            <input type="radio" id="supportInteraction2" name="supportInteraction" value="2">
                            <label for="supportInteraction2">★</label>
                            
                            <input type="radio" id="supportInteraction1" name="supportInteraction" value="1">
                            <label for="supportInteraction1">★</label>
                        </div>
                        
                        <span class="rating-label-right">Excellent</span>
                    </div>
                    
                    <div id="supportInteractionText" class="rating-text"></div>
                </div>
                
                <!-- Question 4: Punctuality -->
                <div class="question-card" id="question4">
                    <div class="flex items-start mb-4">
                        <span class="question-number">4</span>
                        <div>
                            <h2 class="question-text">Punctuality <span class="required">*</span></h2>
                            <p class="question-hint">How punctual was the instructor in starting and ending the class?</p>
                        </div>
                    </div>
                    
                    <div class="star-rating-container">
                        <span class="rating-label-left">Poor</span>
                        
                        <div class="star-rating">
                            <input type="radio" id="punctuality5" name="punctuality" value="5" required>
                            <label for="punctuality5">★</label>
                            
                            <input type="radio" id="punctuality4" name="punctuality" value="4">
                            <label for="punctuality4">★</label>
                            
                            <input type="radio" id="punctuality3" name="punctuality" value="3">
                            <label for="punctuality3">★</label>
                            
                            <input type="radio" id="punctuality2" name="punctuality" value="2">
                            <label for="punctuality2">★</label>
                            
                            <input type="radio" id="punctuality1" name="punctuality" value="1">
                            <label for="punctuality1">★</label>
                        </div>
                        
                        <span class="rating-label-right">Excellent</span>
                    </div>
                    
                    <div id="punctualityText" class="rating-text"></div>
                </div>
                
                <!-- Question 5: Overall Rating -->
                <div class="question-card" id="question5">
                    <div class="flex items-start mb-4">
                        <span class="question-number">5</span>
                        <div>
                            <h2 class="question-text">Overall Rating <span class="required">*</span></h2>
                            <p class="question-hint">Overall, how would you rate your experience with this instructor?</p>
                        </div>
                    </div>
                    
                    <div class="star-rating-container">
                        <span class="rating-label-left">Poor</span>
                        
                        <div class="star-rating">
                            <input type="radio" id="overallRating5" name="overallRating" value="5" required>
                            <label for="overallRating5">★</label>
                            
                            <input type="radio" id="overallRating4" name="overallRating" value="4">
                            <label for="overallRating4">★</label>
                            
                            <input type="radio" id="overallRating3" name="overallRating" value="3">
                            <label for="overallRating3">★</label>
                            
                            <input type="radio" id="overallRating2" name="overallRating" value="2">
                            <label for="overallRating2">★</label>
                            
                            <input type="radio" id="overallRating1" name="overallRating" value="1">
                            <label for="overallRating1">★</label>
                        </div>
                        
                        <span class="rating-label-right">Excellent</span>
                    </div>
                    
                    <div id="overallRatingText" class="rating-text"></div>
                </div>
                
                <!-- Question 6: Additional Comments -->
                <div class="question-card" id="question6">
                    <div class="flex items-start mb-4">
                        <span class="question-number">6</span>
                        <div>
                            <h2 class="question-text">Additional Comments</h2>
                            <p class="question-hint">Share any additional feedback, suggestions, or specific examples (Optional)</p>
                        </div>
                    </div>
                    
                    <textarea 
                        name="comments" 
                        placeholder="Enter your comments here... 
                                        Examples:
                                        - What did you enjoy most about the class?
                                        - Are there areas where the instructor could improve?
                                        - Any specific exercises or moments that stood out?"
                        maxlength="2000"
                        rows="4"></textarea>
                    
                    <div class="text-right mt-2 text-sm char-count">
                        <span id="charCount">0</span>/2000 characters
                    </div>
                </div>
                
                <!-- Submit Button -->
                <div class="text-center mt-8">
                    <button type="submit" id="submitBtn" class="submit-btn">
                        <i class="fas fa-paper-plane mr-2"></i> Submit Feedback
                    </button>
                    <p class="text-espresso opacity-80 text-sm mt-4">
                        All fields marked with <span class="required">*</span> are required. Comments are optional.
                    </p>
                </div>
            </form>
            
            <!-- Thank You Message -->
            <div id="thankYouMessage" class="thank-you-message">
                <div class="success-check text-6xl mb-6">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h2 class="thank-you-title">Thank You!</h2>
                <p class="thank-you-text">
                    Your feedback has been submitted successfully. 
                    Your input is valuable in helping us maintain high-quality instruction.
                </p>
                <p class="text-espresso opacity-80 mb-8">
                    <i class="far fa-calendar-alt mr-2"></i>Submitted on <%= currentDate %> at <%= currentTime %>
                </p>
                <button onclick="location.reload()" class="back-btn">
                    <i class="fas fa-redo mr-2"></i>Submit Another Response
                </button>
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById('feedbackForm');
                const thankYouMessage = document.getElementById('thankYouMessage');
                const progressFill = document.getElementById('progressFill');
                const charCount = document.getElementById('charCount');
                const commentsTextarea = document.querySelector('textarea[name="comments"]');
                const submitBtn = document.getElementById('submitBtn');
                
                // Rating descriptions
                const ratingDescriptions = {
                    1: "Poor - Needs significant improvement",
                    2: "Fair - Room for improvement",
                    3: "Good - Meets expectations",
                    4: "Very Good - Exceeds expectations",
                    5: "Excellent - Outstanding performance"
                };
                
                // Initialize star rating functionality
                initializeStarRatings();
                
                // Character count for comments
                if (commentsTextarea) {
                    commentsTextarea.addEventListener('input', function() {
                        charCount.textContent = this.value.length;
                    });
                }
                
                // Update progress bar
                function updateProgress() {
                    const questions = ['teachingSkill', 'communication', 'supportInteraction', 'punctuality', 'overallRating'];
                    const answered = questions.filter(q => {
                        const input = form.querySelector(`input[name="${q}"]:checked`);
                        return input !== null;
                    }).length;
                    
                    const progress = (answered / questions.length) * 100;
                    progressFill.style.width = `${progress}%`;
                    
                    // Enable/disable submit button based on progress
                    submitBtn.disabled = answered < questions.length;
                    
                    // Log for debugging
                    console.log('Answered:', answered, 'out of', questions.length, 'Progress:', progress, '%', 'Submit button disabled:', submitBtn.disabled);
                }
                
                // Initialize star ratings with text updates
                function initializeStarRatings() {
                    const starGroups = document.querySelectorAll('.star-rating');
                    
                    starGroups.forEach(group => {
                        const inputs = group.querySelectorAll('input[type="radio"]');
                        const questionId = group.closest('.question-card').id;
                        const textElement = document.getElementById(`${questionId.replace('question', '').toLowerCase()}Text`);
                        
                        inputs.forEach(input => {
                            // Add change event listener
                            input.addEventListener('change', function() {
                                const value = parseInt(this.value);
                                if (textElement) {
                                    textElement.textContent = ratingDescriptions[value];
                                }
                                updateProgress();
                            });
                            
                            // Also trigger change on label click for better UX
                            const label = group.querySelector(`label[for="${input.id}"]`);
                            if (label) {
                                label.addEventListener('click', function() {
                                    // Force the radio button to be checked
                                    input.checked = true;
                                    // Trigger change event immediately
                                    const event = new Event('change');
                                    input.dispatchEvent(event);
                                });
                            }
                        });
                    });
                }
                
                // Form submission - SIMPLIFIED VERSION
                form.addEventListener('submit', function(e) {
                    e.preventDefault();
                    
                    console.log('Form submit triggered');
                    
                    // Simple check - if submit button is not disabled, allow submission
                    if (submitBtn.disabled) {
                        showNotification('Please answer all required questions before submitting.', 'error');
                        return;
                    }
                    
                    // Show loading state
                    const originalBtnText = submitBtn.innerHTML;
                    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Submitting...';
                    submitBtn.disabled = true;
                    
                    // Collect form data
                    const formData = new FormData(form);
                    const data = {
                        instructorID: formData.get('instructorID'),
                        classID: formData.get('classID'),
                        teachingSkill: formData.get('teachingSkill'),
                        communication: formData.get('communication'),
                        supportInteraction: formData.get('supportInteraction'),
                        punctuality: formData.get('punctuality'),
                        overallRating: formData.get('overallRating'),
                        comments: formData.get('comments'),
                        feedbackDate: formData.get('feedbackDate')
                    };
                    
                    console.log('Form data for database:', data);
                    
                    // Check if all required fields are filled (extra validation)
                    const requiredFields = ['teachingSkill', 'communication', 'supportInteraction', 'punctuality', 'overallRating'];
                    const missingFields = requiredFields.filter(field => !data[field]);
                    
                    if (missingFields.length > 0) {
                        showNotification('Please answer all required star rating questions.', 'error');
                        submitBtn.innerHTML = originalBtnText;
                        submitBtn.disabled = false;
                        return;
                    }
                    
                    // Simulate API call (replace with actual AJAX submission)
                    setTimeout(() => {
                        // Hide form and show thank you message
                        form.style.display = 'none';
                        thankYouMessage.style.display = 'block';
                        progressFill.style.display = 'none';
                        
                        // Reset button state
                        submitBtn.innerHTML = originalBtnText;
                        submitBtn.disabled = false;
                    }, 1500);
                });
                
                // Auto-save functionality (optional)
                let autoSaveTimer;
                
                function autoSave() {
                    const formData = new FormData(form);
                    const data = Object.fromEntries(formData);
                    
                    // Save to localStorage
                    localStorage.setItem('feedbackDraft', JSON.stringify(data));
                    localStorage.setItem('feedbackLastSave', new Date().toISOString());
                    
                    // Show auto-save notification
                    showNotification('Progress auto-saved', 'info');
                }
                
                function loadDraft() {
                    const draft = localStorage.getItem('feedbackDraft');
                    if (draft) {
                        const data = JSON.parse(draft);
                        
                        // Load radio button values
                        Object.keys(data).forEach(key => {
                            if (key !== 'comments') {
                                const input = form.querySelector(`input[name="${key}"][value="${data[key]}"]`);
                                if (input) {
                                    input.checked = true;
                                    // Trigger change event to update UI
                                    const event = new Event('change');
                                    input.dispatchEvent(event);
                                }
                            }
                        });
                        
                        // Load comments
                        if (data.comments && commentsTextarea) {
                            commentsTextarea.value = data.comments;
                            charCount.textContent = data.comments.length;
                        }
                        
                        // Show restore notification
                        showNotification('Previous draft restored', 'info');
                    }
                }
                
                function showNotification(message, type) {
                    // Create notification element
                    const notification = document.createElement('div');
                    notification.className = 'fixed top-4 right-4 px-4 py-2 rounded-lg shadow-lg ' + 
                        (type === 'success' ? 'notification-success' :
                         type === 'error' ? 'notification-error' :
                         'notification-info');
                    notification.textContent = message;
                    notification.style.zIndex = '9999';
                    notification.style.transition = 'all 0.3s ease';
                    
                    document.body.appendChild(notification);
                    
                    // Remove after 3 seconds
                    setTimeout(() => {
                        notification.style.opacity = '0';
                        setTimeout(() => {
                            document.body.removeChild(notification);
                        }, 300);
                    }, 3000);
                }
                
                // Set up auto-save on input changes
                form.addEventListener('input', function() {
                    clearTimeout(autoSaveTimer);
                    autoSaveTimer = setTimeout(autoSave, 2000);
                });
                
                loadDraft();
                
                form.addEventListener('submit', function() {
                    localStorage.removeItem('feedbackDraft');
                    localStorage.removeItem('feedbackLastSave');
                });
                
                updateProgress();
                
                console.log('Initial form state loaded');
                console.log('Submit button disabled:', submitBtn.disabled);
                
            });
        </script>
    </body>
</html>