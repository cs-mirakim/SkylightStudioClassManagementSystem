<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        
        <!-- Font Roboto -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        
        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>
        
        <!-- Tailwind Custom Palette (Sama seperti template) -->
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
        
        <title>Login - Skylight Studio Management System</title>
    </head>

    <body class="bg-cloud font-sans text-espresso min-h-screen flex items-center justify-center p-6">

        <div class="w-full max-w-4xl bg-whitePure rounded-xl shadow-lg shadow-blush/30 flex overflow-hidden border border-blush">

            <!-- LEFT SIDE (BRANDING) -->
            <div class="hidden md:flex flex-col items-center justify-center 
                 bg-dusty text-whitePure w-1/2 p-8">

                <div class="w-56 h-56 rounded-full bg-whitePure flex items-center justify-center mb-6 shadow-lg">
                    <img src="../util/skylightstudio_logo.jpg" alt="Skylight Studio Logo" 
                         class="w-40 h-40 object-contain rounded-full" />
                </div>

                <h1 class="text-2xl font-bold text-center">Skylight Studio Class Management System</h1>
                <p class="mt-2 text-center text-sm opacity-90">
                    Efficient studio management for creative professionals
                </p>
            </div>

            <!-- RIGHT SIDE (FORM) -->
            <div class="w-full md:w-1/2 p-8">

                <h1 class="text-2xl font-bold mb-6 text-left pb-2 border-b border-petal">
                    Login
                </h1>

                <!-- roles -->
                <fieldset class="mb-6">
                    <legend class="block mb-2 font-medium text-espresso">Login As</legend>
                    <div class="flex gap-4">
                        <label class="inline-flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="role" value="admin" checked 
                                   class="text-dusty focus:ring-dusty" />
                            <span class="text-espresso">Admin</span>
                        </label>
                        <label class="inline-flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="role" value="instructor" 
                                   class="text-dusty focus:ring-dusty" />
                            <span class="text-espresso">Instructor</span>
                        </label>
                    </div>
                </fieldset>

                <form id="loginForm" onsubmit="onLogin(event)" class="space-y-4">

                    <div>
                        <label for="login_email" class="block text-sm font-medium mb-1 text-espresso">
                            Email
                        </label>
                        <input
                            id="login_email"
                            type="email"
                            required
                            class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                            placeholder="you@example.com"
                            />
                    </div>

                    <div>
                        <label for="login_password" class="block text-sm font-medium mb-1 text-espresso">
                            Password
                        </label>
                        <input
                            id="login_password"
                            type="password"
                            required
                            class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                            placeholder="Enter your password"
                            />

                        <div class="mt-2 text-right">
                            <a href="#" onclick="openPopup(); return false;"
                               class="text-dusty hover:text-dustyHover text-sm font-medium transition-colors">
                                Forgot Password?
                            </a>
                        </div>
                    </div>

                    <!-- LOGIN BUTTON -->
                    <button type="submit"
                            class="w-full bg-dusty hover:bg-dustyHover text-whitePure p-3 rounded-lg font-medium transition-colors mt-4">
                        Login
                    </button>

                    <div class="flex items-center justify-center mt-4 text-sm pt-4 border-t border-petal">
                        <p class="text-espresso/70">
                            Don't have an account?
                            <a href="register_account.jsp" class="text-dusty hover:text-dustyHover font-semibold ml-1 transition-colors">
                                Register Now
                            </a>
                        </p>
                    </div>

                </form>
            </div>
        </div>

        <!-- POPUP RESET PASSWORD -->
        <div id="popup"
             class="hidden fixed inset-0 bg-espresso/50 flex items-center justify-center p-4 z-50">
            <div class="bg-whitePure p-6 rounded-xl shadow-lg shadow-blush/30 w-full max-w-sm border border-blush">

                <!-- Header -->
                <h2 class="text-xl font-semibold mb-4 text-center text-espresso">
                    Reset Password
                </h2>

                <!-- Divider line -->
                <hr class="border-petal mb-4">

                <!-- Radio buttons: Login As -->
                <fieldset class="mb-4">
                    <legend class="block mb-2 font-medium text-espresso">Account Type</legend>
                    <div class="flex gap-4">
                        <label class="inline-flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="popup_role" value="admin" checked 
                                   class="text-dusty focus:ring-dusty cursor-pointer"/>
                            <span class="text-espresso">Admin</span>
                        </label>
                        <label class="inline-flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="popup_role" value="instructor" 
                                   class="text-dusty focus:ring-dusty cursor-pointer"/>
                            <span class="text-espresso">Instructor</span>
                        </label>
                    </div>
                </fieldset>

                <!-- Email input -->
                <input id="reset_email" type="email"
                       placeholder="Enter your email"
                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition mb-4" />

                <!-- Buttons -->
                <button onclick="submitReset()"
                        class="w-full bg-dusty hover:bg-dustyHover text-whitePure p-3 rounded-lg font-medium mb-3 transition-colors">
                    Submit
                </button>

                <button onclick="closePopup()"
                        class="w-full bg-cloud hover:bg-blush text-espresso p-3 rounded-lg font-medium transition-colors border border-blush">
                    Cancel
                </button>
            </div>
        </div>


        <script>
            function getSelectedRole() {
                return document.querySelector('input[name="role"]:checked').value;
            }

            function onLogin(e) {
                e.preventDefault();
                const role = getSelectedRole();
                if (role === "admin")
                    window.location.href = "../admin/dashboard_admin.jsp";
                else if (role === "instructor")
                    window.location.href = "dashboard_instructor.jsp";
            }

            function openPopup() {
                document.getElementById("popup").classList.remove("hidden");
            }
            
            function closePopup() {
                document.getElementById("popup").classList.add("hidden");
            }
            
            function submitReset() {
                const email = document.getElementById("reset_email").value;
                if (!email) {
                    alert("Please enter your email");
                    return;
                }
                window.location.href = "reset_password.jsp";
            }
        </script>

    </body>
</html>