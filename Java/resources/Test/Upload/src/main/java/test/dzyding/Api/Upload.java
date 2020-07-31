package test.dzyding.Api;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.File;

@RestController
public class Upload {

    private  String savePath = "/Users/dzy/Documents/";

    @RequestMapping(value = "/uploadImage")
    public String uploadImage(MultipartFile file, HttpServletRequest request) throws Exception {
        String path = null;
        double fileSize = file.getSize();
        System.out.println("文件的大小是" + fileSize);

        byte[] sizeByte = file.getBytes();
        System.out.println("文件的 byte 大小是" + sizeByte.toString());

        if (file != null) {
            String type = null;
            String fileName = file.getOriginalFilename();
            System.out.println("上传的文件原名称：" + fileName);

            type = fileName.indexOf(".") != -1 ? fileName.substring(fileName.lastIndexOf(".") + 1, fileName.length()) : null;
            if (type != null) {
                String upType = type.toUpperCase();
                if ("GIF".equals(upType) || "PNG".equals(upType) || "JPG".equals(upType)) {

                    // 项目在容器中实际发布运行的跟路径
                    String realPath = request.getSession().getServletContext().getRealPath("/");
                    System.out.println("realPath：" + realPath);
                    // 自定义的文件名称
                    String trueFileName = String.valueOf(System.currentTimeMillis()) + "." + type;
                    System.out.println("trueFileName：" + trueFileName);
                    // 设置存放图片的路径
                    path = savePath + fileName;
                    System.out.println("存放路径为：" + path);
                    // 转存文件到指定的路径
                    file.transferTo(new File(path));
                    System.out.println("文件成功上传到指定目录下");
                    return "文件成功上传到指定目录下";
                }
            }else {
                System.out.println("不是我们想要的文件类型，请按需求重新上传");
                return "不是我们想要的文件类型，请按需求重新上传";
            }
        }else {
            System.out.println("文件类型为空");
            return "文件类型为空";
        }
        return "上传成功";
    }
}
