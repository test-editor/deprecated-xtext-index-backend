package org.testeditor.web.xtext.index

import io.dropwizard.Application
import io.dropwizard.setup.Bootstrap
import io.dropwizard.setup.Environment
import org.testeditor.web.xtext.index.health.XtextIndexTemplateHealthCheck
import org.testeditor.web.xtext.index.resources.XtextIndexHelloWorldResource

class XtextIndexHelloWorldApplication extends Application<XtextIndexHelloWorldConfiguration> {
    def static main(String[] args) throws Exception {
        new XtextIndexHelloWorldApplication().run(args)
    }

    override getName() {
        return "hello-world"
    }

    override initialize(Bootstrap<XtextIndexHelloWorldConfiguration> bootstrap) {
        // nothing to do yet
    }

    override run(XtextIndexHelloWorldConfiguration configuration,
                    Environment environment) {
        val resource = new XtextIndexHelloWorldResource(
        	configuration.template, configuration.defaultName)
       	val healthCheck = new XtextIndexTemplateHealthCheck(configuration.template)
       	
		environment.jersey.register(resource)   	
       	environment.healthChecks.register("template", healthCheck)
    }
}
