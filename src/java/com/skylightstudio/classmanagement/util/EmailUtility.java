package com.skylightstudio.classmanagement.util;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;
import javax.servlet.ServletContext;

public class EmailUtility {

    public static boolean sendResetPasswordEmail(ServletContext context,
            String toEmail,
            String token) throws Exception {

        // Get email configuration from web.xml
        String smtpHost = context.getInitParameter("smtpHost");
        String smtpPort = context.getInitParameter("smtpPort");
        String smtpUsername = context.getInitParameter("smtpUsername");
        String smtpPassword = context.getInitParameter("smtpPassword");
        String fromEmail = context.getInitParameter("smtpFromEmail");
        String resetLinkBase = context.getInitParameter("resetLinkBase");

        // Create reset link
        String resetLink = resetLinkBase + "?token=" + token;

        // Email properties
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);

        // Create session
        Session session = Session.getInstance(props,
                new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUsername, smtpPassword);
            }
        });

        try {
            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Skylight Studio - Password Reset Request");

            // Email content (plain text)
            String emailText = "Dear Skylight Studio User,\n\n"
                    + "You have requested to reset your password. Please click the link below to reset your password:\n\n"
                    + resetLink + "\n\n"
                    + "This link will expire in 1 hour.\n\n"
                    + "If you did not request this password reset, please ignore this email.\n\n"
                    + "Best regards,\n"
                    + "Skylight Studio Team\n\n"
                    + "Note: This is an automated message, please do not reply.";

            message.setText(emailText);

            // Send email
            Transport.send(message);
            System.out.println("Password reset email sent to: " + toEmail);
            return true;

        } catch (MessagingException e) {
            System.err.println("Error sending email to " + toEmail + ": " + e.getMessage());
            throw new Exception("Failed to send reset email: " + e.getMessage());
        }
    }
}
