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
    if ((form.enctype || '').toLowerCase() === 'multipart/form-data') {
      var action = form.getAttribute('action') || window.location.href;
      var url = new URL(action, window.location.href);
      if (!url.searchParams.has('_csrf')) {
        url.searchParams.set('_csrf', token);
        form.setAttribute('action', url.pathname + url.search + url.hash);
      }
    }
  });
}

function initPageMessages() {
  var params = new URLSearchParams(window.location.search);
  var msg = params.get('msg');
  var path = window.location.pathname || '';
  var errorKeys = ['error', 'quota_full', 'import_empty', 'import_error', 'csrf_error',
    'upload_invalid', 'rejected', 'already_applied', 'no_topic', 'exists',
    'delete_failed', 'delete_self', 'forbidden', 'student_has_topic',
    'stage_locked', 'document_locked', 'invalid_score', 'invalid_quota',
    'edit_self_role', 'last_admin', 'defense_ineligible',
    'topic_submit_closed', 'selection_closed', 'assign_closed', 'upload_closed',
    'has_assignment', 'choice_count_invalid', 'duplicate_choice',
    'topic_invalid', 'intent_full', 'already_submitted',
    'topic_assigned', 'choice_invalid', 'review_closed'];
  var messages = {
    'add_ok': '添加成功',
    'edit_ok': '修改成功',
    'delete_ok': '删除成功',
    'apply_ok': '选题申请已提交',
    'choice_ok': '志愿已提交，请等待对应课题指导教师审批',
    'choice_confirm_ok': '已确认志愿并生成最终题目分配',
    'accept_ok': '已接收该学生志愿，并生成最终题目分配',
    'reject_ok': '已将该志愿标记为未接收',
    'already_applied': '您已有待审或已通过的选题',
    'submit_ok': '文档提交成功',
    'no_topic': '请先完成选题后再提交文档',
    'approved': '已确认选题申请',
    'suggest_ok': '已保存指导教师建议',
    'rejected': path.indexOf('documents') >= 0 ? '文档已退回' : '已驳回选题申请',
    'reviewed': '文档审核完成',
    'send_ok': '消息发送成功',
    'switch_ok': '系统开关已保存',
    'assign_ok': '强制分配选题成功',
    'exists': '该学生已有答辩安排',
    'delete_failed': '删除失败：该数据可能已被选题、文档、消息或日志引用',
    'delete_self': '不能删除当前登录账号',
    'forbidden': '无权执行该操作',
    'quota_full': '课题名额已满，无法批准',
    'student_has_topic': '该学生已有其他已通过课题，不能重复批准',
    'stage_locked': '请先完成并通过上一阶段文档',
    'document_locked': '该文档正在审核或已通过，不能重复覆盖',
    'invalid_score': '分数必须填写且在 0-100 之间',
    'invalid_quota': '课题名额不能小于当前已选人数',
    'edit_self_role': '不能停用当前账号或修改当前管理员角色',
    'last_admin': '系统必须至少保留一个启用的管理员账号',
    'defense_ineligible': '该学生尚未完成终稿审核，或答辩数据不合法',
    'import_empty': '请选择要导入的 Excel 文件',
    'import_error': '导入失败，请检查文件格式',
    'csrf_error': '安全验证失败，请刷新页面后重试',
    'upload_invalid': '文件格式或大小不符合要求',
    'topic_submit_closed': '教师出题入口已关闭',
    'selection_closed': '学生选题入口已关闭',
    'assign_closed': '管理员尚未开启强制分配阶段',
    'upload_closed': '当前阶段上传入口已关闭',
    'has_assignment': '您已经有最终确认题目，不能重复填报',
    'choice_count_invalid': '每轮至少选择 1 个志愿，最多选择 3 个志愿',
    'duplicate_choice': '三个志愿不能选择同一个题目',
    'topic_invalid': '只能选择本专业、未分配、已审核通过的题目',
    'intent_full': '题目的本轮意向人数已满，请重新选择',
    'already_submitted': '您本轮已经提交过志愿，请等待指导教师审批',
    'topic_assigned': '该题目已被最终分配，不能重复确认',
    'choice_invalid': '该志愿当前不可审批，可能已失效或题目未开放',
    'review_closed': '当前轮次未开放教师志愿审批',
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

function initAiAssistant() {
  var form = document.getElementById('aiForm');
  if (!form) return;
  var input = document.getElementById('aiMessage');
  var chatBox = document.getElementById('aiChatBox');
  var sendBtn = document.getElementById('aiSendBtn');
  var clearBtn = document.getElementById('aiClearBtn');
  var action = form.getAttribute('data-action') || (window.GDMS_AI_CONFIG && window.GDMS_AI_CONFIG.action) || 'ai.action';
  var csrfMeta = document.querySelector('meta[name="csrf-token"]');
  var csrf = csrfMeta ? csrfMeta.getAttribute('content') : '';
  var mermaidSeq = 0;

  if (window.mermaid) {
    window.mermaid.initialize({
      startOnLoad: false,
      securityLevel: 'strict',
      theme: 'default'
    });
  }

  function appendMessage(role, text) {
    var wrap = document.createElement('div');
    wrap.className = 'ai-msg ' + (role === 'user' ? 'ai-msg-user' : 'ai-msg-assistant');
    var avatar = document.createElement('div');
    avatar.className = 'ai-msg-role';
    avatar.textContent = role === 'user' ? '我' : 'AI';
    var body = document.createElement('div');
    body.className = 'ai-msg-body';
    setPlainMessage(body, text);
    wrap.appendChild(avatar);
    wrap.appendChild(body);
    chatBox.appendChild(wrap);
    chatBox.scrollTop = chatBox.scrollHeight;
    return wrap;
  }

  function setPlainMessage(body, text) {
    body.textContent = text || '';
    body.dataset.rawText = text || '';
  }

  function appendPlainText(container, text) {
    if (!text) return;
    container.appendChild(document.createTextNode(text));
  }

  function renderAssistantMessage(body, text) {
    body.dataset.rawText = text || '';
    body.textContent = '';

    var source = text || '';
    var blockRegex = /```mermaid\s*([\s\S]*?)```/gi;
    var lastIndex = 0;
    var match;
    var hasMermaid = false;

    while ((match = blockRegex.exec(source)) !== null) {
      appendPlainText(body, source.substring(lastIndex, match.index));
      appendMermaidBlock(body, match[1]);
      hasMermaid = true;
      lastIndex = blockRegex.lastIndex;
    }
    appendPlainText(body, source.substring(lastIndex));

    if (!hasMermaid) {
      setPlainMessage(body, source);
    }
  }

  function appendMermaidBlock(container, code) {
    var normalized = (code || '').trim();
    var block = document.createElement('div');
    block.className = 'ai-mermaid-block';
    var title = document.createElement('div');
    title.className = 'ai-mermaid-title';
    title.textContent = 'Mermaid 图示';
    var canvas = document.createElement('div');
    canvas.className = 'ai-mermaid-canvas';
    var fallback = document.createElement('pre');
    fallback.className = 'ai-mermaid-fallback';
    fallback.textContent = normalized;
    block.appendChild(title);
    block.appendChild(canvas);
    container.appendChild(block);

    if (!normalized) {
      canvas.textContent = 'Mermaid 内容为空。';
      return;
    }
    if (!window.mermaid) {
      block.appendChild(fallback);
      canvas.textContent = 'Mermaid 脚本未加载，已保留源码。';
      return;
    }

    var id = 'ai-mermaid-' + Date.now() + '-' + (++mermaidSeq);
    window.mermaid.render(id, normalized).then(function(result) {
      canvas.innerHTML = result.svg;
      if (result.bindFunctions) {
        result.bindFunctions(canvas);
      }
      chatBox.scrollTop = chatBox.scrollHeight;
    }).catch(function(err) {
      canvas.textContent = 'Mermaid 渲染失败，已保留源码。';
      block.appendChild(fallback);
      if (window.console && console.warn) {
        console.warn('Mermaid render failed:', err);
      }
    });
  }

  function postJson(data) {
    var params = new URLSearchParams(data);
    if (csrf) params.set('_csrf', csrf);
    return fetch(action, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
        'X-CSRF-Token': csrf
      },
      body: params.toString()
    }).then(function(r) {
      var contentType = r.headers.get('content-type') || '';
      if (contentType.indexOf('application/json') < 0) {
        return r.text().then(function(text) {
          throw new Error(explainNonJsonResponse(r.status, text));
        });
      }
      return r.json().then(function(json) {
        if (!r.ok || json.ok === false) throw new Error((json && json.message) || '请求失败');
        return json;
      });
    });
  }

  function explainNonJsonResponse(status, text) {
    if ((text || '').indexOf('<!DOCTYPE') >= 0 || (text || '').indexOf('<html') >= 0) {
      if (status === 404) return 'AI 接口未加载，请重启 Tomcat 后再试。';
      if (status === 500) return 'AI 后端发生 500 错误，请查看 Tomcat 控制台日志。';
      return '服务器返回了 HTML 页面，通常是登录过期、CSRF 失败或 Tomcat 未重启。';
    }
    return '服务器返回格式异常，状态码：' + status;
  }

  function postAiStream(message, onDelta) {
    var params = new URLSearchParams({ message: message });
    if (csrf) params.set('_csrf', csrf);
    return fetch(action, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
        'X-CSRF-Token': csrf
      },
      body: params.toString()
    }).then(function(r) {
      var contentType = r.headers.get('content-type') || '';
      if (contentType.indexOf('text/event-stream') < 0) {
        if (contentType.indexOf('application/json') >= 0) {
          return r.json().then(function(json) {
            throw new Error((json && json.message) || 'AI 请求失败');
          });
        }
        return r.text().then(function(text) {
          throw new Error(explainNonJsonResponse(r.status, text));
        });
      }
      if (!r.ok) {
        throw new Error('AI 请求失败，状态码：' + r.status);
      }
      return readEventStream(r.body, onDelta);
    });
  }

  function readEventStream(body, onDelta) {
    if (!body || !body.getReader) {
      throw new Error('当前浏览器不支持流式读取。');
    }
    var reader = body.getReader();
    var decoder = new TextDecoder('utf-8');
    var buffer = '';

    function pump() {
      return reader.read().then(function(result) {
        if (result.done) {
          if (buffer) handleSseBlock(buffer, onDelta);
          return;
        }
        buffer += decoder.decode(result.value, { stream: true });
        var parts = buffer.split(/\n\n/);
        buffer = parts.pop();
        parts.forEach(function(part) {
          handleSseBlock(part, onDelta);
        });
        return pump();
      });
    }
    return pump();
  }

  function handleSseBlock(block, onDelta) {
    if (!block) return;
    var lines = block.split(/\r?\n/);
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.indexOf('data:') !== 0) continue;
      var raw = line.substring(5).trim();
      if (!raw) continue;
      var json = JSON.parse(raw);
      if (json.event === 'delta') {
        onDelta(json.data || '');
      } else if (json.event === 'error') {
        throw new Error(json.data || 'AI 服务调用失败。');
      }
    }
  }

  form.addEventListener('submit', function(e) {
    e.preventDefault();
    var text = (input.value || '').trim();
    if (!text) {
      showToast('请输入要咨询的问题', true);
      return;
    }
    appendMessage('user', text);
    input.value = '';
    sendBtn.disabled = true;
    sendBtn.textContent = '思考中...';
    var aiMessage = appendMessage('assistant', '');
    var aiBody = aiMessage.querySelector('.ai-msg-body');
    var received = false;
    var fullReply = '';
    setPlainMessage(aiBody, '正在连接 AI...');
    postAiStream(text, function(delta) {
      if (!received) {
        setPlainMessage(aiBody, '');
        received = true;
      }
      fullReply += delta;
      setPlainMessage(aiBody, fullReply);
      chatBox.scrollTop = chatBox.scrollHeight;
    }).then(function() {
      if (!received) {
        setPlainMessage(aiBody, 'AI 没有返回内容。');
      } else {
        renderAssistantMessage(aiBody, fullReply);
      }
    }).catch(function(err) {
      setPlainMessage(aiBody, err.message || 'AI 服务调用失败。');
    }).finally(function() {
      sendBtn.disabled = false;
      sendBtn.textContent = '发送';
      input.focus();
    });
  });

  if (clearBtn) {
    clearBtn.addEventListener('click', function() {
      postJson({ action: 'clear' }).then(function(json) {
        chatBox.innerHTML = '';
        appendMessage('assistant', json.message || '已清空当前用户的 AI 会话。');
      }).catch(function(err) {
        showToast(err.message || '清空失败', true);
      });
    });
  }

  document.querySelectorAll('.ai-prompt').forEach(function(btn) {
    btn.addEventListener('click', function() {
      input.value = btn.getAttribute('data-prompt') || btn.textContent;
      input.focus();
    });
  });
}

document.addEventListener('DOMContentLoaded', function() {
  injectCsrfToken();
  initPageMessages();
  initAiAssistant();
});
