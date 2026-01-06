package com.skylightstudio.classmanagement.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class Admin implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer adminID;
    private Registration registration;
    private String username;
    private String password;
    private String name;
    private String email;
    private String phone;
    private String nric;
    private String profileImageFilePath;
    private Date BOD;
    private String certificationFilePath;
    private String address;
    private String status;
    private Timestamp dateJoined;

    public Admin() {
    }

    public Integer getRegisterID() {
        return (registration != null) ? registration.getRegisterID() : null;
    }

    public void setAdminID(Integer adminID) {
        this.adminID = adminID;
    }

    public void setRegistration(Registration registration) {
        this.registration = registration;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setNric(String nric) {
        this.nric = nric;
    }

    public void setProfileImageFilePath(String profileImageFilePath) {
        this.profileImageFilePath = profileImageFilePath;
    }

    public void setBOD(Date BOD) {
        this.BOD = BOD;
    }

    public void setCertificationFilePath(String certificationFilePath) {
        this.certificationFilePath = certificationFilePath;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setDateJoined(Timestamp dateJoined) {
        this.dateJoined = dateJoined;
    }

    public Integer getAdminID() {
        return adminID;
    }

    public Registration getRegistration() {
        return registration;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getNric() {
        return nric;
    }

    public String getProfileImageFilePath() {
        return profileImageFilePath;
    }

    public Date getBOD() {
        return BOD;
    }

    public String getCertificationFilePath() {
        return certificationFilePath;
    }

    public String getAddress() {
        return address;
    }

    public String getStatus() {
        return status;
    }

    public Timestamp getDateJoined() {
        return dateJoined;
    }
}
