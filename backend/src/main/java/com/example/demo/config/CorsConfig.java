package com.example.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 跨域配置（CORS，Cross-Origin Resource Sharing）。
 *
 * 学习点：
 * 1. 本示例通过 Nginx 反向代理把前端请求转发到后端，因此前端调用的是“同源”地址，
 *    理论上不需要后端开 CORS。
 * 2. 但为了让你理解 CORS，这里保留一个宽松配置。开发时如果直接访问 Tomcat（例如 http://localhost:8080/backend/api/users），
 *    浏览器也不会报跨域错误。
 * 3. 生产环境不要把 allowedOrigins 写成 "*"，应该指定具体域名。
 */
@Configuration
public class CorsConfig {

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")        // 对 /api/ 下的所有接口生效
                        .allowedOrigins("*")          // 允许所有来源（仅学习用）
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                        .allowedHeaders("*")
                        .maxAge(3600);                // 预检请求缓存 1 小时
            }
        };
    }
}
