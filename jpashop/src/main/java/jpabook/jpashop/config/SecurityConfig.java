package jpabook.jpashop.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter{

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.authorizeRequests()
		.mvcMatchers("/").permitAll()
		.mvcMatchers("/api/**").permitAll()
		.mvcMatchers("/amdin").hasRole("ADMIN");
		//.anyRequest().authenticated();
		http.formLogin().and().httpBasic();
	}

	@Override
	protected void configure(AuthenticationManagerBuilder auth) throws Exception {
		auth.inMemoryAuthentication()
		.withUser("jaqp7363_admin").password("{noop}1001admin").roles("ADMIN").and()
		.withUser("jaqp7363").password("{noop}1001").roles("USER");
	}

	
}
