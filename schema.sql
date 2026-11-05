CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE IF NOT EXISTS users (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), full_name VARCHAR(160) NOT NULL,
 email VARCHAR(190) NOT NULL UNIQUE, phone VARCHAR(40), password_hash TEXT NOT NULL,
 role VARCHAR(20) NOT NULL CHECK (role IN ('admin','tutor','student')),
 active BOOLEAN NOT NULL DEFAULT TRUE, must_change_password BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS students (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
 grade VARCHAR(30) NOT NULL DEFAULT 'Grade 12', school_name VARCHAR(180), student_number VARCHAR(60) UNIQUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS tutors (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
 bio TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS subjects (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name VARCHAR(120) NOT NULL UNIQUE,
 code VARCHAR(30), description TEXT, monthly_fee NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK(monthly_fee >= 0),
 tutor_id UUID REFERENCES tutors(id) ON DELETE SET NULL, active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS topics (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
 name VARCHAR(180) NOT NULL, description TEXT, sort_order INT NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS enrolments (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE RESTRICT,
 status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','active','suspended','completed')),
 starts_on DATE, ends_on DATE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 UNIQUE(student_id, subject_id)
);
CREATE TABLE IF NOT EXISTS payments (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
 amount NUMERIC(12,2) NOT NULL CHECK(amount > 0), currency VARCHAR(3) NOT NULL DEFAULT 'ZMW',
 method VARCHAR(40) NOT NULL, reference VARCHAR(120), notes TEXT,
 received_by UUID REFERENCES users(id) ON DELETE SET NULL, paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS payment_allocations (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
 enrolment_id UUID NOT NULL REFERENCES enrolments(id) ON DELETE RESTRICT,
 amount NUMERIC(12,2) NOT NULL CHECK(amount > 0)
);
CREATE TABLE IF NOT EXISTS sessions (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
 tutor_id UUID NOT NULL REFERENCES tutors(id) ON DELETE RESTRICT,
 title VARCHAR(180) NOT NULL, topic VARCHAR(180), description TEXT,
 starts_at TIMESTAMPTZ NOT NULL, ends_at TIMESTAMPTZ NOT NULL,
 meeting_url TEXT, status VARCHAR(20) NOT NULL DEFAULT 'scheduled' CHECK(status IN ('scheduled','completed','cancelled')),
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), CHECK(ends_at > starts_at)
);
CREATE TABLE IF NOT EXISTS attendance (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 status VARCHAR(20) NOT NULL CHECK(status IN ('present','absent','late','excused')),
 marked_by UUID REFERENCES users(id) ON DELETE SET NULL, marked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 UNIQUE(session_id,student_id)
);
CREATE TABLE IF NOT EXISTS materials (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
 topic_id UUID REFERENCES topics(id) ON DELETE SET NULL, uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
 title VARCHAR(180) NOT NULL, description TEXT, file_name TEXT NOT NULL, file_path TEXT NOT NULL,
 mime_type VARCHAR(120), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS recordings (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
 session_id UUID REFERENCES sessions(id) ON DELETE SET NULL, uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
 title VARCHAR(180) NOT NULL, topic VARCHAR(180), video_url TEXT NOT NULL, duration_minutes INT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS assignments (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
 tutor_id UUID NOT NULL REFERENCES tutors(id) ON DELETE RESTRICT, title VARCHAR(180) NOT NULL,
 instructions TEXT, due_at TIMESTAMPTZ, max_score NUMERIC(8,2) NOT NULL DEFAULT 100,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS submissions (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE, answer_text TEXT, file_path TEXT,
 score NUMERIC(8,2), feedback TEXT, submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), marked_at TIMESTAMPTZ,
 UNIQUE(assignment_id,student_id)
);
CREATE TABLE IF NOT EXISTS assessments (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
 tutor_id UUID NOT NULL REFERENCES tutors(id) ON DELETE RESTRICT, title VARCHAR(180) NOT NULL,
 instructions TEXT, total_marks NUMERIC(8,2) NOT NULL DEFAULT 100, assessment_date TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS results (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE, marks_obtained NUMERIC(8,2) NOT NULL,
 feedback TEXT, recorded_by UUID REFERENCES users(id) ON DELETE SET NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 UNIQUE(assessment_id,student_id)
);
CREATE TABLE IF NOT EXISTS notifications (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 title VARCHAR(180) NOT NULL, message TEXT NOT NULL, read_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_enrolments_student ON enrolments(student_id,status);
CREATE INDEX IF NOT EXISTS idx_sessions_starts ON sessions(starts_at);
CREATE INDEX IF NOT EXISTS idx_materials_subject ON materials(subject_id);
CREATE INDEX IF NOT EXISTS idx_results_student ON results(student_id);
