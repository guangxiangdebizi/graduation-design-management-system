  </div><!-- page-body -->
</div><!-- main-content -->
</div><!-- app-layout -->
<div id="toastContainer" class="toast-container"></div>
<div class="modal fade" id="confirmModal" tabindex="-1">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">
      <div class="modal-header"><h6 class="modal-title">确认操作</h6></div>
      <div class="modal-body"><p id="confirmMessage"></p></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">取消</button>
        <button type="button" class="btn btn-danger btn-sm" id="confirmBtn">确认</button>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
