---
layout: default
title: 'Spring REST API authentication using JSON Web Tokens'
date: 2018-10-17
---

# Spring REST API authentication using JSON Web Tokens

In the [last post](http://fergonco.org/2018/10/12/Form-based-authentication-on-single-page-applications-with-Spring-Security.html) I showed how to implement form-based authentication with Spring Security in the context of a Single Page Application. Plugging our own implementation in some points of the Spring Security model allowed to have custom response codes to the login and logout endpoints while keeping the default logic: session creation, response with the Set-Cookie header containing the id of the session, etc.

However, this approach is not suitable for REST APIs. The fact that the server keeps a session with information about the user is in conflict with the REST stateless principle:

{% highlight java %}
    [...] each request from client to server must contain 
    all of the information necessary to understand the 
    request, and cannot take advantage of any stored 
    context on the server.
{% endhighlight %}

Respecting this principle allows us to scale a system easily (you don't need to share sessions among the nodes) and simplifies the monitoring and recovering processes, as [stated by Roy Fielding in his dissertation](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_3).

Therefore, the session information has to be kept on the client side and be sent on each request. This information can be just the username (the server would get more information from the database) or it may include more data, like roles, permissions, etc. (making it possible to save a database access).

In the following points I'll be implementing authentication with [JSON Web Tokens (JWT)](https://tools.ietf.org/html/rfc7519), which is very common nowadays. Spring does not offer out of the box support for JWT and I had to gather information from many sources in order to get a complete picture. This post tries to summarize all the information I got.

## JWT

A better explanation can be found [here](https://github.com/jwtk/jjwt#overview) ([JJWT](https://github.com/jwtk/jjwt) is the Java library used in this post to manipulate JWT tokens), so I will quickly go over the JWT aspects that are particularly relevant. For a detailed description, you can read [the specification](https://tools.ietf.org/html/rfc7519).

JSON Web Tokens have three parts:

* A header containing information such as the algorithm used to sign the token.

  {% highlight json %}
    {
      "typ":"JWT",
      "alg":"HS256"
    }
  {% endhighlight %}
  
* A payload containing claims. There are registered claims ( [link to specification](https://tools.ietf.org/html/rfc7519#section-4.1) ), like expiration date (exp) or subject (sub), and custom "claims", like "is_root" in the following example.
  
  {% highlight json %}
    {
      "iat": 1948729422,
      "exp": 1948737982,
      "sub": "admin",
      "is_root":true
    }
  {% endhighlight %}

* A signature of the previous two parts.

The token consists of the concatenation of the header in Base64, a dot, the body in Base64, a dot and the signature in Base64. For example:

    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3Mi
    OiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0d
    HA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ.dBj
    ftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk

Note that in this example, the token is signed but not encrypted (also a possibility). If you decode the two first Base64 parts you will get some perfectly readable JSON. Therefore, you may not want to include sensitive data on your tokens, like a telephone number or an email address, and you may consider using a secure connection between client and server (see token hijacking later).

## Token authentication

The workflow for a token authentication schema is as follows:

{% highlight plaintext %}
(1) The client sends credentials to an authentication service.
(2) The service
   (2.1) validates the credentials. If they are correct,
   (2.2) it generates a token signed with a private key
   (2.3) it returns it to the client
(3) The client receives the token in the response and keeps it for use later on
    requests that require authentication.
{% endhighlight %}

Later, the client accesses a resource that requires authentication:

{% highlight plaintext %}
(4) The client sends a request including the token in the *Authorization* header, 
    normally with this format: "Bearer <token>".
(5) The server performs several checks, like the signature, expiration date, etc. and 
    obtains the relevant information (user identification, role, etc.)
(6) If all the checks are passed, the server returns the resource to the client.
{% endhighlight %}

This schema presents some challenges that are new with regard to the cookie based session management:

### How do you logout?

Once you generate a token it exists forever. Does that mean that it is not possible to logout? Somehow.

Loging out, as in the user hitting "loging out" and navigating away to a login form, can be implemented on the client side by just dropping the token. But the token will still be valid even if nobody uses it, so we should care about where we store it, how we transmit it to the server, etc.

It is a good strategy to set an expiration date, in order not to have many valid tokens around. Then, after the user logs out on the client, the token is still valid for a while, but eventually will go invalid.

### How do you deal with an expired token?

So our tokens have an expiration date. Let's say 10 minutes after they are created. Should the user log in again each 10 minutes? Yes, unless something is done to prevent it. For example, the client can use an about to expire token to obtain a new one. This can be automated, so that any request containing a token in the last part of its lifespan results on a response containing a new fresh token.

This way the application would log the user out if he does not use the application for a while (whatever "last part of the token lifespan" means in your application). If the user uses the application regularly he will never be logged out.

Adjusting the token lifespan to few minutes or few days gives a very different user experience.

### How can the server revoke a token?

A similar problem as logout: if a user is vandalizing the application and you want to revoke his access immediately, how can you do it?

A solution could be to keep a black list of tokens. Of course this comes with a penalty because the server should check the black list in the point (5) in the workflow above.

### Token hijacking

Analogously to the [session hijacking](https://en.wikipedia.org/wiki/Session_hijacking), if some attacker gets access to the token he can use it until it reaches its expiration date. In the same way, the solution is basically using a secure connection between server and client. Additionally it is possible to encrypt the token ( [JWE](https://tools.ietf.org/html/rfc7516) ).

Some techniques, as browser fingerprinting, can make the hijacking harder but is far from the security level that the previous options give.

### Secret rotation

Can you imagine what would happen if somebody could generate the tokens and sign them as if he was the server? Well, that could be as easy as getting your private key compromised. A common practice is not to store secret keys in code hosted in public repositories (note the irony). That and secret rotation: automate a system in order to change the private key regularly. And, following [Kerckhoffs's principle](https://en.wikipedia.org/wiki/Kerckhoffs%27s_principle), you should consider the rotation algorithm known to the attacker.

## Implementation

The following token based authentication schema implementation has the following features:

* It uses JWT as tokens.
* It generates tokens containing the user id in the subject (sub) claim. No role information will be included so the services using this token will have to query the database in order to get that information.
* Tokens will have an expiration date.
* At the end of the expiration date, a request from the client will get a response containing a new fresh token.
* Because of the previous point (a token being potentially returned in any request) the tokens are returned in custom HTTP headers.
* Client side logout (no blacklists).

The following code can be found in [this GitHub repository](https://github.com/fergonco/spring-token-based-auth).

As in the previous post, we will be creating a protected resource "secret.txt" in the *src/main/resources/static* folder, that can be accessed in the root of our application and that contains some string like:

    This is our secret!

And again as in the previous post (a quick 2 minutes read is worth if you don't know what is going on here), we replace the default Spring Security form based login redirections:

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

With this departing point, the implementation consists on:

* A success handler for login actions that returns the new token in a HTTP header (*jwt-token*).
* JWTFilter: A *javax.servlet.Filter* that processes each request and:
  * Creates an *Authentication* instance on the *SecurityContext* whenever the request contains a valid token.
  * If the token is at the end of its lifespan it will return a new token in the *jwt-new-token* header.
* JWTProvider: A class dealing with the token related operations: creation, extraction from the request, validation, etc.

Let's start by the login success handler. Instead of using *HTTPStatusHandler* in order to just set the status code, we will need another implementation that sets the status code to 200 and returns a token. This is configured in the *WebSecurityConfig* class like this:

{% highlight java %}
        .formLogin().permitAll()//
        [...]
        // If login succeeds return 200 with JWT token
        .successHandler(new JWTStatusHandler()).and()//
{% endhighlight %}

Whenever a successful login takes place, the instance of *JWTStatusHandler* will be called, which will create the token and return it in the *jwt-token* header, along with a 200 (OK) status code:

{% highlight java %}
    class JWTStatusHandler implements AuthenticationSuccessHandler {
        @Override
        public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                Authentication authentication) throws IOException, ServletException {
            String token = jwtProvider.createToken(authentication.getName());
            response.addHeader("jwt-token", token);
            response.setStatus(HttpStatus.OK.value());
        }
    }
{% endhighlight %}

This code makes use of the *JWTProvider.createToken* method, which looks like this:

{% highlight java %}
    public String createToken(String username) {
        Date now = new Date();
        Date expiration = new Date(now.getTime() + validityInMilliseconds);
        return Jwts.builder()//
                .setSubject(username)//
                .setIssuedAt(now)//
                .setExpiration(expiration)//
                .signWith(ALGORITHM, secretKey)//
                .compact();
    }
{% endhighlight %}

It provides the JJWT library with the token claims, such as expiration date and subject (username), and the algorithm and secret key to sign the token. With this information JJWT generates the token String.

Now the client will read the *jwt-token* header and will keep it, sending it back to the server when it requires to access a protected resource. The server will have to check for this token in each request, building an *Authentication* instance for the controllers. That's what the filter does.

The filter can be installed in *WebSecurityConfig*, before the UsernamePasswordAuthenticationFilter, like this:

{% highlight java %}
    http.addFilterBefore(new JWTFilter(jwtProvider), UsernamePasswordAuthenticationFilter.class);
{% endhighlight %}

For a detailed description of the Spring Security filter chain just [check the documentation](https://docs.spring.io/spring-security/site/docs/5.0.9.RELEASE/reference/htmlsingle/#filter-ordering).

The code of the filter is the following:

{% highlight java %}
package org.fergonco.blog.springtokenbasedauth;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.GenericFilterBean;

public class JWTFilter extends GenericFilterBean {

    private JWTProvider jwtProvider;

    public JWTFilter(JWTProvider jwtProvider) {
        this.jwtProvider = jwtProvider;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Get the token from the request
        String token = jwtProvider.getToken((HttpServletRequest) request);
        try {
            // If there was a token and it is valid (e.g.: not expired)
            if (token != null && jwtProvider.validateToken(token)) {
                // Get the authentication instance and set it in the SecurityContext
                SecurityContextHolder.getContext().setAuthentication(jwtProvider.getAuthentication(token));

                // Check if the token is about to expire and we need to generate a fresh one
                String newToken = jwtProvider.getRefreshToken(token);
                if (newToken != null) {
                    // In that case we will return it on a different header
                    ((HttpServletResponse) response).addHeader("jwt-new-token", newToken);
                }
            }
        } catch (Exception e) {
            // Be sure to clear everything if something when wrong
            SecurityContextHolder.clearContext();
        }

        // Let the filter chain go on
        chain.doFilter(request, response);
    }

}
{% endhighlight %}

First, the filter gets the token from the request invoking *getToken*:

{% highlight java %}
    public String getToken(HttpServletRequest req) {
        String bearerToken = req.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7, bearerToken.length());
        }
        return null;
    }
{% endhighlight %}

As said before, the token is sent in the *Authorization* header as "Bearer &lt;token&gt;".

The next thing the filter does is to check if the token is valid:

{% highlight java %}
    public boolean validateToken(String token) {
        Jws<Claims> claims = Jwts.parser().setSigningKey(secretKey).parseClaimsJws(token);
        if (SignatureAlgorithm.forName(claims.getHeader().getAlgorithm()) != ALGORITHM) {
            return false;
        }
        return true;
    }
{% endhighlight %}

Note that the *parseClaimsJws* method throws an exception if the token is expired, so the method code does not have to take care about that:

     * @throws ExpiredJwtException      if the specified JWT is a Claims JWT and the Claims has an expiration time
     *                                  before the time this method is invoked.

However, it must check if the algorithm used to sign the token is different to the one used to create it (*ALGORITHM* constant). This is very important, specially because the algorithm can be "none"! Imagine your access control layer accepting tokens that anybody could be generating.

If the token is valid, an Authentication instance is generated from the token with the *getAuthentication* method:

{% highlight java %}
    public Authentication getAuthentication(String tokenString) {
        Jws<Claims> claims = Jwts.parser().setSigningKey(secretKey).parseClaimsJws(tokenString);
        String user = claims.getBody().getSubject();
        UserDetails userDetails = myUserDetails.loadUserByUsername(user);
        UsernamePasswordAuthenticationToken ret = new UsernamePasswordAuthenticationToken(userDetails, "",
                userDetails.getAuthorities());
        return ret;
    }
{% endhighlight %}

It just accesses the body of the token and gets the *subject* claim containing the username. With this information, it uses the usual Spring Security beans in order to load user data and generate an *Authentication* instance.

## Client usage

Let's use a bit of curl to check our implementation. First, if we try to access the protected resource we will get a forbidden (403) response:

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
< X-Content-Type-Options: nosniff
< X-XSS-Protection: 1; mode=block
< Cache-Control: no-cache, no-store, max-age=0, must-revalidate
< Pragma: no-cache
< Expires: 0
< X-Frame-Options: DENY
< Content-Type: application/json;charset=UTF-8
< Transfer-Encoding: chunked
< Date: Fri, 19 Oct 2018 05:58:55 GMT
< 
* Connection #0 to host localhost left intact
{"timestamp":"2018-10-19T05:58:55.021+0000","status":403,"error":"Forbidden","message":"Access Denied","path":"/secret.txt"}
{% endhighlight %}

If we proceed to login we obtain a response with an OK (200) and a *jwt-token* header containing the token:

{% highlight bash %}
$ curl -v -F username=user -F password=123 http://localhost:8080/login
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8080 (#0)
> POST /login HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.58.0
> Accept: */*
> Content-Length: 247
> Content-Type: multipart/form-data; boundary=------------------------649be208f2531074
> 
< HTTP/1.1 200 
< jwt-token: eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiaWF0IjoxNTM5OTI5MjEyLCJleHAiOjE1Mzk5MjkyNzJ9.QrrJyjKpUK2Er2oYQ9f4tY-j26YC9Y1ldZiScPdWEz4
< X-Content-Type-Options: nosniff
< X-XSS-Protection: 1; mode=block
< Cache-Control: no-cache, no-store, max-age=0, must-revalidate
< Pragma: no-cache
< Expires: 0
< X-Frame-Options: DENY
< Content-Length: 0
< Date: Fri, 19 Oct 2018 05:59:13 GMT
< 
* Connection #0 to host localhost left intact
{% endhighlight %}

We can now use this token in the *Authorization* header in order to access the protected resource:

{% highlight java %}
$ curl -v -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiaWF0IjoxNTM5OTI5MjEyLCJleHAiOjE1Mzk5MjkyNzJ9.QrrJyjKpUK2Er2oYQ9f4tY-j26YC9Y1ldZiScPdWEz4' http://localhost:8080/secret.txt 
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8080 (#0)
> GET /secret.txt HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.58.0
> Accept: */*
> Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiaWF0IjoxNTM5OTI5MjEyLCJleHAiOjE1Mzk5MjkyNzJ9.QrrJyjKpUK2Er2oYQ9f4tY-j26YC9Y1ldZiScPdWEz4
> 
< HTTP/1.1 200 
< Last-Modified: Fri, 19 Oct 2018 05:57:41 GMT
< Accept-Ranges: bytes
< X-Content-Type-Options: nosniff
< X-XSS-Protection: 1; mode=block
< Cache-Control: no-cache, no-store, max-age=0, must-revalidate
< Pragma: no-cache
< Expires: 0
< X-Frame-Options: DENY
< Content-Type: text/plain
< Content-Length: 17
< Date: Fri, 19 Oct 2018 06:06:15 GMT
< 
* Connection #0 to host localhost left intact
This is my secret
{% endhighlight %}

And if we wait until the token is about to expire, the response will contain a *new-jwt-token* header with a fresh token to use in our next requests.

{% highlight java %}
$ curl -v -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiaWF0IjoxNTM5OTI5MjEyLCJleHAiOjE1Mzk5MjkyNzJ9.QrrJyjKpUK2Er2oYQ9f4tY-j26YC9Y1ldZiScPdWEz4' http://localhost:8080/secret.txt 
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8080 (#0)
> GET /secret.txt HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.58.0
> Accept: */*
> Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiaWF0IjoxNTM5OTI5MjEyLCJleHAiOjE1Mzk5MjkyNzJ9.QrrJyjKpUK2Er2oYQ9f4tY-j26YC9Y1ldZiScPdWEz4
> 
< HTTP/1.1 200 
< jwt-new-token: eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiaWF0IjoxNTM5OTI5MjY3LCJleHAiOjE1Mzk5MjkzMjd9.JOnXcYfGlVpxl9N4QhPStDVsnR563yWdZtKWzMKkoII
< Last-Modified: Fri, 19 Oct 2018 05:57:41 GMT
< Accept-Ranges: bytes
< X-Content-Type-Options: nosniff
< X-XSS-Protection: 1; mode=block
< Cache-Control: no-cache, no-store, max-age=0, must-revalidate
< Pragma: no-cache
< Expires: 0
< X-Frame-Options: DENY
< Content-Type: text/plain
< Content-Length: 17
< Date: Fri, 19 Oct 2018 06:07:47 GMT
< 
* Connection #0 to host localhost left intact
This is my secret
{% endhighlight %}

## What else?

Some more random thoughts that didn't receive enough attention this time:

* We didn't deal with client-side token persistent storage. What if you want tokens with a lifespan of days? Where do you store them? Local storage? Cookies? It would be a pity that your secure connection between client and server becomes useless just because you store your token where you shouldn't.

* Are your tokens long lived? Then you have either one of these problems:

  * If you hold more information than the user id, like roles, etc. how do you deal with updates?

  * If you hold just the user id and your services queries the database to get user information, your API is not so stateless anymore.

[This Hacker News discussion](https://news.ycombinator.com/item?id=11895440) about the usage of JWT as replacement for sessions is interesting.

## Best practices

There are a lot of pages suggesting best practices. I found these interesting:

- [JJWT documentation](https://github.com/jwtk/jjwt#jws)
- [This answer in Stack Overflow](https://stackoverflow.com/questions/30523238/best-practices-for-server-side-handling-of-jwt-tokens/44247711#44247711). Or maybe the whole question.
- [JSON Web Token Best Current Practices](https://tools.ietf.org/id/draft-ietf-oauth-jwt-bcp-02.html)

And I got a quick piece of advice by [Daniel Kachakil](https://twitter.com/Kachakil) in an informal conversation:

- Be sure it does not accept unsigned tokens (alg=none)
- If you use HMAC instead of asymmetric keys, use a long and complex key.
- Use an existing library. Own implementations are a danger!

