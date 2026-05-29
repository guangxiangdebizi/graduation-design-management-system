function showToast(message, isError) {
  var container = document.getElementById('toastContainer');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toastContainer';
    container.className = 'toast-container';
    document.body.appendChild(container);
  }
  var toast = document.createElement('div');
  toast.className = 'toast-msg' + (isError ? ' error' : '');
  toast.textContent = message;
  container.appendChild(toast);
  setTimeout(function() {
    toast.style.opacity = '0';
    toast.style.transition = 'opacity 0.3s';
    setTimeout(function() { toast.remove(); }, 300);
  }, 3000);
}

function togglePassword(inputId, btn) {
  var input = document.getElementById(inputId);
  if (input.type === 'password') {
    input.type = 'text';
    btn.textContent = '隐藏';
  } else {
    input.type = 'password';
    btn.textContent = '显示';
  }
}

function confirmAction(formId, message) {
  var modal = document.getElementById('confirmModal');
  if (!modal) return true;
  document.getElementById('confirmMessage').textContent = message;
  document.getElementById('confirmBtn').onclick = function() {
    document.getElementById(formId).submit();
  };
  new bootstrap.Modal(modal).show();
  return false;
}

function validateScore(input) {
  var val = parseFloat(input.value);
  if (isNaN(val) || val < 0 || val > 100) {
    input.setCustomValidity('分数必须在 0-100 之间');
  } else {
    input.setCustomValidity('');
  }
}

function injectCsrfToken() {
  var meta = document.querySelector('meta[name="csrf-token"]');
  if (!meta) return;
  var token = meta.getAttribute('content');
  if (!token) return;
  document.querySelectorAll('form[method="post"], form[method="POST"]').forEach(function(form) {
    if (form.querySelector('input[name="_csrf"]')) return;
    var input = document.createElement('input');
    input.type = 'hidden';
    input.name = '_csrf';
    input.value = token;
    form.appendChild(input);
  });
}

function initPageMessages() {
  var params = new URLSearchParams(window.location.search);
  var msg = params.get('msg');
  var path = window.location.pathname || '';
  var errorKeys = ['error', 'quota_full', 'import_empty', 'import_error', 'csrf_error',
    'upload_invalid', 'rejected', 'already_applied', 'no_topic', 'exists'];
  var messages = {
    'add_ok': '添加成功',
    'edit_ok': '修改成功',
    'delete_ok': '删除成功',
    'apply_ok': '选题申请已提交',
    'already_applied': '您已有待审或已通过的选题',
    'submit_ok': '文档提交成功',
    'no_topic': '请先完成选题后再提交文档',
    'approved': '已批准选题申请',
    'rejected': path.indexOf('documents') >= 0 ? '文档已退回' : '已驳回选题申请',
    'reviewed': '文档审核完成',
    'send_ok': '消息发送成功',
    'exists': '该学生已有答辩安排',
    'quota_full': '课题名额已满，无法批准',
    'import_empty': '请选择要导入的 Excel 文件',
    'import_error': '导入失败，请检查文件格式',
    'csrf_error': '安全验证失败，请刷新页面后重试',
    'upload_invalid': '文件格式或大小不符合要求',
    'locked': '登录失败次数过多，请稍后再试',
    'error': '操作失败，请重试'
  };

  if (msg === 'import_ok') {
    var success = params.get('success') || '0';
    var skipped = params.get('skipped') || '0';
    showToast('导入完成：成功 ' + success + ' 条，跳过 ' + skipped + ' 条', false);
    return;
  }

  if (msg && messages[msg]) {
    showToast(messages[msg], errorKeys.indexOf(msg) >= 0);
  }
  if (params.get('error') === '1') {
    showToast('用户名或密码错误', true);
  }
  if (params.get('error') === 'locked') {
    showToast(messages['locked'], true);
  }
}

document.addEventListener('DOMContentLoaded', function() {
  injectCsrfToken();
  initPageMessages();
});
