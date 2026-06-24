package com.example.demo.service;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 用户业务逻辑层。
 *
 * 学习点：
 * 1. @Service 是 @Component 的特化，表示这是一个业务层 Bean，会被 Spring 扫描并管理。
 * 2. 这里用内存 Map 模拟数据库，避免引入数据库依赖，让示例保持简单。
 * 3. ConcurrentHashMap + AtomicLong 保证多线程下的线程安全（Tomcat 是多线程容器）。
 */
@Service
public class UserService {

    // 用线程安全的 Map 存储用户数据，key 是用户 ID
    private final Map<Long, Map<String, Object>> users = new ConcurrentHashMap<>();

    // 自增 ID 生成器，线程安全
    private final AtomicLong idGenerator = new AtomicLong(1);

    /**
     * 构造方法：初始化几条示例数据，方便前端一启动就能看到效果。
     */
    public UserService() {
        create(Map.of("name", "张三", "age", 25));
        create(Map.of("name", "李四", "age", 30));
        create(Map.of("name", "王五", "age", 28));
    }

    /**
     * 查询所有用户。
     */
    public List<Map<String, Object>> findAll() {
        return new ArrayList<>(users.values());
    }

    /**
     * 根据 ID 查询用户，找不到返回空 Map。
     */
    public Map<String, Object> findById(Long id) {
        return users.getOrDefault(id, Map.of("error", "用户不存在"));
    }

    /**
     * 新增用户。
     */
    public Map<String, Object> create(Map<String, Object> user) {
        Long id = idGenerator.getAndIncrement();
        // 复制一份可变 Map，避免直接修改调用方传入的不可变 Map（例如 Map.of 创建的）
        Map<String, Object> mutableUser = new HashMap<>(user);
        mutableUser.put("id", id);
        users.put(id, mutableUser);
        return mutableUser;
    }
}
