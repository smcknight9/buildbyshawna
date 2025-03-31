---
layout: default
title: Built by Shawna
permalink: /built/
---

# Built by Shawna

{% for item in site.built %}
- [{{ item.title }}]({{ item.url }})
{% endfor %}