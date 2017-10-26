package org.testeditor.web.xtext.index.health

import com.codahale.metrics.health.HealthCheck

class XtextIndexTemplateHealthCheck extends HealthCheck {
    val String template

    new(String template) {
        this.template = template
    }

    override protected Result check() throws Exception {
        val saying = String.format(template, "TEST")
        if (!saying.contains("TEST")) {
            return Result.unhealthy("template doesn't include a name");
        }
        return Result.healthy();
    }
}
