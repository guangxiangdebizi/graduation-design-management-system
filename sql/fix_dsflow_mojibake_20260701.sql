USE graduation_design;
SET NAMES utf8mb4;

START TRANSACTION;

UPDATE users SET real_name='流程测试-一志愿全拒'
WHERE username='dsflow_rejected';
UPDATE users SET real_name='流程测试-顺利选题'
WHERE username='dsflow_selected';
UPDATE users SET real_name='流程测试-待安排答辩'
WHERE username='dsflow_final_ready';
UPDATE users SET real_name='流程测试-答辩未过'
WHERE username='dsflow_defense_fail';
UPDATE users SET real_name='流程测试-答辩已过'
WHERE username='dsflow_defense_pass';

UPDATE users
SET title='学生',
    class_name='数据科学与大数据技术1班',
    department='人工智能学部'
WHERE username IN (
    'dsflow_rejected',
    'dsflow_selected',
    'dsflow_final_ready',
    'dsflow_defense_fail',
    'dsflow_defense_pass'
);

UPDATE topics SET title='DS流程测试-第一志愿被拒绝课题A',
    description='用于测试学生第一轮三志愿全部未匹配：志愿1未被接收。'
WHERE id = (
    SELECT topic_id FROM selection_choices
    WHERE student_id=(SELECT id FROM users WHERE username='dsflow_rejected')
      AND round=1 AND choice_rank=1
    LIMIT 1
);

UPDATE topics SET title='DS流程测试-第二志愿被拒绝课题B',
    description='用于测试学生第一轮三志愿全部未匹配：志愿2未被接收。'
WHERE id = (
    SELECT topic_id FROM selection_choices
    WHERE student_id=(SELECT id FROM users WHERE username='dsflow_rejected')
      AND round=1 AND choice_rank=2
    LIMIT 1
);

UPDATE topics SET title='DS流程测试-第三志愿被拒绝课题C',
    description='用于测试学生第一轮三志愿全部未匹配：志愿3未被接收。'
WHERE id = (
    SELECT topic_id FROM selection_choices
    WHERE student_id=(SELECT id FROM users WHERE username='dsflow_rejected')
      AND round=1 AND choice_rank=3
    LIMIT 1
);

UPDATE topics SET title='DS流程测试-顺利匹配课题',
    description='用于测试第一轮第一志愿被指导教师接收并生成最终课题。'
WHERE id = (
    SELECT topic_id FROM topic_assignments
    WHERE student_id=(SELECT id FROM users WHERE username='dsflow_selected')
    LIMIT 1
);

UPDATE topics SET title='DS流程测试-终稿通过待答辩课题',
    description='用于测试学生终稿已通过，进入系主任待安排答辩列表。'
WHERE id = (
    SELECT topic_id FROM topic_assignments
    WHERE student_id=(SELECT id FROM users WHERE username='dsflow_final_ready')
    LIMIT 1
);

UPDATE topics SET title='DS流程测试-答辩未通过课题',
    description='用于测试已安排三名教师且均分低于60的答辩未通过状态。'
WHERE id = (
    SELECT topic_id FROM topic_assignments
    WHERE student_id=(SELECT id FROM users WHERE username='dsflow_defense_fail')
    LIMIT 1
);

UPDATE topics SET title='DS流程测试-答辩已通过课题',
    description='用于测试已安排三名教师且均分达到60的答辩通过状态。'
WHERE id = (
    SELECT topic_id FROM topic_assignments
    WHERE student_id=(SELECT id FROM users WHERE username='dsflow_defense_pass')
    LIMIT 1
);

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-待安排答辩-开题报告',
    d.content='开题报告测试内容。',
    d.feedback='开题通过。'
WHERE u.username='dsflow_final_ready' AND d.doc_type='proposal';

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-待安排答辩-中期检查',
    d.content='中期检查测试内容。',
    d.feedback='中期通过。'
WHERE u.username='dsflow_final_ready' AND d.doc_type='midterm';

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-待安排答辩-终稿/结题材料',
    d.content='终稿测试内容，已由指导教师审核通过。',
    d.feedback='指导教师评价：终稿通过，可进入评阅和答辩安排。',
    d.self_review='指导教师评价：终稿通过，可进入评阅和答辩安排。',
    d.advisor_comment='指导教师评价：终稿通过，可进入评阅和答辩安排。',
    d.reviewer_comment='评阅教师意见：论文结构完整，数据处理过程较清楚。',
    d.peer_review='评阅教师意见：论文结构完整，数据处理过程较清楚。'
WHERE u.username='dsflow_final_ready' AND d.doc_type='final';

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-答辩未过-开题报告',
    d.content='开题报告测试内容。',
    d.feedback='开题通过。'
WHERE u.username='dsflow_defense_fail' AND d.doc_type='proposal';

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-答辩未过-中期检查',
    d.content='中期检查测试内容。',
    d.feedback='中期通过。'
WHERE u.username='dsflow_defense_fail' AND d.doc_type='midterm';

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-答辩未过-终稿/结题材料',
    d.content='终稿测试内容，已由指导教师审核通过。',
    d.feedback='指导教师评价：终稿基本通过，但系统完成度仍需提升。',
    d.self_review='指导教师评价：终稿基本通过，但系统完成度仍需提升。',
    d.advisor_comment='指导教师评价：终稿基本通过，但系统完成度仍需提升。',
    d.reviewer_comment='评阅教师意见：论文结构基本完整，但实验和分析偏弱。',
    d.peer_review='评阅教师意见：论文结构基本完整，但实验和分析偏弱。'
WHERE u.username='dsflow_defense_fail' AND d.doc_type='final';

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-答辩已过-开题报告',
    d.content='开题报告测试内容。',
    d.feedback='开题通过。'
WHERE u.username='dsflow_defense_pass' AND d.doc_type='proposal';

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-答辩已过-中期检查',
    d.content='中期检查测试内容。',
    d.feedback='中期通过。'
WHERE u.username='dsflow_defense_pass' AND d.doc_type='midterm';

UPDATE documents d
JOIN users u ON d.student_id=u.id
SET d.title='DS流程测试-答辩已过-终稿/结题材料',
    d.content='终稿测试内容，已由指导教师审核通过。',
    d.feedback='指导教师评价：终稿质量较好，系统实现完整。',
    d.self_review='指导教师评价：终稿质量较好，系统实现完整。',
    d.advisor_comment='指导教师评价：终稿质量较好，系统实现完整。',
    d.reviewer_comment='评阅教师意见：论文规范，工作量充足，技术路线合理。',
    d.peer_review='评阅教师意见：论文规范，工作量充足，技术路线合理。'
WHERE u.username='dsflow_defense_pass' AND d.doc_type='final';

UPDATE topic_assignments a
JOIN users u ON a.student_id=u.id
SET a.confirm_comment=CASE u.username
    WHEN 'dsflow_selected' THEN '测试数据：第一轮第一志愿由指导教师接收。'
    WHEN 'dsflow_final_ready' THEN '测试数据：第一轮志愿匹配，已进入终稿通过待答辩。'
    WHEN 'dsflow_defense_fail' THEN '测试数据：第一轮志愿匹配，后续答辩未通过。'
    WHEN 'dsflow_defense_pass' THEN '测试数据：第一轮志愿匹配，后续答辩通过。'
    ELSE a.confirm_comment
END
WHERE u.username IN ('dsflow_selected','dsflow_final_ready','dsflow_defense_fail','dsflow_defense_pass');

UPDATE defense_schedules ds
JOIN users u ON ds.student_id=u.id
SET ds.comment=CASE u.username
    WHEN 'dsflow_defense_fail' THEN '测试数据：三名教师均分低于60，答辩未通过。'
    WHEN 'dsflow_defense_pass' THEN '测试数据：三名教师均分达到60及以上，答辩通过。'
    ELSE ds.comment
END
WHERE u.username IN ('dsflow_defense_fail','dsflow_defense_pass');

UPDATE defense_scores s
JOIN defense_schedules ds ON s.schedule_id=ds.id
JOIN users u ON ds.student_id=u.id
JOIN users t ON s.teacher_id=t.id
SET s.comment=CASE
    WHEN u.username='dsflow_defense_fail' AND t.username='teacher_ds' THEN '陈述结构不完整，核心实现解释不足。'
    WHEN u.username='dsflow_defense_fail' AND t.username='test1' THEN '数据分析过程较弱，答问不充分。'
    WHEN u.username='dsflow_defense_fail' AND t.username='director_ds' THEN '系统完成度不足，未达到通过要求。'
    WHEN u.username='dsflow_defense_pass' AND t.username='teacher_ds' THEN '系统实现完整，答辩表达清楚。'
    WHEN u.username='dsflow_defense_pass' AND t.username='test1' THEN '数据处理链路清晰，演示效果良好。'
    WHEN u.username='dsflow_defense_pass' AND t.username='director_ds' THEN '创新性和完成度较好，通过答辩。'
    ELSE s.comment
END
WHERE u.username IN ('dsflow_defense_fail','dsflow_defense_pass');

COMMIT;
