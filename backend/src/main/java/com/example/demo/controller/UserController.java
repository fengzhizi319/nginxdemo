package com.example.demo.controller;

import com.example.demo.service.UserService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * RESTful API 控制器。
 *
 * 学习点：
 * 1. @RestController = @Controller + @ResponseBody，表示该类所有方法都返回 JSON 数据。
 * 2. @RequestMapping("/api/users") 给类设置统一的路径前缀。
 *    部署到 Tomcat 后，WAR 名为 backend，所以完整路径是：
 *    http://localhost:8080/backend/api/users
 * 3. Nginx 反向代理后，前端只需要访问 /api/users，Nginx 会自动转发到 Tomcat。
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    // 构造器注入：Spring 会自动把 UserService 的实例注入进来
    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 获取用户列表。
     * HTTP 方法：GET
     * 示例请求：GET /api/users
     * 示例响应：[{"id":1,"name":"张三","age":25}, ...]
     */
    @GetMapping
    public List<Map<String, Object>> listUsers() {
        return userService.findAll();
    }

    /**
     * 根据 ID 获取单个用户。
     * HTTP 方法：GET
     * 路径变量：{id}
     * 示例请求：GET /api/users/1
     */
    @GetMapping("/{id}")
    public Map<String, Object> getUser(@PathVariable Long id) {
        return userService.findById(id);
    }

    /**
     * 新增用户。
     * HTTP 方法：POST
     * 请求体：JSON 对象，例如 {"name":"李四","age":30}
     */
    @PostMapping
    public Map<String, Object> createUser(@RequestBody Map<String, Object> user) {
        return userService.create(user);
    }

    /**
     * 健康检查接口。
     * Nginx 可以用它来做后端存活检测（upstream 健康检查需额外模块，这里是简单示例）。
     */
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of(
                "status", "UP",
                "container", "Tomcat",
                "message", "后端服务运行正常"
        );
    }
}
