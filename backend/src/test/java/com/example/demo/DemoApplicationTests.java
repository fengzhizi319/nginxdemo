package com.example.demo;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * Spring Boot 应用上下文集成冒烟测试。
 *
 * 测试目标：
 * 1. 验证 Spring Boot 应用能正常启动并加载上下文。
 * 2. 验证 Controller、Service、CorsConfig 等 Bean 能被正确扫描和注入。
 *
 * 注意：该测试会启动一个嵌入式的 Tomcat 并监听 application.yml 中配置的端口（默认 8081）。
 * 如果 8081 端口被占用，可通过在 resources/application-test.yml 中覆盖 server.port 来解决。
 */
@SpringBootTest
class DemoApplicationTests {

    @Test
    @DisplayName("Spring Boot 应用上下文应能正常加载")
    void contextLoads() {
        // 只要测试能执行到这里，说明 Spring 上下文加载成功
    }
}
