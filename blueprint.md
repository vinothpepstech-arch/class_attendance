# App Blueprint

## Overview

This document outlines the project structure, features, and design of a Flutter-based School Management application. The app provides role-based access for Admins, Teachers, and Students, integrating with Supabase for backend services, including authentication and database management.

## Key Features

### 1. User Roles & Authentication
- **Three Roles:** The app supports `admin`, `teacher`, and `student` roles.
- **Authentication:** Users log in with their email and password. The app fetches their role from the `profiles` table in Supabase to determine which dashboard to display.
- **State Management:** The user's authentication state and role are managed globally using the `provider` package.

### 2. Student Dashboard (`StudentScreen`)
- **Attendance Marking:**
  - Students can mark their own attendance for the current day as either 'Present' or 'Absent'.
  - If a student marks themselves as 'Absent', they are required to provide a reason.
  - The attendance data is saved to the `attendance` table, uniquely identified by the student's ID and the date.
- **View Announcements:**
  - Students can view a list of the latest announcements posted by admins or teachers, ensuring they stay informed about school-wide updates.

### 3. Admin/Teacher Dashboard (`AdminTeacherScreen`)
- **Modern Navigation:** The dashboard uses a clean, icon-driven `BottomNavigationBar` to switch between two main sections:
  - Attendance Management
  - Announcements
- **Attendance Management:**
  - **Visual Summary:** Displays a dynamic and visually appealing summary of the total number of present and absent students for the current day in prominent cards.
  - **Student List:** Shows a list of all students with their current attendance status clearly marked with colors (green for present, red for absent).
  - **Update Attendance:** Allows the admin/teacher to quickly update the attendance status ('Present' or 'Absent') for each student.
  - **View Absence Reason:** If a student is marked absent, tapping on their name will open a dialog box displaying the reason they provided.
- **Announcements & Instructions:**
  - **Create Announcements:** Provides an intuitive interface with predefined announcement types (e.g., 'Assemble', 'Dismissal') and a text field for custom messages.
  - **Post Announcements:** Allows the admin/teacher to post announcements that become immediately visible to all students.
  - **View Past Announcements:** Displays a list of previously sent announcements for reference.

## Architecture & Design

### UI/UX Principles
- **Modern Aesthetics:** The app uses a modern, clean, and visually balanced design based on Material Design 3.
- **Cool & Smooth UI:** Incorporates smooth animations, a vibrant color scheme derived from a seed color, and custom `Google Fonts` typography for a premium user experience.
- **Responsive Design:** All screens are fully responsive and adapt gracefully to different screen sizes, ensuring a consistent experience on both mobile and web platforms.
- **Intuitive Components:** Utilizes clear iconography, well-spaced layouts, and interactive elements like cards and chips to make navigation and interaction effortless.

### Technical Stack
- **Framework:** Flutter
- **Backend:** Supabase (Authentication & PostgreSQL Database)
- **State Management:** Provider
- **UI Toolkit:** Material Design 3
- **Typography:** google_fonts

### Database Schema
- **`profiles`**: Stores user information, including `full_name` and `role`, linked to `auth.users`.
- **`attendance`**: Records daily attendance for each student, including `status` and `reason` for absence.
- **`announcements`**: Stores all announcements with a `title`, `content`, and `created_at` timestamp.
