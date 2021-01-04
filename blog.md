---
layout: default
title: Fergonco's log
---
# {{ page.title }}

<ul class="postlist">
{% for post in site.posts %}
{% if post.title == 'CI/CD at AI Incube' %}
<li>{{ post.date | date_to_string }} -> <a href="https://medium.com/aiincube-engineering/ci-cd-at-ai-incube-c014039294b4">{{post.title}} (In Medium)</a></li>
{% elsif post.title == 'Kubernetes liveness and readiness probes with Spring Boot' %}
<li>{{ post.date | date_to_string }} -> <a href="https://medium.com/aiincube-engineering/kubernetes-liveness-and-readiness-probes-with-spring-boot-185af0d5b5de">{{post.title}} (In Medium)</a></li>
{% elsif post.title == 'Sending Kong logs to a GCP Pub/Sub topic' %}
<li>{{ post.date | date_to_string }} -> <a href="https://medium.com/aiincube-engineering/sending-kong-logs-to-a-gcp-pub-sub-topic-dc89f4d299ca">{{post.title}} (In Medium)</a></li>
{% else %}
<li>{{ post.date | date_to_string }} -> <a href="{{post.url}}">{{post.title}}</a></li>
{% endif %}
{% endfor %}
</ul>
