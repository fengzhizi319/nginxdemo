package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * Spring Boot 应用启动类。
 *
 * 学习点：
 * 1. @SpringBootApplication 是一个组合注解，相当于：
 *    - @Configuration：标明这是一个配置类
 *    - @EnableAutoConfiguration：开启自动配置
 *    - @ComponentScan：自动扫描同包及子包下的组件
 * 2. 为了把本项目打成 WAR 包放到外置 Tomcat 中运行，必须继承 SpringBootServletInitializer，
 *    并重写 configure() 方法，返回应用主类。
 *    这样 Tomcat 启动 WAR 时，才能正确找到 Spring Boot 的入口并初始化容器。
 * 3. 如果用内嵌 Tomcat 运行（java -jar backend.war），main 方法中的 SpringApplication.run 也能启动。
 */
@SpringBootApplication
public class DemoApplication extends SpringBootServletInitializer {

    /**
     * 外置 Tomcat 启动 WAR 包时会调用这个方法。
     * 它告诉 Tomcat：Spring Boot 应用的主类是 DemoApplication.class。
     */
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(DemoApplication.class);
    }

    /**
     * 本地开发/内嵌 Tomcat 启动入口。
     * 运行：mvn spring-boot:run 或 java -jar target/backend.war
     */
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
