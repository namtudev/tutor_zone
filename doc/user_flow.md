I'll design comprehensive user flow scenarios for your tutoring management system. Let me break down each feature into detailed user journeys.

## User Flow Scenarios for Tutoring Management System

### 1. Student Management Flows

#### 1.1 Add New Student
**Scenario**: Teacher wants to add a new student to the system

**Flow**:
1. User clicks "Add Student" button from dashboard/student list
2. System displays student form with fields:
    - Name (required)
    - Email (optional)
    - Phone (optional)
    - Subject(s) - multi-select or tags
    - Hourly rate
    - Notes/Goals text area
3. User fills in student information
4. User clicks "Save Student"
5. System validates required fields
6. System saves student and shows success message
7. User is redirected to student profile or student list

**Alternative Paths**:
- Validation error: System highlights missing/invalid fields
- Duplicate student: System warns if similar name exists
- Cancel: User clicks cancel, returns to previous screen without saving

#### 1.2 Edit Student Profile
**Scenario**: Teacher needs to update student information or rate

**Flow**:
1. User navigates to student list
2. User clicks on student name or "Edit" button
3. System displays pre-filled form with current information
4. User modifies desired fields
5. User clicks "Update"
6. System saves changes and shows confirmation
7. User sees updated information

#### 1.3 View Student Details
**Scenario**: Teacher wants to review student's history and balance

**Flow**:
1. User clicks on student from list/dashboard
2. System displays student profile showing:
    - Basic info and rate
    - Current balance (prepaid/owed)
    - Recent sessions list
    - Total hours taught
    - Notes/goals
3. User can navigate to edit or add new session from this view

### 2. Session Tracking Flows

#### 2.1 Log Manual Session
**Scenario**: Teacher finished a session and wants to log it

**Flow**:
1. User clicks "Add Session" (from dashboard or student profile)
2. System displays session form:
    - Student dropdown (pre-selected if from student profile)
    - Date picker (defaults to today)
    - Start time
    - End time
    - Duration (auto-calculated)
    - Session notes
    - Payment status (Paid/Unpaid toggle)
3. User fills in session details
4. System auto-calculates duration and session cost
5. User reviews and clicks "Save Session"
6. System updates student balance accordingly
7. Success message with option to add another session

#### 2.2 Quick Log from Timer
**Scenario**: Teacher uses timer during session

**Flow**:
1. User selects student and clicks "Start Timer"
2. Timer runs with live duration display
3. User clicks "Stop Timer" when session ends
4. System pre-fills session form with:
    - Selected student
    - Current date
    - Actual start/end times
    - Calculated duration
5. User adds notes and payment status
6. User saves session

#### 2.3 Edit Past Session
**Scenario**: Teacher needs to correct session details

**Flow**:
1. User navigates to session list/history
2. User finds session and clicks "Edit"
3. System shows pre-filled form
4. User updates information
5. System recalculates duration/cost if times changed
6. User saves changes
7. System updates balances if payment status changed

### 3. Payment & Balance Flows

#### 3.1 Mark Session as Paid
**Scenario**: Student pays for completed sessions

**Flow**:
1. User views student profile or session list
2. User sees unpaid sessions highlighted
3. User selects one or multiple unpaid sessions
4. User clicks "Mark as Paid"
5. System shows payment summary:
    - Selected sessions
    - Total amount
    - Payment date (editable)
6. User confirms payment
7. System updates session status and student balance
8. Success message shows new balance

#### 3.2 Add Prepaid Credit
**Scenario**: Student pays in advance for future sessions

**Flow**:
1. User navigates to student profile
2. User clicks "Add Credit"
3. System displays form:
    - Amount paid
    - Number of hours (auto-calculated based on rate)
    - Payment date
    - Notes
4. User enters payment details
5. System shows preview of new balance
6. User confirms
7. System updates prepaid balance

#### 3.3 View Monthly Summary
**Scenario**: Teacher wants to see monthly earnings and outstanding payments

**Flow**:
1. User clicks "Reports" or "Monthly Summary"
2. System displays current month by default with:
    - Total hours taught
    - Total income (paid sessions)
    - Outstanding amount (unpaid sessions)
    - Student breakdown
3. User can change month/year
4. User can export or print summary

### 4. Time Tracking Flows

#### 4.1 Start Session Timer
**Scenario**: Teacher begins a tutoring session

**Flow**:
1. User opens app/dashboard
2. User selects student from dropdown/quick list
3. User clicks "Start Session"
4. Timer begins with visible countdown
5. System shows:
    - Student name
    - Running time
    - Pause/Stop buttons
    - Quick note field
6. Timer continues running (even if app minimized)

#### 4.2 End Session with Timer
**Scenario**: Teacher finishes session using timer

**Flow**:
1. User clicks "Stop" on running timer
2. System shows session summary:
    - Duration
    - Calculated cost
    - Pre-filled session form
3. User adds session notes
4. User selects payment status
5. User saves session
6. Option to start new session immediately

### 5. Analytics Dashboard Flows (Future Feature)

#### 5.1 View Dashboard
**Scenario**: Teacher wants to see business overview

**Flow**:
1. User navigates to Dashboard/Analytics
2. System displays widgets:
    - This month's hours
    - This month's income
    - Top 5 students by hours
    - Weekly hours trend chart
    - Upcoming scheduled sessions
3. User can click any widget for detailed view
4. User can change date range for analytics

#### 5.2 Generate Custom Report
**Scenario**: Teacher needs specific time period analysis

**Flow**:
1. User clicks "Custom Report"
2. User selects:
    - Date range
    - Students (all or specific)
    - Report type (summary/detailed)
3. System generates report
4. User can view, export, or share report

### Common UI Patterns Across All Flows:

1. **Empty States**: Helpful messages when no data exists yet
2. **Search/Filter**: Available on all list views
3. **Bulk Actions**: Select multiple items for batch operations
4. **Confirmation Dialogs**: For destructive actions (delete, etc.)
5. **Auto-save**: Draft sessions saved to prevent data loss
6. **Responsive Design**: All flows work on mobile/tablet
7. **Keyboard Shortcuts**: Quick actions for power users
8. **Undo/Redo**: For recent actions where applicable

These user flows provide a comprehensive foundation for building an intuitive tutoring management system that handles the complete lifecycle of student management, session tracking, and payment processing.