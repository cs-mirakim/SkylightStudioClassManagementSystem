package com.skylightstudio.classmanagement.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String DB_URL = "jdbc:derby://localhost:1527/SkylightStudioDB";
    private static final String DB_USER = "app";
    private static final String DB_PASSWORD = "app";

    static {
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            System.out.println("[DBConnection] Derby JDBC Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] ERROR: Derby driver not found");
            throw new RuntimeException("Derby JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        System.out.println("[DBConnection] Creating new connection...");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        System.out.println("[DBConnection] Connection created successfully");
        return conn;
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                    System.out.println("[DBConnection] Connection closed");
                }
            } catch (SQLException e) {
                System.err.println("[DBConnection] Error closing connection: " + e.getMessage());
            }
        }
    }
}
