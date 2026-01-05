<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        
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
        
        <title>Reset Password - Skylight Studio Management System</title>
    </head>
    
    <body class="bg-cloud font-sans text-espresso flex items-center justify-center min-h-screen p-4">
        <div class="bg-whitePure p-6 md:p-8 rounded-xl shadow-lg shadow-blush/30 w-full max-w-md border border-blush">
            <!-- Header -->
            <h1 class="text-2xl font-bold mb-6 text-center pb-2 border-b border-petal">
                Reset Password
            </h1>

            <div class="flex flex-col gap-4">
                <!-- New Password -->
                <div>
                    <label for="new_password" class="block text-sm font-medium mb-1 text-espresso">
                        New Password
                    </label>
                    <input
                        id="new_password"
                        type="password"
                        class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                        placeholder="Enter new password"
                        required
                        />
                </div>

                <!-- Confirm Password -->
                <div>
                    <label for="confirm_password" class="block text-sm font-medium mb-1 text-espresso">
                        Confirm Password
                    </label>
                    <input
                        id="confirm_password"
                        type="password"
                        class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                        placeholder="Confirm new password"
                        required
                        />
                </div>

                <!-- Submit Button -->
                <button
                    onclick="submitReset()"
                    class="w-full bg-dusty hover:bg-dustyHover text-whitePure p-3 rounded-lg font-medium transition-colors mt-2"
                    >
                    Submit
                </button>
            </div>
        </div>

        <script>
            function submitReset() {
                const newPwd = document.getElementById('new_password').value;
                const confirmPwd = document.getElementById('confirm_password').value;

                if (newPwd !== confirmPwd) {
                    alert('Password and Confirm Password do not match.');
                    return;
                }

                // Dummy process
                alert('Password reset successful!');

                // Redirect to login page
                window.location.href = 'login.jsp';
            }
        </script>
    </body>
</html>