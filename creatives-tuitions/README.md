# Creatives Tuitions

Grade 12 online tuition and learning platform for Zambia.

## Stack
- React + Vite frontend
- Node.js + Express backend
- PostgreSQL database
- JWT authentication with role-based access

## Included modules
- Administrator, tutor and student accounts
- Subject catalogue, tutor assignment and subject pricing
- Student enrolment and payment recording
- Live lesson scheduling with external meeting links
- Recorded lessons and learning materials
- Assignments, student submissions, assessments and results
- Attendance and student progress summaries

## Requirements
- Node.js 20+
- PostgreSQL 14+

## Setup

### 1. Database
Create a PostgreSQL database named `creatives_tuitions`, then run:

```bash
psql -U postgres -d creatives_tuitions -f backend/sql/schema.sql
```

Alternatively, open `backend/sql/schema.sql` in pgAdmin and execute it against the database.

### 2. Backend

```bash
cd backend
npm install
copy .env.example .env
```

Edit `.env` and set your PostgreSQL username/password and a long random JWT secret. Then:

```bash
npm run create-admin
npm run dev
```

Backend: http://localhost:5000
Health check: http://localhost:5000/api/health

Default admin is created from `ADMIN_NAME`, `ADMIN_EMAIL`, and `ADMIN_PASSWORD` in `.env`. Change the password after first login.

### 3. Frontend
Open another terminal:

```bash
cd frontend
npm install
copy .env.example .env
npm run dev
```

Open the Vite URL shown in the terminal (normally http://localhost:5173).

## Important first-run notes
- The administrator creates tutor and student accounts from the Users page.
- Create subjects, assign tutors and set each subject's fee.
- Record a student's payment, then enrol the student in the relevant subject. Access is limited to active enrolments.
- Live sessions use Google Meet, Zoom or another external meeting URL; this app does not host video calls.
- Uploads are stored locally in `backend/uploads` for development. For public deployment, configure durable object storage and HTTPS before real student use.
- Email delivery is not enabled by default. The app displays generated temporary passwords to the administrator during local setup; configure a transactional email provider before production use.
- This is a complete functional MVP codebase, but it must be tested, security-reviewed, configured for production, and deployed before handling real student data or payments.

## Production checklist
- Use a managed PostgreSQL database with backups.
- Set a strong unique `JWT_SECRET` and `NODE_ENV=production`.
- Configure HTTPS, CORS origins, rate limiting and secure hosting.
- Configure private cloud file/video storage and email delivery.
- Add a payment gateway only after merchant onboarding and payment reconciliation testing.
- Review Zambia's applicable data protection requirements and publish privacy/retention terms.
