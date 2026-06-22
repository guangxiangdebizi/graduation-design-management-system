package util;

import java.io.File;
import java.io.IOException;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import javax.servlet.http.Part;

public class FileUploadUtil {
    private static final long DEFAULT_MAX_SIZE = 10L * 1024 * 1024;

    public static String saveFile(Part filePart, String uploadDir, String prefix) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        long maxSize = SystemConfigUtil.getLong("upload.max_size_bytes", DEFAULT_MAX_SIZE);
        if (filePart.getSize() > maxSize) {
            throw new IOException("文件大小超过" + (maxSize / 1024 / 1024) + "MB限制");
        }
        String original = getFileName(filePart);
        if (original == null || original.trim().isEmpty()) {
            return null;
        }
        String ext = getExtension(original);
        validateExtension(ext);
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        String savedName = prefix + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + ext;
        filePart.write(uploadDir + File.separator + savedName);
        return savedName;
    }

    public static String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) {
            return null;
        }
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                String name = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                int slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
                if (slash >= 0) {
                    name = name.substring(slash + 1);
                }
                return name;
            }
        }
        return null;
    }

    private static String getExtension(String filename) {
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) {
            return "";
        }
        return filename.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    private static void validateExtension(String ext) throws IOException {
        Set<String> allowedExt = SystemConfigUtil.getCsvSet(
            "upload.allowed_extensions", "pdf,doc,docx,zip,rar");
        Set<String> blockedExt = SystemConfigUtil.getCsvSet(
            "upload.blocked_extensions", "exe,jsp,jspx,bat,cmd,sh");
        if (ext.isEmpty()) {
            throw new IOException("文件缺少扩展名");
        }
        if (blockedExt.contains(ext)) {
            throw new IOException("不允许上传该类型文件: ." + ext);
        }
        if (!allowedExt.contains(ext)) {
            throw new IOException("仅允许上传 " + String.join("/", allowedExt) + " 文件");
        }
    }
}
