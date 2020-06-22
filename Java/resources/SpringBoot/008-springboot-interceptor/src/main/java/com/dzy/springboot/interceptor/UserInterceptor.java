package com.dzy.springboot.interceptor;

import com.dzy.springboot.model.User;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class UserInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        System.out.println("进入拦截器");

        // 编写业务拦截的规则
        // 从 session 中获取用户的信息
        User user = (User) request.getSession().getAttribute("user");

        // 判断用户是否登陆
        if (null == user) {
            // 未登录
            response.sendRedirect(request.getContextPath() + "/user/error");
            return  false;
        }

        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    }
}
