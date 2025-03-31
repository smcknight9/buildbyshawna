---
layout: default
title: Read by Shawna
permalink: /read/
---

# Read by Shawna

{% for item in site.read %}
- [{{ item.title }}]({{ item.url }})
{% endfor %}
