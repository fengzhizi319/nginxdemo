package com.example.demo.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * UserService 单元测试。
 *
 * 测试目标：
 * 1. 验证构造方法初始化时创建了 3 条默认用户数据。
 * 2. 验证 findAll 能返回所有用户。
 * 3. 验证 findById 能根据 ID 查询用户，找不到时返回错误提示。
 * 4. 验证 create 能为用户分配自增 ID 并保存。
 */
class UserServiceTest {

    private UserService userService;

    @BeforeEach
    void setUp() {
        // 每个测试方法前新建实例，保证状态隔离
        userService = new UserService();
    }

    @Test
    @DisplayName("初始化时应包含 3 条默认用户数据")
    void shouldInitializeWithThreeDefaultUsers() {
        List<Map<String, Object>> users = userService.findAll();

        assertEquals(3, users.size(), "默认应该有 3 条用户数据");

        // 验证默认数据内容
        assertTrue(users.stream().anyMatch(u -> "张三".equals(u.get("name")) && Integer.valueOf(25).equals(u.get("age"))));
        assertTrue(users.stream().anyMatch(u -> "李四".equals(u.get("name")) && Integer.valueOf(30).equals(u.get("age"))));
        assertTrue(users.stream().anyMatch(u -> "王五".equals(u.get("name")) && Integer.valueOf(28).equals(u.get("age"))));
    }

    @Test
    @DisplayName("findAll 应返回所有用户列表")
    void findAllShouldReturnAllUsers() {
        // 初始化 3 条 + 新增 2 条
        userService.create(Map.of("name", "赵六", "age", 35));
        userService.create(Map.of("name", "孙七", "age", 40));

        List<Map<String, Object>> users = userService.findAll();

        assertEquals(5, users.size(), "新增 2 条后应该有 5 条用户数据");
    }

    @Test
    @DisplayName("findById 应返回对应用户")
    void findByIdShouldReturnUser() {
        Map<String, Object> user = userService.findById(1L);

        assertNotNull(user);
        assertEquals("张三", user.get("name"));
        assertEquals(25, user.get("age"));
        assertEquals(1L, user.get("id"));
    }

    @Test
    @DisplayName("findById 查询不存在的用户时应返回错误提示")
    void findByIdShouldReturnErrorForNonExistentUser() {
        Map<String, Object> result = userService.findById(999L);

        assertTrue(result.containsKey("error"));
        assertEquals("用户不存在", result.get("error"));
    }

    @Test
    @DisplayName("create 应分配自增 ID 并保存用户")
    void createShouldAssignAutoIncrementIdAndSaveUser() {
        Map<String, Object> newUser = Map.of("name", "周八", "age", 45);

        Map<String, Object> created = userService.create(newUser);

        assertEquals(4L, created.get("id"), "ID 应该从 1 开始自增，默认 3 条数据后下一条为 4");
        assertEquals("周八", created.get("name"));
        assertEquals(45, created.get("age"));

        // 验证能查询到新增的用户
        Map<String, Object> found = userService.findById(4L);
        assertEquals("周八", found.get("name"));
    }

    @Test
    @DisplayName("create 不应修改原始传入对象")
    void createShouldNotModifyOriginalInput() {
        Map<String, Object> original = Map.of("name", "吴九", "age", 50);

        userService.create(original);

        // Map.of 创建的是不可变 Map，如果修改会抛异常；
        // 这里额外验证原始对象没有 id 字段
        assertFalse(original.containsKey("id"), "原始对象不应被添加 id 字段");
    }
}
