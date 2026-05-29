<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
  request.setAttribute("pageTitle", "数据统计");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-3">
  <div></div>
  <a href="../admin/export.action" class="btn btn-success btn-sm">导出成绩 Excel</a>
</div>

<div class="row g-3">
  <div class="col-md-4">
    <div class="content-card">
      <h6>选题情况</h6>
      <div id="chartSelection" style="height:280px;position:relative">
        <div id="chartSelectionLoading" class="text-center py-5 text-muted">加载中...</div>
        <div id="chartSelectionError" class="text-center py-5 text-danger d-none">图表加载失败</div>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="content-card">
      <h6>文档通过数（已评阅）</h6>
      <div id="chartDocPass" style="height:280px;position:relative">
        <div id="chartDocPassLoading" class="text-center py-5 text-muted">加载中...</div>
        <div id="chartDocPassError" class="text-center py-5 text-danger d-none">图表加载失败</div>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="content-card">
      <h6>成绩分布</h6>
      <div id="chartScores" style="height:280px;position:relative">
        <div id="chartScoresLoading" class="text-center py-5 text-muted">加载中...</div>
        <div id="chartScoresError" class="text-center py-5 text-danger d-none">图表加载失败</div>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
  function hideLoading(id) {
    var el = document.getElementById(id + 'Loading');
    if (el) el.style.display = 'none';
  }
  function showError(id) {
    hideLoading(id);
    var el = document.getElementById(id + 'Error');
    if (el) el.classList.remove('d-none');
  }
  try {
    fetch('../admin/stats.action').then(function(r) {
      if (!r.ok) throw new Error('fetch failed');
      return r.json();
    }).then(function(data) {
      if (typeof echarts === 'undefined') throw new Error('echarts missing');
      var pieOpt = function(mapData) {
        return { tooltip: { trigger: 'item' }, series: [{ type: 'pie', radius: '65%', data: mapData }] };
      };
      var selData = [];
      for (var k in data.selection) { selData.push({ name: k, value: data.selection[k] }); }
      hideLoading('chartSelection');
      echarts.init(document.getElementById('chartSelection')).setOption(pieOpt(selData));

      var docData = [];
      for (var k2 in data.docPass) { docData.push({ name: k2, value: data.docPass[k2] }); }
      hideLoading('chartDocPass');
      echarts.init(document.getElementById('chartDocPass')).setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: docData.map(function(d){ return d.name; }) },
        yAxis: { type: 'value', minInterval: 1 },
        series: [{ type: 'bar', data: docData.map(function(d){ return d.value; }), itemStyle: { color: '#3b82f6' } }]
      });

      hideLoading('chartScores');
      echarts.init(document.getElementById('chartScores')).setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: data.scores.labels },
        yAxis: { type: 'value', minInterval: 1 },
        series: [{ type: 'bar', data: data.scores.values, itemStyle: { color: '#10b981' } }]
      });
    }).catch(function() {
      showError('chartSelection');
      showError('chartDocPass');
      showError('chartScores');
    });
  } catch (e) {
    showError('chartSelection');
    showError('chartDocPass');
    showError('chartScores');
  }
})();
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
