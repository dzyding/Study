package com.dzy.springboot.config;

import com.dzy.springboot.interceptor.UserInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration // 定义此类为配置文件(即相当于之前的 xml 配置文件)
public class InterceptorConfig implements WebMvcConfigurer {

    /**
     *
     * @param registry InterceptorRegistry 拦截器注册类
     *
     *                 addPathPatterns 添加拦截路径
     *                 excludePathPatterns 排除拦截路径
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 拦截 user 下的所有访问请求，必须用户登陆后才可访问，但是这样拦截的路径中有一些是不需要用户登陆也可以访问的
        String[] addPathPatterns = {
            "/user/**"
        };

        // 要排除的路径，说明不需要用户登陆也可访问
        String[] excludePathPatterns = {
            "/user/out", "/user/error", "/user/login", "/user/loginout"
        };
        registry.addInterceptor(new UserInterceptor())
                .addPathPatterns(addPathPatterns)
                .excludePathPatterns(excludePathPatterns);
    }
}
