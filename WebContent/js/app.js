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

function initPageMessages() {
  var params = new URLSearchParams(window.location.search);
  var msg = params.get('msg');
  if (!msg) return;
  var messages = {
    'add_ok': '添加成功',
    'edit_ok': '修改成功',
    'delete_ok': '删除成功',
    'apply_ok': '选题申请已提交',
    'already_applied': '您已有待审或已通过的选题',
    'submit_ok': '文档提交成功',
    'no_topic': '请先完成选题后再提交文档',
    'approved': '已批准选题申请',
    'rejected': '已驳回选题申请',
    'reviewed': '文档审核完成',
    'error': '操作失败，请重试'
  };
  if (messages[msg]) {
    showToast(messages[msg], msg === 'error' || msg === 'already_applied' || msg === 'no_topic');
  }
  if (params.get('error') === '1') {
    showToast('用户名或密码错误', true);
  }
}

document.addEventListener('DOMContentLoaded', initPageMessages);
