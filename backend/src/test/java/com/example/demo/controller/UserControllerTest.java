package com.example.demo.controller;

import com.example.demo.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Map;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * UserController Web 层单元测试。
 *
 * 测试目标：
 * 1. 验证 GET /api/users 返回用户列表。
 * 2. 验证 GET /api/users/{id} 返回指定用户。
 * 3. 验证 POST /api/users 创建用户并返回结果。
 * 4. 验证 GET /api/users/health 返回健康状态。
 *
 * 使用 @WebMvcTest 只加载 Controller 层，不启动完整的 Spring 上下文，UserService 用 @MockBean 模拟。
 */
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("GET /api/users 应返回用户列表")
    void listUsersShouldReturnUserList() throws Exception {
        when(userService.findAll()).thenReturn(List.of(
                Map.of("id", 1L, "name", "张三", "age", 25),
                Map.of("id", 2L, "name", "李四", "age", 30)
        ));

        mockMvc.perform(get("/api/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].name", is("张三")))
                .andExpect(jsonPath("$[1].age", is(30)));
    }

    @Test
    @DisplayName("GET /api/users/{id} 应返回指定用户")
    void getUserShouldReturnUserById() throws Exception {
        when(userService.findById(1L)).thenReturn(Map.of("id", 1L, "name", "张三", "age", 25));

        mockMvc.perform(get("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.name", is("张三")))
                .andExpect(jsonPath("$.age", is(25)));
    }

    @Test
    @DisplayName("GET /api/users/{id} 查询不存在用户时应返回错误提示")
    void getUserShouldReturnErrorForNonExistentId() throws Exception {
        when(userService.findById(999L)).thenReturn(Map.of("error", "用户不存在"));

        mockMvc.perform(get("/api/users/999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.error", is("用户不存在")));
    }

    @Test
    @DisplayName("POST /api/users 应创建用户并返回带 ID 的用户对象")
    void createUserShouldReturnCreatedUser() throws Exception {
        Map<String, Object> request = Map.of("name", "赵六", "age", 35);
        Map<String, Object> response = Map.of("id", 4L, "name", "赵六", "age", 35);

        when(userService.create(any())).thenReturn(response);

        mockMvc.perform(post("/api/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(4)))
                .andExpect(jsonPath("$.name", is("赵六")))
                .andExpect(jsonPath("$.age", is(35)));
    }

    @Test
    @DisplayName("GET /api/users/health 应返回健康检查信息")
    void healthShouldReturnUpStatus() throws Exception {
        mockMvc.perform(get("/api/users/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("UP")))
                .andExpect(jsonPath("$.container", is("Tomcat")))
                .andExpect(jsonPath("$.message", is("后端服务运行正常")));
    }
}
