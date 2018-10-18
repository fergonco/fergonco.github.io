---
layout: default
title: 'Spring REST API authentication using JSON Web Tokens'
date: 2018-10-17
---

☑ Read and check the structure is ok.
☐ Add best practices and give credit to Dani
Remove the user id as private claim and add "sub" instead.
☐ Check the use of *we* and set the different artifacts as subjects.
☐ Explain at some point that we are using headers to set the tokens and that the authentication is done with Authentication: Bearer &lt;token&gt;
☐ The class names do not correspond to the code.
☐ I dont knwo which parts of the token schema above are particular of jwt, so probably it's better to introduce JWT at the beginning and talk about it the whole time.
☐ Add that you dont want to put sensitive data in the token, like addresses, telephone numbers, etc.
☐ Formating of REST quote
☐ Check spelling and maybe translate

In the [last post]() I showed how to implement form-based authentication with Spring Security in the context of a Single Page Application. Plugging our own implementation in some points of the Spring Security model allowed to have custom response codes to the login and logout endpoints while keeping the default logic: session creation, response with the Set-Cookie header containing the id of the session, etc.

However, this approach is not suitable for REST APIs. The fact that the server keeps a session with information about the user is in conflict with the REST stateless principle:

{% highlight java %}
    [...] each request from client to server must contain all of the information necessary to understand the request, and cannot take advantage of any stored context on the server.
{% endhighlight %}

Respecting this principle allows us to scale a system easily (you don't need to share sessions among the nodes) and simplifies the monitoring and recovering processes, as [stated by Roy Fielding in his disertation](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_3).

Therefore, the session information has to be kept on the client side and be sent on each request. This information can be just the username (the server would get more information from the database) or it may include more data, like roles, permissions, etc. (making it possible to save a database access).

In the following points I'll be implementing [JSON Web Tokens (JWT)](https://tools.ietf.org/html/rfc7519) authentication, which is very common nowadays. Spring does not offer out of the box support for JWT and I had to gather information from many sources in order to get a complete picture. This post tries to summarize all the information I got.

## JWT

A better explanation can be found [here](https://github.com/jwtk/jjwt#overview) ([JJWT](https://github.com/jwtk/jjwt) is the Java library used in this post to manipulate JWT tokens). So I will quickly go over the JWT aspects that are particularly relevant. For a detailed description, you can read [the specification](https://tools.ietf.org/html/rfc7519).

JSON Web Tokens have three parts:

* A header containing information such as the algorithm used to sign the token.

  {% highlight json %}
    {
      "alg": "HS256"
    }
  {% endhighlight %}
  
* A payload containing claims. There are public claims, like expiration date (exp), and private "claims", like the user id.
  
  {% highlight json %}
    {
      "iat": 1948729422,
      "exp": 1948737982,
      "userId": "admin"
    }
  {% endhighlight %}

* A signature of the Base64 representation of the previous two parts

These three parts are encoded in Base64, signed and concatenated with a dot, resulting in something like:
<sub><sub><sub>eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsb2dnZWRJbkFzIjoiYWRtaW4iLCJpYXQiOjE0MjI3Nzk2Mzh9.gzSraSYS8EXBxLN_oWnFSRgCzcmJmMjLiuyu5CSpyHI</sub></sub></sub>

## Token authentication

The workflow for a token authentication schema is as follows:

{% highlight plaintext %}
(1) The client sends credentials to an authentication service.
(2) The service
   (2.1) validates the credentials. If they are correct,
   (2.2) it generates a token
   (2.3) it signs it with a private key
   (2.4) it returns it to the client
(3) The client receives the token in the response and keeps it for use later on requests that require authentication.
{% endhighlight %}

Later, the client accesses a resource that requires authentication:

{% highlight plaintext %}
(4) The client sends a request including the token in the *Authorization* header, normally with this format: "Bearer &lt;token&gt;".
(5) The server performs several checks, like the signature, expiration date, etc. and 
    obtains the relevant information (user identification, role, etc.)
(6) If all the checks are passed, the server returns the resouce to the client.
{% endhighlight %}

This schema presents some challenges that are new with regard to the cookie based session management:

### How do you logout?

Once you generate a token it exists forever. Does that mean that it is not possible to logout? Somehow.

Loging out, as in the user hitting "loging out" and navigating away to a login form, can be implemented on the client side by just dropping the token. But the token will still be valid even if nobody uses it, so we should care about where we store it, how we transmit it to the server, etc.

It is a good strategy to set an expiration date, in order not to have many valid tokens around. Then, after the user logs out on the client, the token is still valid for a while, but eventually will go invalid.

### How do you deal with an expired token?

So our tokens have an expiration date. Let's say we want this to be 10 minutes. Should the user log in again each 10 minutes? Yes, unless we use an about to expire token to obtain a new one. We could automate a system where any request on the last part of a token lifespan results on receiving a new fresh token in the response.

This way the application would log the user out if he does not use the application for a while (whatever "last part of the token lifespan" means in your application). If the user uses the application regularly he will never be logged out.

Adjusting the token lifespan to few minutes or few days gives a very different user experience.

### How can we revoke a token?

A similar problem as logout: if a user is vandalizing the application and you want to revoke his access immediately, how can you do it?

A solution could be to keep a black list of tokens. Of course this comes with a penalty because the server should check the black list in the point (5) in the workflow above.

### Token hijacking

Analogously to the [session hijacking](https://en.wikipedia.org/wiki/Session_hijacking), if some attacker gets access to the token he can use it until it reaches its expiration date. In the same way, the solution is basically using a secure connection between server and client. Additionally it is possible to encrypt the token ( [JWE](https://tools.ietf.org/html/rfc7516) ).

Some techniques, as browser fingerprinting, can make the hijacking harder but is far from the security level that the previous options give.

### Secret rotation

Can you imagine what would happen if somebody could generate the tokens and sign them as if he was the server? Well, that could be as easy as getting your private key compromised. A common practice is not to store secret keys in code hosted in public repositories (note the irony). That and secret rotation: automate a system in order to change the private key regularly. And, following [Kerckhoffs's principle](https://en.wikipedia.org/wiki/Kerckhoffs%27s_principle), you should consider the rotation algorithm known to the attacker.

## Implementation

In the following points we will see the details about a token based authentication system that:

* Uses JWT as tokens
* It generates tokens containing the user id. No role information will be included so the services using this information will have to query the database in order to get that information.
* Tokens will have an expiration date.
* At the end of the expiration date, a request from the client will get a response containing a new fresh token.
* Client side logout (no blacklists).

As said before, Spring does not offer out of the box support for token based authentication (that I know) and I had to roll my own.

The implementation consists on:

* A success handler for login actions that returns the new token in a HTTP header (jwt-token).
* JWTFilter: A *javax.servlet.Filter* that processes each request and:
  * Creates an *Authentication* instance on the *SecurityContext* whenever the request contains a valid token.
  * If the token is at the end of its lifespan it will return a new token in the *jwt-new-token* header.
* JWTProvider: A class dealing with the token related operations: creation, extraction from the request, validation, etc.

Let's start by the handler. This is configured in the *WebSecurityConfig* class like this:

{% highlight java %}
    .formLogin().loginProcessingUrl("/login").permitAll()//
        [...]
        // If login succeeds return 200 with JWT token
        .successHandler(new JWTTokenStatusHandler()).and()//
{% endhighlight %}

Whenever a successful login takes place, the instance of *JWTTokenStatusHandler* will be called, which will create the token and return it in the *jwt-token* header, along with a 200 (OK) status code:

{% highlight java %}
class JWTTokenStatusHandler implements AuthenticationSuccessHandler {

		@Override
		public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
				Authentication authentication) throws IOException, ServletException {
			String token = jwtTokenProvider.createToken(authentication.getName());
			response.addHeader("jwt-token", token);
			response.setStatus(HttpStatus.OK.value());
		}

	}
{% endhighlight %}

This code makes use of *JWTProvider.createToken*, which looks like this:

{% highlight java %}
	public String createToken(String username) {
		Claims claims = Jwts.claims().setSubject(username);
		Date now = new Date();
		Date expiration = new Date(now.getTime() + validityInMilliseconds);
		return Jwts.builder()//
				.setClaims(claims)//
				.setIssuedAt(now)//
				.setExpiration(expiration)//
				.signWith(ALGORITHM, secretKey)//
				.compact();
	}
{% endhighlight %}

Basically we provide the JJWT library with information such as expiration date, the username and the algorithm and secret key to sign the token. With this information JJWT generates the token String.

Now the client will read the *jwt-token* header and will keep it, sending it back to the server when it requires to access a protected resource. The server will have to check for this token in each request, building an *Authentication* instance for the controllers. That's what the filter does.

The filter can be installed in *WebSecurityConfig*, before the UsernamePasswordAuthenticationFilter, like this:

{% highlight java %}
    http.addFilterBefore(new JWTTokenFilter(jwtTokenProvider), UsernamePasswordAuthenticationFilter.class);
{% endhighlight %}

For a detailed description of the Spring Security filter chain just [check the documentation](https://docs.spring.io/spring-security/site/docs/5.0.9.RELEASE/reference/htmlsingle/#filter-ordering).

The code of the filter is the following:

{% highlight java %}
package org.fergonco.footballManager.controllers;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.GenericFilterBean;

public class JWTTokenFilter extends GenericFilterBean {

	private JWTTokenProvider jwtTokenProvider;

	public JWTTokenFilter(JWTTokenProvider jwtTokenProvider) {
		this.jwtTokenProvider = jwtTokenProvider;
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		// Get the token from the request
		String token = jwtTokenProvider.getToken((HttpServletRequest) request);
		try {
			// If there was a token and it is valid (e.g.: not expired)
			if (token != null && jwtTokenProvider.validateToken(token)) {
				// Get the authentication instance and set it in the SecurityContext
				SecurityContextHolder.getContext().setAuthentication(jwtTokenProvider.getAuthentication(token));
				
				// Check if the token is about to expire and we need to generate a fresh one
				String newToken = jwtTokenProvider.getRefreshToken(token);
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

As we said before, the token is sent in the *Authorization* header as "Bearer &lt;token&gt;".

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

However, **it must check if the algorithm used to sign the token is different to the one used to create it** (*ALGORITHM* constant). This is very important, specially because the algorithm can be "none"! Imagine your access control layer accepting tokens that anybody could be generating.

If the token is valid, an Authentication instance is generated from the token with the *getAuthentication* method:

{% highlight java %}
	public Authentication getAuthentication(String tokenString) {
		String user = null;
		Jws<Claims> claims = Jwts.parser().setSigningKey(secretKey).parseClaimsJws(tokenString);
		user = claims.getBody().getSubject();
		UserDetails userDetails = myUserDetails.loadUserByUsername(user);
		UsernamePasswordAuthenticationToken ret = new UsernamePasswordAuthenticationToken(userDetails, "",
				userDetails.getAuthorities());
		return ret;
	}
{% endhighlight %}

It just accesses the body of the token and gets the information encoded there when it was created: the username. With this information, it uses the usual Spring Security beans in order to load user data and generate an *Authentication* instance.

## Best practices

There are a lot of pages suggesting best practices. I found these interesant:



Piece of advice by Daniel Kachakil.

Do not accept any token with a different algorithm, specially "none"!
