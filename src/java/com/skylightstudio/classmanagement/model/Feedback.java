package com.skylightstudio.classmanagement.model;

import java.io.Serializable;
import java.sql.Date;

public class Feedback implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer feedbackID;
    private Instructor instructor;
    private Clazz clazz;        // UPDATE: dari classObj ke clazz
    private Integer teachingSkill;
    private Integer communication;
    private Integer supportInteraction;
    private Integer punctuality;
    private Integer overallRating;
    private String comments;
    private Date feedbackDate;

    public Feedback() {
    }

    public Integer getInstructorID() {
        return (instructor != null) ? instructor.getInstructorID() : null;
    }

    public Integer getClassID() {
        return (clazz != null) ? clazz.getClassID() : null;
    }

    public void setFeedbackID(Integer feedbackID) {
        this.feedbackID = feedbackID;
    }

    public void setInstructor(Instructor instructor) {
        this.instructor = instructor;
    }

    public void setClazz(Clazz clazz) {
        this.clazz = clazz;
    }

    public void setTeachingSkill(Integer teachingSkill) {
        this.teachingSkill = teachingSkill;
    }

    public void setCommunication(Integer communication) {
        this.communication = communication;
    }

    public void setSupportInteraction(Integer supportInteraction) {
        this.supportInteraction = supportInteraction;
    }

    public void setPunctuality(Integer punctuality) {
        this.punctuality = punctuality;
    }

    public void setOverallRating(Integer overallRating) {
        this.overallRating = overallRating;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public void setFeedbackDate(Date feedbackDate) {
        this.feedbackDate = feedbackDate;
    }

    public Integer getFeedbackID() {
        return feedbackID;
    }

    public Instructor getInstructor() {
        return instructor;
    }

    public Clazz getClazz() {
        return clazz;
    }

    public Integer getTeachingSkill() {
        return teachingSkill;
    }

    public Integer getCommunication() {
        return communication;
    }

    public Integer getSupportInteraction() {
        return supportInteraction;
    }

    public Integer getPunctuality() {
        return punctuality;
    }

    public Integer getOverallRating() {
        return overallRating;
    }

    public String getComments() {
        return comments;
    }

    public Date getFeedbackDate() {
        return feedbackDate;
    }
}
