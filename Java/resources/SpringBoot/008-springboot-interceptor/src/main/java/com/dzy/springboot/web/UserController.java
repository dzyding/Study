package com.dzy.springboot.web;

import com.dzy.springboot.model.User;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.PushBuilder;

@RestController
@RequestMapping(value = "/user") // 加在所有请求的前面 比如登陆变成了 /user/login
public class UserController {

    // 用户登陆的请求
    @RequestMapping(value = "/login")
    public Object login(HttpServletRequest request) {
        // 将用户的信息存放到 session 中
        User user = new User();
        user.setId(1001);
        user.setUsername("zhangsan");
        request.getSession().setAttribute("user", user);

        return "登陆成功";
    }

    @RequestMapping(value = "/loginout")
    public Object loginout(HttpServletRequest request) {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null)  {
            return "not login";
        }
        request.getSession().removeAttribute("user");
        return "loginout SUCCESS";
    }

    // 该请求需要用户登录之后才可访问
    @RequestMapping(value = "/center")
    public Object center() {
        return "See Center Message";
    }

    // 该请求不登陆也可访问
    @RequestMapping(value = "/out")
    public Object out() {
        return "Out see anytime";
    }

    // 如果用户未登录访问了需要登陆才可访问的请求，之后会跳转至该路径
    // 该请求用户不登陆也能访问
    @RequestMapping(value = "/error")
    public Object error() {
        return "error";
    }
}
