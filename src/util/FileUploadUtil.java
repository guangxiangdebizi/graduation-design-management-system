package util;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import javax.servlet.http.Part;

public class FileUploadUtil {
    private static final long MAX_SIZE = 10L * 1024 * 1024;
    private static final Set<String> ALLOWED_EXT = new HashSet<String>(
        Arrays.asList("pdf", "doc", "docx", "zip", "rar"));
    private static final Set<String> BLOCKED_EXT = new HashSet<String>(
        Arrays.asList("exe", "jsp", "jspx", "bat", "cmd", "sh"));

    public static String saveFile(Part filePart, String uploadDir, String prefix) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        if (filePart.getSize() > MAX_SIZE) {
            throw new IOException("文件大小超过10MB限制");
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
        if (ext.isEmpty()) {
            throw new IOException("文件缺少扩展名");
        }
        if (BLOCKED_EXT.contains(ext)) {
            throw new IOException("不允许上传该类型文件: ." + ext);
        }
        if (!ALLOWED_EXT.contains(ext)) {
            throw new IOException("仅允许上传 pdf/doc/docx/zip/rar 文件");
        }
    }
}
