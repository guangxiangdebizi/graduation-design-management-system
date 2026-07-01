-- 修复旧 DS流程测试课题的审核意见乱码。
-- 原因：早先通过 PowerShell 管道导入中文 SQL，客户端编码被打成问号。

USE graduation_design;
SET NAMES utf8mb4;

UPDATE topics
SET review_comment='测试数据：本专业审核通过。'
WHERE title LIKE 'DS流程测试-%';

SELECT id,title,review_comment
FROM topics
WHERE title LIKE 'DS流程测试-%'
ORDER BY id;
