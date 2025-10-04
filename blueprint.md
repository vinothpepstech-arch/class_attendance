# Project Blueprint

## Overview

This document outlines the structure, features, and implementation plan for the `attendance_PT` application. The application is a Flutter-based mobile app for managing student attendance, with separate interfaces for students and administrators.

## Implemented Features

*   User authentication with email and password using Supabase.
*   Role-based access control for students and admins/teachers.
*   A theme provider for toggling between light and dark modes.
*   A student dashboard to view announcements and mark attendance.
*   An admin dashboard to view student attendance statistics, search for students, and manage announcements.

## Planned Changes

1.  **Rename Application**: Change the application name from `myapp` to `attendance_PT`.
2.  **Modify Student Screen**:
    *   Remove the "Present" button from the student attendance screen.
    *   Students will only be able to mark themselves as "Absent" and provide a reason.
    *   Each time a student marks themselves as absent, a new row will be inserted into the `student_login` table.
3.  **Modify Admin Screen**:
    *   Add a feature for administrators to mark a student as "Present".
    *   This action will insert a new row into the `student_login` table with the student's name and a "present" status.
4.  **Database Interaction**:
    *   Modify the database logic to insert a new row for each attendance event (present or absent) instead of updating existing records.

## File-by-File Implementation Plan

*   **`pubspec.yaml`**:
    *   Change the `name` attribute from `myapp` to `attendance_PT`.
*   **`lib/screens/student_screen.dart`**:
    *   Remove the `ToggleButtons` for selecting "Present" or "Absent".
    *   The UI will default to marking the student as "Absent".
    *   The `_submitAttendance` function will be updated to always set the `status` to `false` (absent) and insert a new record.
*   **`lib/screens/admin_teacher_screen.dart`**:
    *   In the `AttendanceManagementScreen`, add a button or action to mark a student as "Present".
    *   Implement a function to handle this action, which will insert a new record into the `student_login` table with the `status` set to `true` (present).
*   **`lib/providers/student_login_provider.dart`**:
    *   Remove the `updateStudentStatus` function.
    *   Add a new function, `addStudentAttendance`, to insert a new attendance record.
    *   The `fetchStudents` function will need to be updated to correctly display the latest status for each student, since there can now be multiple records for each student. A possible approach is to fetch the most recent record for each student.