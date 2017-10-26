package org.testeditor.web.xtext.index.resources

import org.testeditor.web.xtext.index.api.Saying
import com.codahale.metrics.annotation.Timed

import javax.ws.rs.GET
import javax.ws.rs.Path
import javax.ws.rs.Produces
import javax.ws.rs.QueryParam
import javax.ws.rs.core.MediaType
import java.util.concurrent.atomic.AtomicLong
import java.util.Optional

@Path("/xtext/index/hello-world")
@Produces(MediaType.APPLICATION_JSON)
class XtextIndexHelloWorldResource {

    val String template
    val String defaultName
    val AtomicLong counter

    new(String template, String defaultName) {
        this.template = template
        this.defaultName = defaultName
        this.counter = new AtomicLong
    }

    @GET @Timed def sayHello(@QueryParam("name") Optional<String> name) {
        val value = String.format(template, name.orElse(defaultName))
        return new Saying(counter.incrementAndGet, value)
    }
}
