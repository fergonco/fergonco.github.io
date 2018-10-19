---
layout: default
title: 'Form-based authentication on single page applications with Spring Security'
date: 2018-10-12
---

# Form-based authentication on single page applications with Spring Security

In this post I'll show how to change the default form based authentication behavior in Spring Security in order to adapt it to Singe Page Applications (SPA). The default workflow is as follows:

- When a user accesses a protected resource without being authenticated, it redirects to the login page (Spring Security generates a page automatically for you if there is none).
- When the login succeeds, it redirects to the root of the application.
- On a successful logout, it redirects to *http://localhost:8080/login?logout*

However, on a SPA we don't want to reload the page. Instead we will be sending the user credentials with an asynchronous call. Our desired workflow would be as follows:

- Return 403 (Forbiden) if the resource is protected and user is no autenticated.
- On successful login return 200 (OK). If login fails, return 401 (Unauthorized).
- On a successful logout return 200 (OK).

The code shown in the following points can be found here: [https://github.com/fergonco/spring-form-based-auth](https://github.com/fergonco/spring-form-based-auth).

## Default login workflow

If you want to do the next steps by yourself you can create a new project using with Spring Initializr (https://start.spring.io/), selecting "Web", "Security" and "DevTools" as technologies.

We create now a static resource that we want to protect, *secret.txt*, in the *src/main/resources/static* folder containing something like:

    This is our secret

This resource can be accessed on *http://localhost:8080/secret.txt*.

In order to protect it we will configure Spring Security:

{% highlight java %}
    package org.fergonco.blog.springformbasedauth;

    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.context.annotation.Configuration;
    import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
    import org.springframework.security.config.annotation.web.builders.HttpSecurity;
    import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
    import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
    import org.springframework.security.core.userdetails.User;

    @Configuration
    @EnableWebSecurity
    public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http.authorizeRequests().mvcMatchers("/secret.txt").authenticated()//
                    .and()//
                    .formLogin().permitAll();

            http.csrf().disable();
        }

        @Autowired
        public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
            auth.inMemoryAuthentication()
                    .withUser(User.withDefaultPasswordEncoder().username("user").password("123").roles("USER").build());
        }
    }
{% endhighlight %}

This configuration does three things:

- Requires authentication in order to access the protected resource, installing a */login* and */logout* endpoints that follow the behavior described before. 
- Disables CSRF, for simplicity.
- Creates a user called "user" with password "123".

Some curl outputs follows, to demonstrate the redirection workflow:

- redirecting (302) to the login page whenever an unauthenticated user requests the protected resource.

{% highlight bash %}
    $ curl -v http://localhost:8080/secret.txt
    *   Trying 127.0.0.1...
    * TCP_NODELAY set
    * Connected to localhost (127.0.0.1) port 8080 (#0)
    > GET /secret.txt HTTP/1.1
    > Host: localhost:8080
    > User-Agent: curl/7.58.0
    > Accept: */*
    > 
    < HTTP/1.1 302 
    < Set-Cookie: JSESSIONID=3B049FEEB403F48DF7E1A9C329F2A84C; Path=/; HttpOnly
    < X-Content-Type-Options: nosniff
    < X-XSS-Protection: 1; mode=block
    < Cache-Control: no-cache, no-store, max-age=0, must-revalidate
    < Pragma: no-cache
    < Expires: 0
    < X-Frame-Options: DENY
    < Location: http://localhost:8080/login
    < Content-Length: 0
    < Date: Sat, 13 Oct 2018 05:28:20 GMT
    < 
{% endhighlight %}

- redirecting to / when the login takes place successfully, setting a *JSESSIONID* cookie with the id of the session created on the server.

{% highlight bash %}
    $ curl -v -F username=user -F password=123 --cookie-jar /tmp/cookie http://localhost:8080/login
    *   Trying 127.0.0.1...
    * TCP_NODELAY set
    * Connected to localhost (127.0.0.1) port 8080 (#0)
    > POST /login HTTP/1.1
    > Host: localhost:8080
    > User-Agent: curl/7.58.0
    > Accept: */*
    > Content-Length: 247
    > Content-Type: multipart/form-data; boundary=------------------------7c52a64ded158a72
    > 
    < HTTP/1.1 302 
    < X-Content-Type-Options: nosniff
    < X-XSS-Protection: 1; mode=block
    < Cache-Control: no-cache, no-store, max-age=0, must-revalidate
    < Pragma: no-cache
    < Expires: 0
    < X-Frame-Options: DENY
    < Set-Cookie: JSESSIONID=D219E7256B6823F21C5B4A6522A4267D; Path=/; HttpOnly
    < Location: http://localhost:8080/
    < Content-Length: 0
    < Date: Sat, 13 Oct 2018 05:47:34 GMT
    * HTTP error before end of send, stop sending
    < 
{% endhighlight %}

- redirecting to *http://localhost:8080/login?logout* when logging out.

{% highlight bash %}
    $ curl -v --cookie /tmp/cookie http://localhost:8080/logout
    *   Trying 127.0.0.1...
    * TCP_NODELAY set
    * Connected to localhost (127.0.0.1) port 8080 (#0)
    > GET /logout HTTP/1.1
    > Host: localhost:8080
    > User-Agent: curl/7.58.0
    > Accept: */*
    > Cookie: JSESSIONID=ED68465BBA95E94A4C88694D72DBC07C
    >
    < HTTP/1.1 302
    < X-Content-Type-Options: nosniff
    < X-XSS-Protection: 1; mode=block
    < Cache-Control: no-cache, no-store, max-age=0, must-revalidate
    < Pragma: no-cache
    < Expires: 0
    < X-Frame-Options: DENY
    < Location: http://localhost:8080/login?logout
    < Content-Length: 0
    < Date: Sat, 13 Oct 2018 05:51:42 GMT
    <
    * Connection #0 to host localhost left intact
{% endhighlight %}

## SPA login workflow

In order to get rid of all the redirections and get the desired response codes we need to change the configuration to this:

{% highlight java %}
	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.authorizeRequests().mvcMatchers("/secret.txt").authenticated()//
				.and()//
				// Return 403 accessing resources that require authentication
				.exceptionHandling().authenticationEntryPoint(new Http403ForbiddenEntryPoint()).and()//
				.formLogin().permitAll()//
				// If login fails, return 401
				.failureHandler(new HTTPStatusHandler(HttpStatus.UNAUTHORIZED))//
				// If login succeeds return 200
				.successHandler(new HTTPStatusHandler(HttpStatus.OK)).and()//
				.logout()//
				// If logout succeeds return 200
				.logoutSuccessHandler(new HTTPStatusHandler(HttpStatus.OK));//

		http.csrf().disable();
	}
{% endhighlight %}

which:

- installs an exception handler to return 403 whenever an unauthenticated user accesses the protected resource. This is actually the default behavior of Spring Security, but the call to *formLogin* to setup form-based login overrides it.
- installs success and failure handlers for login and logout. These handlers are instances of an inner class that returns in all cases a status code received as a parameter:

{% highlight java %}
	class HTTPStatusHandler
			implements AuthenticationFailureHandler, AuthenticationSuccessHandler, LogoutSuccessHandler {

		private HttpStatus status;

		public HTTPStatusHandler(HttpStatus status) {
			this.status = status;
		}

		@Override
		public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
				AuthenticationException exception) throws IOException, ServletException {
			onAuthenticationSuccess(request, response, null);
		}

		@Override
		public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
				Authentication authentication) throws IOException, ServletException {
			response.setStatus(status.value());
		}

		@Override
		public void onLogoutSuccess(HttpServletRequest request, HttpServletResponse response,
				Authentication authentication) throws IOException, ServletException {
			onAuthenticationSuccess(request, response, null);
		}

	}
{% endhighlight %}

Now, the same curl commands as before. Note that we don't get redirections anymore but the session management and the sending of the session cookie is still there.

- An unauthenticated user requests the protected resource.

{% highlight bash %}
    $ curl -v http://localhost:8080/secret.txt
    *   Trying 127.0.0.1...
    * TCP_NODELAY set
    * Connected to localhost (127.0.0.1) port 8080 (#0)
    > GET /secret.txt HTTP/1.1
    > Host: localhost:8080
    > User-Agent: curl/7.58.0
    > Accept: */*
    > 
    < HTTP/1.1 403 
    < Set-Cookie: JSESSIONID=BDD71309C31B229D3CACAFC9616D7171; Path=/; HttpOnly
    < X-Content-Type-Options: nosniff
    < X-XSS-Protection: 1; mode=block
    < Cache-Control: no-cache, no-store, max-age=0, must-revalidate
    < Pragma: no-cache
    < Expires: 0
    < X-Frame-Options: DENY
    < Content-Type: application/json;charset=UTF-8
    < Transfer-Encoding: chunked
    < Date: Sat, 13 Oct 2018 06:25:36 GMT
    < 
    * Connection #0 to host localhost left intact
    {"timestamp":"2018-10-13T06:25:36.124+0000","status":403,"error":"Forbidden","message":"Access Denied","path":"/secret.txt"}
{% endhighlight %}

- Successful login.

{% highlight bash %}
    $ curl -v -F username=user -F password=123 --cookie-jar /tmp/cookie http://localhost:8080/login
    *   Trying 127.0.0.1...
    * TCP_NODELAY set
    * Connected to localhost (127.0.0.1) port 8080 (#0)
    > POST /login HTTP/1.1
    > Host: localhost:8080
    > User-Agent: curl/7.58.0
    > Accept: */*
    > Content-Length: 247
    > Content-Type: multipart/form-data; boundary=------------------------cf8a1b68f3403b66
    > 
    < HTTP/1.1 200 
    < X-Content-Type-Options: nosniff
    < X-XSS-Protection: 1; mode=block
    < Cache-Control: no-cache, no-store, max-age=0, must-revalidate
    < Pragma: no-cache
    < Expires: 0
    < X-Frame-Options: DENY
    * cookie size: name/val 10 + 32 bytes
    * cookie size: name/val 4 + 1 bytes
    * cookie size: name/val 8 + 0 bytes
    * Added cookie JSESSIONID="8D3D22C89AEE8477092A3036C7113002" for domain localhost, path /, expire 0
    < Set-Cookie: JSESSIONID=8D3D22C89AEE8477092A3036C7113002; Path=/; HttpOnly
    < Content-Length: 0
    < Date: Sat, 13 Oct 2018 06:34:00 GMT
    < 
    * Connection #0 to host localhost left intact
{% endhighlight %}

- Logging out.

{% highlight bash %}
    $ curl -v --cookie /tmp/cookie http://localhost:8080/logout
    * Trying 127.0.0.1...
    * TCP_NODELAY set
    * Connected to localhost (127.0.0.1) port 8080 (#0)
    > GET /logout HTTP/1.1
    > Host: localhost:8080
    > User-Agent: curl/7.58.0
    > Accept: */*
    > Cookie: JSESSIONID=8D3D22C89AEE8477092A3036C7113002
    > 
    < HTTP/1.1 200 
    < X-Content-Type-Options: nosniff
    < X-XSS-Protection: 1; mode=block
    < Cache-Control: no-cache, no-store, max-age=0, must-revalidate
    < Pragma: no-cache
    < Expires: 0
    < X-Frame-Options: DENY
    < Content-Length: 0
    < Date: Sat, 13 Oct 2018 06:36:12 GMT
    < 
    * Connection #0 to host localhost left intact
{% endhighlight %}
