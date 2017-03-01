---
layout: default
title: Fergonco's log
---
# {{ page.title }}

<ul class="postlist">
{% for post in site.posts %}
<li>{{ post.date | date_to_string }} -> <a href="{{post.url}}">{{post.title}}</a></li>
{% endfor %}
</ul>
