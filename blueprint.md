# Project Blueprint

## Overview

This is a Flutter application for a school management system using Supabase as the backend. It supports three user roles: admin, teacher, and student. The application provides features for authentication, attendance tracking, and announcements.

## Features Implemented

### 1. Authentication & Roles
- **Login:** Users can log in with their email and password.
- **Sample Logins:** The login screen now includes buttons to pre-fill sample credentials for admin, teacher, and student roles to facilitate testing.
- **Role-Based Access:** After login, the app identifies the user's role (`admin`, `teacher`, or `student`) from the `profiles` table in Supabase.
- **Role-Specific Dashboards:**
  - Students are directed to the `StudentScreen`.
  - Admins and Teachers are directed to the `AdminTeacherScreen`.
- **Session Management:** The app checks for an existing session on startup and directs the user to the appropriate screen, bypassing login if already authenticated.
- **Logout:** Users can log out, which clears their session and returns them to the `LoginScreen`.

### 2. Student Dashboard (`StudentScreen`)
- **Attendance Marking:** Students can mark their attendance for the current day.
  - They can select 'Present' or 'Absent'.
  - If 'Absent', they can provide a reason.
- **Data Submission:** Attendance status is submitted to the `attendance` table in Supabase. An `upsert` operation is used to create or update the record for the student and date.

### 3. Admin/Teacher Dashboard (`AdminTeacherScreen`)
- **Bottom Navigation:** The dashboard uses a `BottomNavigationBar` to switch between two main sections:
  - Attendance Management
  - Announcements
- **Attendance Management:**
  - Displays a list of all students.
  - Allows the admin/teacher to update the attendance status ('Present' or 'Absent') for each student for the current day.
  - **Total Attendance Summary:** Displays a summary of the total number of present and absent students for the current day.
- **Announcements:**
  - Provides a set of predefined announcement types (e.g., 'Assemble', 'Dismissal', 'Emergency').
  - Allows the admin/teacher to select an announcement type and post it.
  - **Instructions:** Provides a new "Post Instruction" button that allows the admin to quickly send one of 5 predefined messages.
  - Announcements are saved to the `announcements` table in Supabase.

## Architecture & Design

- **State Management:** `provider` is used for managing the application's state, particularly for authentication (`AuthProvider`).
- **Service Layer:** A `SupabaseService` class centralizes the Supabase client initialization and access, promoting a clean separation of concerns.
- **Routing:**
  - Initial routing is handled by a Consumer<AuthProvider> widget in `main.dart` which listens to `AuthProvider` and decides which screen to show (`SplashScreen`, `LoginScreen`, or a dashboard).
  - Navigation between dashboards is handled by `Navigator.pushReplacement` after a successful login.
- **UI:** The UI is built with standard Material Design widgets.

## Supabase Schema

1.  **`profiles`**
    - `id` (UUID, Primary Key, Foreign Key to `auth.users`)
    - `full_name` (TEXT)
    - `role` (TEXT, CHECK constraint: 'admin', 'teacher', 'student')

2.  **`attendance`**
    - `id` (UUID, Primary Key)
    - `student_id` (UUID, Foreign Key to `profiles.id`)
    - `date` (DATE)
    - `status` (TEXT, CHECK constraint: 'present', 'absent')
    - `reason` (TEXT)
    - `UNIQUE` constraint on `(student_id, date)`.

3.  **`announcements`**
    - `id` (UUID, Primary Key)
    - `title` (TEXT)
    - `content` (TEXT)
    - `created_at` (TIMESTAMP WITH TIME ZONE)

4.  **`play_queue`**
    - `id` (UUID, Primary Key)
    - `audio_file` (TEXT)
    - `last_updated` (TIMESTAMP WITH TIME ZONE)

5.  **`student_login`**
    - `id` (BIGSERIAL, Primary Key)
    - `name` (VARCHAR(50))
    - `status` (BOOLEAN)
    - `reason` (VARCHAR(50))
    - `last_updated` (TIMESTAMP WITH TIME ZONE)

## Current Task: Enhance Admin Dashboard

I have enhanced the admin dashboard with the following features:

1.  **Total Student Attendance:** The attendance screen now displays a summary of the total number of present and absent students for the current day.

2.  **Instructions Announcements:** A new "Post Instruction" button has been added to the announcements screen, allowing admins to quickly send predefined instructions.
