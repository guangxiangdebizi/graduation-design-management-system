USE graduation_design;

-- Run once on databases created before the 2026-06-19 business-logic fixes.
ALTER TABLE users
    ADD COLUMN college VARCHAR(50) DEFAULT NULL AFTER student_no,
    ADD COLUMN major VARCHAR(50) DEFAULT NULL AFTER college,
    ADD COLUMN class_name VARCHAR(50) DEFAULT NULL AFTER major,
    ADD UNIQUE KEY uk_users_student_no (student_no);

ALTER TABLE topics
    ADD COLUMN college VARCHAR(50) DEFAULT NULL AFTER teacher_id;

UPDATE users
SET college = CASE department
    WHEN '计算机学院' THEN 'cs'
    WHEN '软件学院' THEN 'sw'
    WHEN '电气学院' THEN 'ee'
    ELSE college
END
WHERE college IS NULL;

UPDATE topics t
JOIN users u ON t.teacher_id = u.id
SET t.college = u.college
WHERE t.college IS NULL;

UPDATE topics
SET status = 'closed'
WHERE selected_count >= max_students;

ALTER TABLE topic_selections
    ADD COLUMN active_guard TINYINT GENERATED ALWAYS AS (
        CASE WHEN status IN ('pending','approved') THEN 1 ELSE NULL END
    ) STORED,
    ADD UNIQUE KEY uk_student_active_selection (student_id, active_guard);

ALTER TABLE documents
    ADD UNIQUE KEY uk_student_doc_type (student_id, doc_type),
    ADD CONSTRAINT chk_document_score
        CHECK (score IS NULL OR (score >= 0 AND score <= 100));

ALTER TABLE document_versions
    ADD UNIQUE KEY uk_document_version (document_id, version_no);

ALTER TABLE defense_schedules
    DROP INDEX student_id,
    ADD UNIQUE KEY uk_defense_student (student_id),
    ADD CONSTRAINT chk_defense_score
        CHECK (score IS NULL OR (score >= 0 AND score <= 100));
