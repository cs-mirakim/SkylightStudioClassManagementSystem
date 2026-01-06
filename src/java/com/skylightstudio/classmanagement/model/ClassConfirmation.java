package com.skylightstudio.classmanagement.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class ClassConfirmation implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer confirmID;
    private Clazz clazz;        // UPDATE: dari classObj ke clazz
    private Instructor instructor;
    private String action;
    private Timestamp actionAt;
    private String cancellationReason;
    private Timestamp cancelledAt;

    public ClassConfirmation() {
    }

    public Integer getClassID() {
        return (clazz != null) ? clazz.getClassID() : null;
    }

    public Integer getInstructorID() {
        return (instructor != null) ? instructor.getInstructorID() : null;
    }

    public void setConfirmID(Integer confirmID) {
        this.confirmID = confirmID;
    }

    public void setClazz(Clazz clazz) {
        this.clazz = clazz;
    }

    public void setInstructor(Instructor instructor) {
        this.instructor = instructor;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public void setActionAt(Timestamp actionAt) {
        this.actionAt = actionAt;
    }

    public void setCancellationReason(String cancellationReason) {
        this.cancellationReason = cancellationReason;
    }

    public void setCancelledAt(Timestamp cancelledAt) {
        this.cancelledAt = cancelledAt;
    }

    public Integer getConfirmID() {
        return confirmID;
    }

    public Clazz getClazz() {
        return clazz;
    }

    public Instructor getInstructor() {
        return instructor;
    }

    public String getAction() {
        return action;
    }

    public Timestamp getActionAt() {
        return actionAt;
    }

    public String getCancellationReason() {
        return cancellationReason;
    }

    public Timestamp getCancelledAt() {
        return cancelledAt;
    }
}
